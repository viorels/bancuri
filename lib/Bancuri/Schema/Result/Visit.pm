package Bancuri::Schema::Result::Visit;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("visit");
__PACKAGE__->add_columns(
  "joke_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "date",
  { data_type => "date", default_value => "now()", is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("joke_id", "user_id");
__PACKAGE__->add_unique_constraint("pk_visit", ["joke_id", "user_id"]);
__PACKAGE__->belongs_to(
  "user_id",
  "Bancuri::Schema::Result::Users",
  { id => "user_id" },
);
__PACKAGE__->belongs_to(
  "joke_id",
  "Bancuri::Schema::Result::Joke",
  { id => "joke_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-03-20 00:27:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xicmm2CulvvfgLI598D7NQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
