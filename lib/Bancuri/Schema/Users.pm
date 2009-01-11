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
  "country",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 64,
  },
  "karma",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "deleted",
  {
    data_type => "boolean",
    default_value => "false",
    is_nullable => 1,
    size => 1,
  },
  "comment",
  {
    data_type => "text",
    default_value => "''::text",
    is_nullable => 1,
    size => undef,
  },
  "created",
  {
    data_type => "timestamp without time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
  "gender",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 6,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("pk_users", ["id"]);
__PACKAGE__->add_unique_constraint("idx_users_email", ["email"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-01-11 03:51:59
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:P6VYX6bhgpEFjQpDsbmFhQ

__PACKAGE__->resultset_class('Bancuri::ResultSet::Users');

# You can replace this text with custom content, and it will be preserved on regeneration
1;
