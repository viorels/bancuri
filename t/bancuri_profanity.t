use strict;
use warnings;
use Test::More tests => 7;
use Test::Exception;

BEGIN { use_ok 'Bancuri::Profanity' }

my @words = qw(pula pizda);
my $bp = new Bancuri::Profanity( words => \@words );

# simple test that should work
is( $bp->filter_joke('pula pizda'), 'p**a p***a', 'pula pizda' );

# ignore part of a word
is( $bp->filter_joke('pulapizda'), 'pulapizda', 'pulapizda' );

# odd position word
is( $bp->filter_joke(' -pula'), ' -p**a', ' -p**a' );

# ignore non word
is( $bp->filter_joke('.,;'), '.,;', '.,;' );

push @words, 'fut';
$bp->reset_regexp;

# Incearca un cuvant nou adaugat
is ( $bp->filter_joke('fut'), 'f*t', 'adaugat fut' );

# words arg check
throws_ok { $bp->words("aaa") } qr/does not pass the type constraint/, 'type constraint';


