package Bancuri::Schema::Joke;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("joke");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('joke_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "version",
  { data_type => "smallint", default_value => 1, is_nullable => 1, size => 2 },
  "link",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 64,
  },
  "changed",
  {
    data_type => "timestamp without time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
  "deleted",
  {
    data_type => "boolean",
    default_value => "false",
    is_nullable => 1,
    size => 1,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("pk_joke", ["id"]);
__PACKAGE__->add_unique_constraint("idx_joke_link", ["link"]);
__PACKAGE__->has_many(
  "joke_versions",
  "Bancuri::Schema::JokeVersion",
  { "foreign.joke_id" => "self.id" },
);
__PACKAGE__->has_many(
  "tags",
  "Bancuri::Schema::Tag",
  { "foreign.joke_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-12-21 03:04:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TPZH2CLbulCwkkdAqVwHrA

#__PACKAGE__->load_components(qw/PK::Auto Core/);

__PACKAGE__->resultset_class('Bancuri::ResultSet::Joke');

__PACKAGE__->has_one(
  "current_version",
  "Bancuri::Schema::JokeVersion",
  { "foreign.joke_id" => "self.id",
  	"foreign.version" => "self.version" },
);

# TODO move methods for Resultset BELOW to a ResultSet (not result) ...

sub get {
	my ($self, $link, $version) = @_;
	
	return $self->find({ link => $link, version => $version });
}

sub add {
	my ($self) = @_;
	
	# add trebuie sa fie in resultset nu in joke class
	# http://www.gossamer-threads.com/lists/catalyst/users/18185#18185
	
	# $schema->txn_do($coderef);
	# http://search.cpan.org/~ash/DBIx-Class-0.08010/lib/DBIx/Class/Storage.pm#txn_do
	# add a joke ...
	# return $self->price * $self->currency->rate; (use related tables)
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
