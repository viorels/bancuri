#!/usr/bin/perl 

use strict;
use warnings;

my $constraint = $ARGV[0] || '.*';
$constraint = qr/$constraint/;

use FindBin;
use DBIx::Class::Schema::Loader qw| make_schema_at |;
make_schema_at(
    "Bancuri::Schema",
    {
        debug          => 1,
        use_namespaces => 0,
        components     => [qw/InflateColumn::DateTime/],
        dump_directory => "$FindBin::Bin/../lib",
        constraint     => $constraint,
    },
    [ "dbi:Pg:dbname=bancuri;host=localhost", "bancuri", "gSj0wGSH" ]
);


