package Bancuri::Schema::Result::Tag;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("tag");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('tag_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 32,
  },
  "created",
  {
    data_type => "timestamp without time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("idx_tag_name", ["name"]);
__PACKAGE__->add_unique_constraint("pk_tag", ["id"]);
__PACKAGE__->has_many(
  "joke_tags",
  "Bancuri::Schema::Result::JokeTag",
  { "foreign.tag_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-03-18 23:12:23
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:+0aQcpgm7II7BKlqDlLpkg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
