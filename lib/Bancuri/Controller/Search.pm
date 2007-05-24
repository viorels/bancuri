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

sub all : Chained('/') PathPart('all') Args(0) {
    my ( $self, $c ) = @_;
	my $wiki = $c->stash->{'wiki'};
    
    $c->stash->{'template'} = 'search.html';
    my @nodes = $wiki->list_all_nodes;
    $c->stash( results => @nodes );
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
