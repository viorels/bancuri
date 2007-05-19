use Test::More tests => 2;
BEGIN { use_ok( Catalyst::Test, 'Bancuri' ); }

ok( request('/')->is_success );
