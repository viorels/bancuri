package Bancuri::Schema::Result::Browser;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("browser");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('browser_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "session_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "ip",
  {
    data_type => "inet",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "useragent_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("pk_browser", ["id"]);
__PACKAGE__->belongs_to(
  "useragent_id",
  "Bancuri::Schema::Result::Useragent",
  { id => "useragent_id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-02-22 14:12:46
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:19Afw6r8NB6c8XrxBgPiuQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
