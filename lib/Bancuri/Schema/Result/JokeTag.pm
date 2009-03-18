package Bancuri::Schema::Result::JokeTag;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("joke_tag");
__PACKAGE__->add_columns(
  "joke_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "tag_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "tagged",
  {
    data_type => "timestamp without time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
);
__PACKAGE__->add_unique_constraint("idx_joke_tag_unique", ["joke_id", "tag_id", "user_id"]);
__PACKAGE__->belongs_to(
  "joke_id",
  "Bancuri::Schema::Result::Joke",
  { id => "joke_id" },
);
__PACKAGE__->belongs_to("tag_id", "Bancuri::Schema::Result::Tag", { id => "tag_id" });


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-03-18 23:50:47
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:nUipxo08LdFntRCdnCuESA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
