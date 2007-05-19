package Bancuri::Controller::Edit;

use strict;
use warnings;
use base 'Catalyst::Controller';

=head1 NAME

Bancuri::Controller::Edit - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index 

=cut

sub index : Private {
    my ( $self, $c ) = @_;
    
    my $banc = $c->req->params->{banc}; 

    $c->response->body($banc);
}


=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
