package Bancuri::Schema::ChangeVote;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("change_vote");
__PACKAGE__->add_columns(
  "change_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "vote",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "time",
  {
    data_type => "timestamp without time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
);
__PACKAGE__->set_primary_key("change_id", "user_id");
__PACKAGE__->add_unique_constraint("pk_change_vote", ["change_id", "user_id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-12-21 03:04:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:XRgkZYJBps5wnLOCjEyXGA


# You can replace this text with custom content, and it will be preserved on regeneration
1;