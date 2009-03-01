package Bancuri::View::TT;

use strict;
use base 'Catalyst::View::TT';

__PACKAGE__->config({
    INCLUDE_PATH => [
        Bancuri->path_to( 'root' ),
#        Bancuri->path_to( 'root', 'inc' ),
    ],
    TEMPLATE_EXTENSION  => '.html',
    CATALYST_VAR        => 'c',
    TIMER               => 0,
#    PRE_PROCESS         => 'config/main',
    WRAPPER             => 'site/wrapper.html',
});

=head1 NAME

Bancuri::View::TT - Catalyst TT View

=head1 SYNOPSIS

See L<Bancuri>

=head1 DESCRIPTION

Catalyst TT View.

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
