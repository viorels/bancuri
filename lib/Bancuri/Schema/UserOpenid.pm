package Bancuri::Schema::UserOpenid;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("user_openid");
__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "openid",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
);
__PACKAGE__->set_primary_key("user_id", "openid");
__PACKAGE__->add_unique_constraint("pk_user_openid", ["user_id", "openid"]);
__PACKAGE__->belongs_to("user_id", "Bancuri::Schema::Users", { id => "user_id" });


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-01-04 21:39:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:NbiQSv+xdbLTQ0eVrEf/Ng


# You can replace this text with custom content, and it will be preserved on regeneration
1;
