package Bancuri::Schema::Result::Role;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("role");
__PACKAGE__->add_columns(
  "id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "role",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 16,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("pk_role", ["id"]);
__PACKAGE__->has_many(
  "user_roles",
  "Bancuri::Schema::Result::UserRole",
  { "foreign.role_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-02-22 14:13:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:R4mn9/NCkQ1KKtwnX+rEsA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
