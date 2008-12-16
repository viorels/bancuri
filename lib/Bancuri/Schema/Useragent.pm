package Bancuri::Schema::Useragent;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("Core");
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
__PACKAGE__->add_unique_constraint("useragent_pkey", ["id"]);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2008-12-15 22:32:04
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:7qyqrWu6xzSEYUFqElc1cQ


# You can replace this text with custom content, and it will be preserved on regeneration
1;
