package Bancuri::Schema::Result::UserPreference;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("user_preference");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('user_preference_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "key",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 32,
  },
  "value",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("pk_user_preference", ["id"]);
__PACKAGE__->belongs_to(
  "user_id",
  "Bancuri::Schema::Result::Users",
  { id => "user_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-07-28 22:44:22
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BvPNW9AXT7TaqJahg+uT3w


# You can replace this text with custom content, and it will be preserved on regeneration
1;
