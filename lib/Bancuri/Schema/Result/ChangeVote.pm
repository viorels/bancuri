package Bancuri::Schema::Result::ChangeVote;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("change_vote");
__PACKAGE__->add_columns(
  "change_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "browser_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "rating",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "date",
  {
    data_type => "timestamp without time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
);
__PACKAGE__->set_primary_key("change_id", "user_id");
__PACKAGE__->add_unique_constraint("pk_change_vote", ["change_id", "user_id"]);
__PACKAGE__->belongs_to(
  "user_id",
  "Bancuri::Schema::Result::Users",
  { id => "user_id" },
);
__PACKAGE__->belongs_to(
  "change_id",
  "Bancuri::Schema::Result::Change",
  { id => "change_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-06-26 17:42:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:kl2luX2y1O6K1CHVhGeO8Q


# You can replace this text with custom content, and it will be preserved on regeneration
1;
