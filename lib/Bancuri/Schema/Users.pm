package Bancuri::Schema::Users;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("users");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('users_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 64,
  },
  "email",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "password",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "birth",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
  "karma",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "comment",
  {
    data_type => "text",
    default_value => "''::text",
    is_nullable => 1,
    size => undef,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("pk_users", ["id"]);
__PACKAGE__->add_unique_constraint("idx_users_email", ["email"]);
__PACKAGE__->has_many(
  "changes",
  "Bancuri::Schema::Change",
  { "foreign.user_id" => "self.id" },
);
__PACKAGE__->has_many(
  "joke_versions",
  "Bancuri::Schema::JokeVersion",
  { "foreign.user_id" => "self.id" },
);
__PACKAGE__->has_many(
  "user_openids",
  "Bancuri::Schema::UserOpenid",
  { "foreign.user_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-01-04 21:39:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:myrgGdJzkXDPGUSwQVSgcg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
