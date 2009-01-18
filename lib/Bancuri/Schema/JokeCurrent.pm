package Bancuri::Schema::JokeCurrent;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("joke_current");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "version",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "link",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 64,
  },
  "for_day",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
  "changed",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "deleted",
  { data_type => "boolean", default_value => undef, is_nullable => 1, size => 1 },
  "text",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
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
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "parent_version",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "browser_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "rating",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "voted",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "visited",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "last_visit",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
  "banned",
  { data_type => "boolean", default_value => undef, is_nullable => 1, size => 1 },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-01-18 17:14:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:0fN9hGr+kqhMnuxuI8AHYQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
