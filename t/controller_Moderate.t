use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Bancuri' }
BEGIN { use_ok 'Bancuri::Controller::Moderate' }

ok( request('/moderate')->is_success, 'Request should succeed' );


