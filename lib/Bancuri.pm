package Bancuri;

use strict;
use warnings;

use Catalyst qw/ConfigLoader
                Log::Colorful
				/;

#               Unicode
#				Session
#				Session::Store::FastMmap
#				Session::State::Cookie
#               StackTrace
#				Static::Simple

our $VERSION = '0.01';

#
# Configure the application
#
__PACKAGE__->config( 
    name => 'Bancuri',
    default_view => 'Bancuri::View::TT',
   	on_backward_compatibility => 1,
    'Plugin::Log::Colorful' => {
        color_table => {
	        debug       => {
	            color       => 'white',
	            bg_color    => 'black'
	        },
        }
    },
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

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
