package Bancuri::Controller::Show;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Data::Dumper;

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
	
	# node_exists ?
	# node_required_moderation
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
	
	my %node_data = $wiki->retrieve_node( name => $node, version => $version );
	my $cooked = $wiki->format($node_data{'content'});
	
	$c->stash(
		text => $cooked,
		last_modified => $node_data{'last_modified'},
		version => $node_data{'version'},
		metadata => Dumper $node_data{'metadata'},		
	);
	$c->stash->{template} = 'banc.html';
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
