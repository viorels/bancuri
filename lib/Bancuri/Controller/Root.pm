package Bancuri::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

__PACKAGE__->config->{namespace} = '';

=head1 NAME

Bancuri::Controller::Root - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

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
		$c->forward('Bancuri::Controller::Show');
	}
}



  sub wiki : PathPart('') Chained('/') CaptureArgs(1) {
      my ( $self, $c, $page_name ) = @_;
      #  load the page named $page_name and put the object
      #  into the stash
  }

  sub rev : PathPart('rev') Chained('wiki') Args(1) {
      my ( $self, $c, $revision_id ) = @_;
      #  use the page object in the stash to get at its
      #  revision with number $revision_id
      $c->response->body($revision_id);
  }
#
#  sub view : PathPart Chained('rev') Args(0) {
#      my ( $self, $c ) = @_;
#      #  display the revision in our stash. Another option
#      #  would be to forward a compatible object to the action
#      #  that displays the default wiki pages, unless we want
#      #  a different interface here, for example restore
#      #  functionality.
#  }
  
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
