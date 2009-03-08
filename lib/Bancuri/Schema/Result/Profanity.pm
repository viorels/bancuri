package Bancuri::Schema::Result::Profanity;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("profanity");
__PACKAGE__->add_columns(
  "word",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "created",
  {
    data_type => "timestamp without time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
);
__PACKAGE__->set_primary_key("word");
__PACKAGE__->add_unique_constraint("pk_profanity", ["word"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-03-08 15:42:55
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:X9xEfo/aAoePm7oLmA7ukA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
