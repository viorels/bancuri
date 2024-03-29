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
                Scheduler

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
    time_zone => 'Europe/Bucharest',
    session => {
        # Session and cookie expire in one week
        expires => 604800,
        cookie_expires => 604800,
        dbic_class => 'DB::Session',
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
                    user_class => 'DB::Users',
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
                    user_class => 'DB::Users',
                    role_relation => 'roles',
                    role_field => 'role',
                }
            },
        },
    },
    scheduler => {
        time_zone => 'Europe/Bucharest',
    },
);

# Configure the logger
require Catalyst::Log::Log4perl;
__PACKAGE__->log(
    Catalyst::Log::Log4perl->new(
        __PACKAGE__->path_to('bancuri_log.conf')->stringify, watch_delay => 10));

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
