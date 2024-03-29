package Bancuri::Schema::Result::Session;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("session");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "character",
    default_value => undef,
    is_nullable => 0,
    size => 72,
  },
  "data",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "expires",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("pk_session", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-08-17 22:02:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:rwftleiyh1QDu1Hdz0Mc+A


# You can replace this text with custom content, and it will be preserved on regeneration
1;
