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

sub banc : PathPart('') Chained('/') Args(1) {
	my ( $self, $c, $node ) = @_;
	
	my $wiki = $c->forward('retrieve', [$node]);
	
	my $raw    = $wiki->retrieve_node($node);
	my $cooked = $wiki->format($raw);
	
	$c->stash(
		banc => $cooked
	);
	$c->stash->{template} = 'banc.html';
}

sub banc_id : Private {
    my ( $self, $c, $id ) = @_;

    $c->response->body("banc id $id");
}

sub retrieve : Private {
	my ( $self, $c, $title ) = @_;
	
	my $dbh = $c->model('DBI')->dbh;
	my $store  = Wiki::Toolkit::Store::Pg->new( dbh => $dbh, charset => 'utf-8' );
	my $search = Wiki::Toolkit::Search::Plucene->new( path => "plucene" );
	my $wiki   = Wiki::Toolkit->new( store => $store, search => $search );
	return $wiki;
}


=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
