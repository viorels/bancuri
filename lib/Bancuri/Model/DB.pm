package Bancuri::Model::DB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'Bancuri::Schema',
    connect_info => [
        'dbi:Pg:dbname=bancuri;host=localhost',
        'bancuri',
        'XXXXXXXX',
        {
            AutoCommit        => 1,
            RaiseError        => 1,
            pg_enable_utf8    => 1,
            on_connect_do     => [
                "SET client_encoding=UTF8",
            ],
        },
    ],
);

=head1 NAME

Bancuri::Model::DB - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<Bancuri>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<Bancuri::Schema>

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
