package Bancuri::Schema::Result::UserRole;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("user_role");
__PACKAGE__->add_columns(
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "role_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
);
__PACKAGE__->set_primary_key("user_id", "role_id");
__PACKAGE__->add_unique_constraint("pk_user_role", ["user_id", "role_id"]);
__PACKAGE__->belongs_to(
  "user_id",
  "Bancuri::Schema::Result::Users",
  { id => "user_id" },
);
__PACKAGE__->belongs_to(
  "role_id",
  "Bancuri::Schema::Result::Role",
  { id => "role_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-02-22 14:13:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:p0962O1el0joM4XzFCNfFA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
