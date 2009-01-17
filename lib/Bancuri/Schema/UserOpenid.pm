package Bancuri::Schema::UserOpenid;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("user_openid");
__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "identifier",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
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
__PACKAGE__->belongs_to("user_id", "Bancuri::Schema::Users", { id => "user_id" });


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-01-17 20:41:48
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:L/W5hVwQ4l+cErtu3LGtRg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
