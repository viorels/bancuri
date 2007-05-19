use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'Bancuri' }
BEGIN { use_ok 'Bancuri::Controller::Root' }

ok( request('/root')->is_success, 'Request should succeed' );


