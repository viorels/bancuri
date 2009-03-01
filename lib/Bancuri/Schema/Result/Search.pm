package Bancuri::Schema::Result::Search;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("search");
__PACKAGE__->add_columns(
  "keywords",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 255,
  },
  "times",
  { data_type => "integer", default_value => 1, is_nullable => 1, size => 4 },
  "last",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("keywords");
__PACKAGE__->add_unique_constraint("pk_search", ["keywords"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-03-01 19:33:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xteCXQT+K1KaxNagu2Z3Cg


# You can replace this text with custom content, and it will be preserved on regeneration
1;
