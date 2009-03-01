package Bancuri::Schema::Result::UserOpenid;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("user_openid");
__PACKAGE__->add_columns(
  "identifier",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "created",
  {
    data_type => "timestamp without time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
);
__PACKAGE__->set_primary_key("identifier");
__PACKAGE__->add_unique_constraint("pk_user_openid", ["identifier"]);
__PACKAGE__->belongs_to(
  "user_id",
  "Bancuri::Schema::Result::Users",
  { id => "user_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-03-01 19:33:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:d26O8nuXgGEww/7+9+70eQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
