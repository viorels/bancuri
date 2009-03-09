use strict;
use warnings;
use Test::More tests => 5;

BEGIN { use_ok 'Bancuri::Profanity' }

my @words = qw(pula pizda);
my $bp = new Bancuri::Profanity( words => \@words );

is( $bp->filter_joke('pula pizda'), 'p**a p***a', 'pula pizda' );
is( $bp->filter_joke('pulapizda'), 'pulapizda', 'pulapizda' );
is( $bp->filter_joke('.,;'), '.,;', '.,;' );

push @words, 'fut';
$bp->reset_regexp;

is ( $bp->filter_joke('fut'), 'f*t', 'adaugat fut' );

