package Bancuri::Schema::JokeVersion;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("joke_version");
__PACKAGE__->add_columns(
  "joke_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "version",
  { data_type => "integer", default_value => 1, is_nullable => 0, size => 4 },
  "text",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "title",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 64,
  },
  "comment",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "created",
  {
    data_type => "timestamp without time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
  "parent_ver",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "ip",
  {
    data_type => "inet",
    default_value => undef,
    is_nullable => 0,
    size => undef,
  },
  "useragent_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "stars",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "votes",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "views",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "banned",
  {
    data_type => "boolean",
    default_value => "false",
    is_nullable => 0,
    size => 1,
  },
);
__PACKAGE__->set_primary_key("joke_id", "version");
__PACKAGE__->add_unique_constraint("joke_version_pkey", ["joke_id", "version"]);
__PACKAGE__->belongs_to("joke_id", "Bancuri::Schema::Joke", { id => "joke_id" });


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-12-15 22:32:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:hHgh4khkaddO4L3giyvfsQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
