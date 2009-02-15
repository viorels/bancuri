package Bancuri::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces(
    result_namespace => '+Bancuri::Schema',
    resultset_namespace => 'ResultSet',
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-02-15 05:15:37
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:gGdRSHgzFFa23QR89CyEvA


# You can replace this text with custom content, and it will be preserved on regeneration
1;
