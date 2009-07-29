package Bancuri::Controller::Search;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Data::SpreadPagination;
use Data::Dump qw(pp);
use List::MoreUtils qw(any);

=head1 NAME

Bancuri::Controller::Search - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;
    
    $c->stash->{'keywords'} = $c->request->params->{'keywords'}
        || $c->request->query_keywords;
    $c->stash->{'page'} = $c->request->params->{'page'};

    $c->forward('results');
}

sub keywords : Chained('/') PathPart('search') CaptureArgs(1) {
    my ( $self, $c, $keywords ) = @_;

    # copied from engine unescape_uri
    $keywords =~ s/(?:%([0-9A-Fa-f]{2})|\+)/defined $1 ? chr(hex($1)) : ' '/eg;
    
    $c->stash->{'keywords'} = $keywords;
}

sub page : Chained('keywords') PathPart('') Args(1) {
    my ( $self, $c, $page ) = @_;
 
    $c->stash->{'page'} = $page;
    $c->forward('results');
}

sub first_page : Chained('keywords') PathPart('') Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('results');
} 

sub results : Private {    
    my ( $self, $c ) = @_;
    
    $c->session->{'last_page'} = $c->request->uri;
   
    my $keywords = $c->stash->{'keywords'};
    unless (length $keywords) {
        $c->res->redirect($c->uri_for('/all'), 302) and $c->detach;
    }
    
    my $page = $c->stash->{'page'} || 1;
    my $perpage = 10;
    
    # Save the search
    $c->model('DB::Search')->save_search($keywords);

    my $result = $c->model('Xapian')->search($keywords, $page, $perpage);
    # hits querytime struct search pager query query_obj mset page page_size    

    my @ids = map { $_->{'id'} } @{ $result->hits };
    my @jokes;
    if (@ids) {
        @jokes = $c->model('DB::Joke')->search_ids(\@ids)->all();
        
        my @joke_texts = map { $_->current->text_blessed } @jokes;
        my $joke_snippets = $c->model('Xapian')->highlight(\@joke_texts, $keywords);
        
        for (my $i=0; $i<@jokes; $i++) {
            $jokes[$i]->position( $perpage * ($page-1) + $i + 1 );
            $jokes[$i]->text_snippet( $joke_snippets->[$i] );
        }

        $c->stash->{'profanity'} = any { $_->current->has_profanity } @jokes;
        
        $c->stash->{'results'} = \@jokes;
    }
    
    # query->get_description, match->get_document/get_docid
    
    # TODO highlight 
    # http://dev.swish-e.org/browser/libswish3/trunk/perl/xsearch.pl
    # http://www.google.com/codesearch/p?hl=en#AXv3X_0il7U/lemur.sei/src/lemur/xapian/highlight.py&q=highlight%20package:xapian
    # http://xappy.googlecode.com/svn/trunk/xappy/highlight.py
    # http://article.gmane.org/gmane.comp.search.xapian.general/2027/match=context
    # Search::Xapian::Enquire::get_matching_terms_begin
    
    my $pages = Data::SpreadPagination->new({
        totalEntries     => $result->pager->total_entries,
        entriesPerPage   => $perpage,
        currentPage      => $page,
        maxPages         => 10
    });

    $c->forward('page_base_url');

    $c->stash(
        pages           => $pages,
        current_page    => $page,
        template        => 'search.html',
    );
}

sub update_index : Private {
    my ( $self, $c ) = @_;
    
    
}

### listing functions begin here, they should be joined with search though ...

sub all : Chained('/') CaptureArgs(0) {
    my ( $self, $c ) = @_;
    
    $c->stash->{'jokes'} = $c->model('DB::Joke')
        ->search_not_deleted->search_clean;
}

sub all_page_number : Chained('all') PathPart('') Args(1) {                                                                                                 
    my ( $self, $c, $page ) = @_;

    $c->stash->{'page'} = $page;
    $c->forward('show_list');
}

sub all_first_page : Chained('all') PathPart('') Args(0) {                                                                                                  
    my ( $self, $c ) = @_;

    $c->forward('show_list');
}

sub tag : Chained('/') CaptureArgs(1) {
    my ( $self, $c, $tag ) = @_;

    $c->stash->{'tags'} = $tag;
    $c->stash->{'jokes'} = $c->model('DB::Joke')
        ->search_not_deleted->search_clean->search_with_tag($tag);
}

sub tag_page_number : Chained('tag') PathPart('') Args(1) {
    my ( $self, $c, $page ) = @_;
 
    $c->stash->{'page'} = $page;
    $c->forward('show_list');
}

sub tag_first_page : Chained('tag') PathPart('') Args(0) {
    my ( $self, $c ) = @_;

    $c->forward('show_list');
} 

sub show_list : Private {
    my ( $self, $c ) = @_;

    my $jokes = $c->stash->{'jokes'};
    my $page = $c->stash->{'page'} || 1;
    my $perpage = 10;

    my $pages = Data::SpreadPagination->new({
        totalEntries     => $jokes->count,
        entriesPerPage   => $perpage,
        currentPage      => $page,
        maxPages         => 10
    });

    my @jokes = $jokes->search({}, { prefetch => [ 'current' ] })
        ->slice($pages->first - 1, $pages->last - 1)->all;

    for (my $i=0; $i<@jokes; $i++) {
        $jokes[$i]->position( $pages->first + $i );
        $jokes[$i]->text_snippet( $jokes[$i]->current->text_teaser );
    }

    $c->stash->{'profanity'} = any { $_->current->has_profanity } @jokes;

    $c->forward('page_base_url');

    $c->stash(
        pages           => $pages,
        current_page    => $page,
        results         => \@jokes,
        template        => 'search.html',
    );
}

=item page_base_url
Determine the base url used for next search/tag/all pages, e.g. /search/base_url/page
=cut

sub page_base_url : Private {
    my ( $self, $c ) = @_;

    # Current url without search query args
    # remove ALL search args, otherwise appending '/42' will fail
    my $page_base_url = $c->req->uri_with({ 
        map { $_ => undef } keys %{ $c->req->params } });

    # Only consider the first path segment, 
    # that is 2 elements including the first "" that means /
    my @path_segments = $page_base_url->path_segments;
    @path_segments = @path_segments[0..1];

    warn "*** TAGS".$c->stash->{'tags'};
    my $keywords = $c->stash->{'keywords'} || $c->stash->{'tags'};
    push @path_segments, $keywords if defined $keywords;

    $page_base_url->path_segments(@path_segments);

    $c->stash( page_base_url => $page_base_url->as_string );
}


=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
