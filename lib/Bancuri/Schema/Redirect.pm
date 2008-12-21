package Bancuri::Schema::Redirect;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
__PACKAGE__->table("redirect");
__PACKAGE__->add_columns(
  "old_link",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 64,
  },
  "new_link",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 64,
  },
  "created",
  { data_type => "date", default_value => "now()", is_nullable => 1, size => 4 },
  "last_used",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("old_link");
__PACKAGE__->add_unique_constraint("pk_redirect", ["old_link"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-12-21 03:04:30
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:1+YU6klE5EPrdEhTpaitEQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
