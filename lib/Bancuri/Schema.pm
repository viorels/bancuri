package Bancuri::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces(
    result_namespace => 'Result',
    resultset_namespace => 'ResultSet',
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-02-15 05:55:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FPQvgnKB8pHlpIfzF31+HA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
