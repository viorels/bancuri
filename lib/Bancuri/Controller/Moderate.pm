package Bancuri::Controller::Moderate;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Bancuri::Controller::Moderate - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub process : Private {
	my ( $self, $c ) = @_;
	$c->forward('recent');
	$c->forward('unmoderated');
	$c->forward('node_all_versions');
}

sub recent : Private {
    my ( $self, $c ) = @_;
	my $wiki = $c->stash->{'wiki'};
    
    my @nodes = $wiki->list_recent_changes(
		days => 7,
		include_all_changes => 1,
	);
	$c->stash( recent => \@nodes );
	# nu prea este util ...
}

sub unmoderated : Private {
    my ( $self, $c ) = @_;
	my $wiki = $c->stash->{'wiki'};
	my @nodes = $wiki->list_unmoderated_nodes( only_where_latest => 1 );
	$c->stash( unmoderated => \@nodes );
}

sub node_all_versions : Private {
    my ( $self, $c ) = @_;
	my $wiki = $c->stash->{'wiki'};
	my $node = $c->stash->{'node'};
		
	my @versions = $wiki->list_node_all_versions(
		name => $node,
		with_content => 1,
		with_metadata => 1
	);
	$c->log->dumper(\@versions);
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
