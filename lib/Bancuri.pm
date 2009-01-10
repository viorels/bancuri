package Bancuri;

use strict;
use warnings;

use Catalyst qw/ConfigLoader
				Session
				Session::State::Cookie
				Session::Store::FastMmap
				Authentication
				Authorization::Roles
                Unicode
                DateTime

                Static::Simple
                StackTrace
                Log::Colorful
				/;

our $VERSION = '0.01';

#
# Configure the application
#
__PACKAGE__->config( 
    name => 'Bancuri',
    default_view => 'Bancuri::View::TT',
    'Plugin::Authentication' => {
        default_realm => 'email',
        email => {
            credential => {
                class => 'Password',
                password_field => 'password',
                password_type => 'clear'
            },
            store => {
                class => 'DBIx::Class',
                user_class => 'BancuriDB::Users',
#                role_column => 'roles',
            }
        },
#        openid => {
#        },
#        typekey => {
#            credential => {
#                class => 'TypeKey',
#                key_url => 'http://example.com/regkeys.txt',
#            },
#            store => {
#                class => 'Null',
#            }
#        },
    },
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
