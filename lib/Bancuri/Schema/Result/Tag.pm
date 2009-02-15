package Bancuri::Schema::Result::Tag;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("tag");
__PACKAGE__->add_columns(
  "joke_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "tag",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 32,
  },
);
__PACKAGE__->belongs_to("joke_id", "Bancuri::Schema::Joke", { id => "joke_id" });


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-01-09 21:23:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:ukowDHGsbe1iVVcvnxhqDA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
