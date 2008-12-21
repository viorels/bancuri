#!/usr/bin/perl 
#===============================================================================
#
#         FILE:  import.pl
#
#        USAGE:  ./import.pl 
#
#  DESCRIPTION:  Import from bancuri 1.0
#
#      OPTIONS:  ---
# REQUIREMENTS:  ---
#         BUGS:  ---
#        NOTES:  ---
#       AUTHOR:  Viorel Stirbu (vio), <viorels@gmail.com>
#      COMPANY:  SVSOFT
#      VERSION:  1.0
#      CREATED:  12/21/2008 01:12:26 PM EET
#     REVISION:  ---
#===============================================================================

use strict;
use warnings;

use Data::Dumper;

use Bancuri::Model::BancuriDB;

my $db_schema = new Bancuri::Model::BancuriDB;


# TRY Bancuri1::Schema

#my $old_schema = Bancuri1::Schema->connect(
#  "dbi:mysql:host=dmz",
#  "bancuri",
#  "gSj0wGSH",
#  { AutoCommit => 0 },
#);

# fetch objects using Library::Schema::DVD
#my $resultset = $old_schema->resultset('Banc')->find( id=>1 );

#print Dumper $resultset;

# TRY My::Schema (autoload)

my $schema1 = My::Schema->connect( 
  "dbi:mysql:dbname=bancuri;host=dmz",
  "bancuri",
  "gSj0wGSH",
  { AutoCommit => 0 },
);

my $rs = $schema1->resultset('Bancuri')->find({id=>1});
print $rs->banc();

#=================


#package Bancuri1::Schema;
#use base qw/DBIx::Class::Schema/;
#
## load Library::Schema::bancuri, Library::Schema::Book, Library::Schema::DVD
#__PACKAGE__->load_classes(qw/Banc Categorie BanCat/);
#
#1;
#
#package Bancuri1::Schema::Banc;
#use base qw/DBIx::Class/;
#__PACKAGE__->load_components(qw/PK::Auto Core/); # for example
#__PACKAGE__->table('bancuri');
#__PACKAGE__->source_name('Banc');
#
#1;
#
#package Bancuri1::Schema::Categorie;


#================
package My::Schema;
use base qw/DBIx::Class::Schema::Loader/;

__PACKAGE__->loader_options(
    debug                 => 1,
);


