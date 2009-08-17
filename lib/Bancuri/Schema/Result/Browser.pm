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
  "ip",
  {
    data_type => "inet",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "useragent_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "session_id",
  {
    data_type => "character",
    default_value => undef,
    is_nullable => 1,
    size => 72,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("pk_browser", ["id"]);
__PACKAGE__->add_unique_constraint(
  "idx_browser_session_ip_useragent",
  ["session_id", "ip", "useragent_id"],
);
__PACKAGE__->belongs_to(
  "useragent_id",
  "Bancuri::Schema::Result::Useragent",
  { id => "useragent_id" },
);
__PACKAGE__->has_many(
  "changes",
  "Bancuri::Schema::Result::Change",
  { "foreign.browser_id" => "self.id" },
);
__PACKAGE__->has_many(
  "joke_versions",
  "Bancuri::Schema::Result::JokeVersion",
  { "foreign.browser_id" => "self.id" },
);
__PACKAGE__->has_many(
  "votes",
  "Bancuri::Schema::Result::Vote",
  { "foreign.browser_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-08-17 22:02:36
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:clu5hMAM931IwG6bytlskg

__PACKAGE__->belongs_to(
  "session_id",
  "Bancuri::Schema::Result::Session",
  { id => "session_id" },
);

# You can replace this text with custom content, and it will be preserved on regeneration
1;
