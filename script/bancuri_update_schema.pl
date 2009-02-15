#!/usr/bin/perl 

use strict;
use warnings;

my $constraint = $ARGV[0] || '.*';
$constraint = qr/$constraint/;

our $schema_class = "Bancuri::Schema";

use FindBin;
use DBIx::Class::Schema::Loader qw| make_schema_at |;
make_schema_at(
    $schema_class,
    {
        debug          => 1,
        use_namespaces => 1,
        result_namespace => "+$schema_class",
        resultset_namespace => 'ResultSet',
        components     => [qw/InflateColumn::DateTime/],
        dump_directory => "$FindBin::Bin/../lib",
        constraint     => $constraint,
    },
    [ "dbi:Pg:dbname=bancuri;host=localhost", "bancuri", "gSj0wGSH" ]
);


