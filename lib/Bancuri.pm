package Bancuri;

use strict;
use warnings;

use Catalyst qw/ConfigLoader
				Static::Simple
				Session
				Session::Store::FastMmap
				Session::State::Cookie
				Unicode
                StackTrace
				/;

our $VERSION = '0.01';

#
# Configure the application
#
__PACKAGE__->config( 
    name => 'Bancuri',
    default_view => 'Bancuri::View::TT',
);

#
# Start the application
#
__PACKAGE__->setup;

=head1 NAME

Bancuri - Catalyst based application

=head1 SYNOPSIS

    script/bancuri_server.pl

=head1 DESCRIPTION

Catalyst based application.

=head1 METHODS

=head2 default

=cut

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
