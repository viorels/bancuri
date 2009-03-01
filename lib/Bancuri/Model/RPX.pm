package Bancuri::Model::RPX;
use strict;
use warnings;
use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( 
    class       => 'Net::API::RPX',
    constructor => 'new',
);

1;
