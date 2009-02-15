package Bancuri::Schema::Result::Useragent;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("useragent");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('useragent_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "name",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("pk_useragent", ["id"]);
__PACKAGE__->has_many(
  "browsers",
  "Bancuri::Schema::Browser",
  { "foreign.useragent_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-01-04 21:39:54
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:xbkgabvWLAi45FCWpqaaYA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
