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
    default_value => "nextval('joke_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "version",
  { data_type => "integer", default_value => 1, is_nullable => 0, size => 4 },
  "link",
  {
    data_type => "character varying",
    default_value => "''::character varying",
    is_nullable => 0,
    size => 64,
  },
  "modified",
  {
    data_type => "timestamp without time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
  "verified",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "deleted",
  {
    data_type => "boolean",
    default_value => "false",
    is_nullable => 0,
    size => 1,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("joke_pkey", ["id"]);
__PACKAGE__->has_many(
  "joke_versions",
  "Bancuri::Schema::JokeVersion",
  { "foreign.joke_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-12-15 22:32:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kK6mEebP561s/MDKrCyoOg

__PACKAGE__->has_one(
  "current_version",
  "Bancuri::Schema::JokeVersion",
  { "foreign.joke_id" => "self.id",
  	"foreign.version" => "self.version" },
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
