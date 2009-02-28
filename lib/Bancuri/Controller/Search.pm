package Bancuri::Controller::Search;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Data::SpreadPagination;
use Data::Dump qw(pp);

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
    $c->detach('all') unless length $keywords;
    
    my $page = $c->stash->{'page'} || 1;
    my $perpage = 10;

    my $result = $c->model('Xapian')->search($keywords, $page, $perpage);
    # hits querytime struct search pager query query_obj mset page page_size    

    $c->log->debug(pp $result);
    
    my @ids = map { $_->{'id'} } @{ $result->hits };
    my @jokes;
    if (@ids) {
        @jokes = $c->model('BancuriDB::Joke')->search_ids(\@ids)->all();
        
        my @joke_texts = map { $_->current->text } @jokes;
        my $joke_snippets = $c->model('Xapian')->highlight(\@joke_texts, $keywords);
        
        for (my $i=0; $i<@jokes; $i++) {
            $jokes[$i]->position( $perpage * ($page-1) + $i + 1 );
            $jokes[$i]->text_snippet( $joke_snippets->[$i] );
        }
        
        $c->stash->{results} = \@jokes;
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

    $c->stash(
        pages => $pages,
    );
    
    $c->stash->{template} = 'search.html';
}

sub all : Private {
    my ( $self, $c ) = @_;
    
    $c->response->body('ALL');
}

sub update_index : Private {
    my ( $self, $c ) = @_;
    
    
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
