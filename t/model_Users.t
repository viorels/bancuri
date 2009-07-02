use strict;
use warnings;
use Test::More tests => 6;

use DateTime;
use DateTime::Duration;

BEGIN { use_ok 'Bancuri::Model::BancuriDB' }

my $schema = new Bancuri::Model::BancuriDB;

my $user = $schema->resultset('Users')->new_result({});

ok( !$user->is_underage, 'undefined age so not underage' );

my $year = DateTime->now->year;
$user->birth( DateTime->new( year => $year ) );
is( $user->birth->year, $year, 'set the right birth year' );
ok( $user->is_underage, 'is_underage' );

my $age = 20;
my $birth_year = (DateTime->now - DateTime::Duration->new( years => $age ))
                ->truncate( to => 'year' );
$user->birth($birth_year);
is( $user->age, $age, 'set the right age' );

ok( !$user->is_underage, 'not is_underage' );

