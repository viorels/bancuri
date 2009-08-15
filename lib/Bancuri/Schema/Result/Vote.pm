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
  "rating",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 0,
    size => 2,
  },
  "date",
  { data_type => "date", default_value => "now()", is_nullable => 1, size => 4 },
  "id",
  {
    data_type => "integer",
    default_value => "nextval('vote_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(
  "idx_vote_browser_date",
  ["joke_id", "version", "browser_id", "date"],
);
__PACKAGE__->add_unique_constraint("pk_vote", ["id"]);
__PACKAGE__->belongs_to(
  "user_id",
  "Bancuri::Schema::Result::Users",
  { id => "user_id" },
);
__PACKAGE__->belongs_to(
  "joke_version",
  "Bancuri::Schema::Result::JokeVersion",
  { joke_id => "joke_id", version => "version" },
);
__PACKAGE__->belongs_to(
  "browser_id",
  "Bancuri::Schema::Result::Browser",
  { id => "browser_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-08-15 16:43:20
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:lhFUKEgJvS+D6Id2lpm62Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
