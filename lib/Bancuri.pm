package Bancuri;

use strict;
use warnings;

use Catalyst qw/ConfigLoader
				Session
				Session::State::Cookie
				Session::Store::DBIC
				Authentication
				Authorization::Roles
                Unicode
                DateTime

                Static::Simple
                StackTrace
				/;

our $VERSION = '0.01';

#
# Configure the application
#
__PACKAGE__->config(
    name => 'Bancuri',
    default_view => 'TT',
    session => {
        # Session expires in one day but cookie expires in 2 weeks !
        expires => 86400,
        cookie_expires => 1209600,
        dbic_class => 'BancuriDB::Session',
        id_field => 'id',
        data_field => 'data',
    },
    authentication => {
        default_realm => 'email',
        realms => {
            email => {
                credential => {
                    class => 'Password',
                    password_field => 'password',
                    password_type => 'clear'
                },
                store => {
                    class => 'DBIx::Class',
                    user_class => 'BancuriDB::Users',
                    role_relation => 'roles',
                    role_field => 'role',
                }
            },
            passwordless => {
                credential => {
                    class => 'Password',
                    password_field => 'password',
                    password_type => 'none'
                },
                store => {
                    class => 'DBIx::Class',
                    user_class => 'BancuriDB::Users',
                    role_relation => 'roles',
                    role_field => 'role',
                }
            },
        },
    },
);

# Override Catalyst::Response class
use Bancuri::Response;
__PACKAGE__->response_class('Bancuri::Response');

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
