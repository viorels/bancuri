package Bancuri::Controller::Search;

use strict;
use warnings;
use base 'Catalyst::Controller';

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
    
    my $it = $c->model('Xapian')->search(
        $c->req->param('q'),
        $c->req->param('page') || 0,
        $c->req->param('itemsperpage') || 0
    );
    
    use Data::Dumper;
    $c->log->debug(Dumper $it->hits);
    
    # TODO highlight 
    # http://dev.swish-e.org/browser/libswish3/trunk/perl/xsearch.pl
    # http://www.google.com/codesearch/p?hl=en#AXv3X_0il7U/lemur.sei/src/lemur/xapian/highlight.py&q=highlight%20package:xapian
    
    # Search::Xapian::Enquire::get_matching_terms_begin
    
    $c->stash->{results} = $it->hits;
    $c->stash->{template} = 'search.html';
}

sub all : Chained('/') PathPart('all') Args(0) {
    my ( $self, $c ) = @_;
    
    my $jokes;
    $c->stash->{'template'} = 'search.html';
    $c->stash( all => $jokes );
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
