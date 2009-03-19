package Bancuri::Schema::Result::Users;

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
  "gender",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 6,
  },
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
  "last_login",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("pk_users", ["id"]);
__PACKAGE__->add_unique_constraint("idx_users_email", ["email"]);
__PACKAGE__->has_many(
  "changes",
  "Bancuri::Schema::Result::Change",
  { "foreign.user_id" => "self.id" },
);
__PACKAGE__->has_many(
  "change_votes",
  "Bancuri::Schema::Result::ChangeVote",
  { "foreign.user_id" => "self.id" },
);
__PACKAGE__->has_many(
  "joke_versions",
  "Bancuri::Schema::Result::JokeVersion",
  { "foreign.user_id" => "self.id" },
);
__PACKAGE__->has_many(
  "user_openids",
  "Bancuri::Schema::Result::UserOpenid",
  { "foreign.user_id" => "self.id" },
);
__PACKAGE__->has_many(
  "user_roles",
  "Bancuri::Schema::Result::UserRole",
  { "foreign.user_id" => "self.id" },
);
__PACKAGE__->has_many(
  "visits",
  "Bancuri::Schema::Result::Visit",
  { "foreign.user_id" => "self.id" },
);
__PACKAGE__->has_many(
  "votes",
  "Bancuri::Schema::Result::Vote",
  { "foreign.user_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-03-20 00:27:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:MgSeBmX0d96sw3SzdR1ctA

__PACKAGE__->many_to_many(roles => 'user_roles', 'role_id');

sub age {
    my ($self) = @_;

    # TODO Return DateTime diff in years. Also make this a setter for birth.
}

sub update_last_login {
    my ($self) = @_;
    
    $self->last_login('now()');
    $self->update;
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
