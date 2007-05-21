package Bancuri::Controller::Show;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Wiki::Toolkit;
use Wiki::Toolkit::Store::Pg;
use Wiki::Toolkit::Search::Plucene;

=head1 NAME

Bancuri::Controller::Show - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub process : Private {
	my ( $self, $c ) = @_;
	$c->response->body('Matched Bancuri::Controller::Show');
}

sub banc : Chained('/wiki') PathPart('') Args(0) {
	my ( $self, $c ) = @_;
	my $node = $c->stash->{'node'};
	
	$c->forward('show', [ $node ]);
}

sub rev : Chained('/wiki') PathPart Args(1) {
    my ( $self, $c, $version ) = @_;
	my $node = $c->stash->{'node'};

	$c->forward('show', [ $node, $version ]);
}

sub show : Private {
	my ( $self, $c, $node, $version ) = @_;
	my $wiki = $c->stash->{'wiki'};
	
	my $raw    = $wiki->retrieve_node( name => $node, version => $version );
	my $cooked = $wiki->format($raw);
	
	$c->stash(
		text => $cooked
	);
	$c->stash->{template} = 'banc.html';
}

sub retrieve : Private {
	
}

sub banc_id : Private {
    my ( $self, $c, $id ) = @_;

    $c->response->body("banc id $id"); # TODO redirect to name
}


=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
