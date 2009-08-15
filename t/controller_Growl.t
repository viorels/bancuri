use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Bancuri' }
BEGIN { use_ok 'Bancuri::Controller::Growl' }

ok( request('/growl')->is_success, 'Request should succeed' );


