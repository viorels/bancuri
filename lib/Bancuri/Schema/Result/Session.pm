package Bancuri::Schema::Result::Session;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("session");
__PACKAGE__->add_columns(
  "ref_id",
  {
    data_type => "integer",
    default_value => "nextval('session_ref_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
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
__PACKAGE__->set_primary_key("ref_id");
__PACKAGE__->add_unique_constraint("pk_session", ["ref_id"]);
__PACKAGE__->add_unique_constraint("idx_session_id", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-03-14 13:05:03
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:mzxM6BG2dYz2TOkqNIbmUQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
