package Bancuri::Schema::Result::Change;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("change");
__PACKAGE__->add_columns(
  "joke_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "type",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "to_version",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "from_version",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "from_joke_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "browser_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "rating",
  { data_type => "smallint", default_value => 0, is_nullable => 0, size => 2 },
  "proposed",
  {
    data_type => "timestamp without time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
  "approved",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "rejected",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
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
);
__PACKAGE__->set_primary_key("joke_id", "user_id");
__PACKAGE__->add_unique_constraint("pk_change", ["joke_id", "user_id"]);
__PACKAGE__->belongs_to(
  "user_id",
  "Bancuri::Schema::Result::Users",
  { id => "user_id" },
);
__PACKAGE__->belongs_to(
  "browser_id",
  "Bancuri::Schema::Result::Browser",
  { id => "browser_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-03-13 22:40:24
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:fln5yvWbJIEwLikYDz8LYQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
