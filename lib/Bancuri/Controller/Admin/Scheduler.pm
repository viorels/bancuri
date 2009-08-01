package Bancuri::Controller::Admin::Scheduler;

use strict;
use warnings;
use parent 'Catalyst::Controller';

use Data::Dump qw(pp);

=head1 NAME

Bancuri::Controller::Admin::Scheduler - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    
    $c->stash(
        template    => 'admin/scheduler.html',
        event_keys  => [qw/ event at auto_run next_run last_run last_output /],
        state       => $c->scheduler_state,
    );
}


=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
