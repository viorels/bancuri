package Bancuri::Schema::Result::Vote;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("vote");
__PACKAGE__->add_columns(
  "joke_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "version",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 0,
    size => 2,
  },
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "browser_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "date",
  { data_type => "date", default_value => "now()", is_nullable => 1, size => 4 },
  "rating",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
);
__PACKAGE__->belongs_to(
  "joke_version",
  "Bancuri::Schema::Result::JokeVersion",
  { joke_id => "joke_id", version => "version" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-02-22 14:13:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:IujaYWKzjEfIZ03X4oC7eA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
