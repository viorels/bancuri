package Bancuri::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

require Wiki::Toolkit;
require Wiki::Toolkit::Store::Pg;
require Wiki::Toolkit::Search::Plucene;
require Wiki::Toolkit::Formatter::Default;

__PACKAGE__->config->{namespace} = '';

=head1 NAME

Bancuri::Controller::Root - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub auto : Private {
	my ( $self, $c ) = @_;
	$c->stash->{'wiki'} = $c->forward('toolkit');
};

sub default : Path('') {
	my ( $self, $c ) = @_;
	
	$c->response->status(404);
	$c->response->body("404 Not Found");
	$c->request->action(undef);	
};

=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;
    my $id = $c->request->params->{id};

	if ($id) {
    	$c->forward(qw/Bancuri::Controller::Show banc_id/, [$id]);
	}
	else {
		$c->forward('Bancuri::Controller::Show'); # show the best ?
	}
}

sub wiki : Chained PathPart('') CaptureArgs(1) {
	my ( $self, $c, $node ) = @_;
	$c->stash->{'node'} = $node;
}

sub toolkit : Private {
	my ( $self, $c, $title ) = @_;
	
	my $dbh = $c->model('DBI')->dbh;
	my $store  = Wiki::Toolkit::Store::Pg->new( dbh => $dbh, charset => 'utf-8' );
    $store->{_charset} = 'utf-8'; # Workaround for bug http://www.wiki-toolkit.org/ticket/24
	my $search = Wiki::Toolkit::Search::Plucene->new( path => "plucene" );
	my $formatter = Wiki::Toolkit::Formatter::Default->new(
    	extended_links  => 0,
        implicit_links  => 0,
        allowed_tags    => [qw(b i)],
        macros          => {},
        node_prefix     => ''
	);
	my $wiki   = Wiki::Toolkit->new(
		store => $store, 
		search => $search, 
		formatter => $formatter 
	);
	return $wiki;
}
  
sub end : ActionClass('RenderView') {
	my ( $self, $c ) = @_;
    # do stuff here; the RenderView action is called afterwards
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
