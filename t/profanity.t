use strict;
use warnings;
use Test::More tests => 12;
use Test::Exception;

BEGIN { use_ok 'Bancuri::Profanity' }

my @words = qw(pula pizda);
my $bp = new Bancuri::Profanity( words => \@words );

# simple test that should work
is( $bp->filter_joke('pula pizda'), 'p**a p***a', 'p**a p***a' );

# ignore part of a word
is( $bp->filter_joke('pulapizda'), 'pulapizda', 'pulapizda' );
is( $bp->filter_joke('popular'), 'popular', 'popular' );

# odd position word
is( $bp->filter_joke(' -pula'), ' -p**a', ' -p**a' );

# ignore non word
is( $bp->filter_joke('.,;'), '.,;', '.,;' );

# long word
is( $bp->filter_joke('pullaaaa'), 'p******a', 'p******a' );

# diacritice
is( $bp->filter_joke('pul'.chr(0x0103)), 'p**'.chr(0x0103), 'p**ă' );

# upper case
is( $bp->filter_joke('PULA'), 'P**A', 'P**A' );

push @words, 'fut';
$bp->words(\@words);

# Incearca un cuvant nou adaugat
is ( $bp->filter_joke('fut'), 'f*t', 'f*t (dupa adaugare)' );

# Incearca daca cele vechi inca mai functioneaza
is( $bp->filter_joke('pula pizda'), 'p**a p***a', 'p**a p***a' );

# words arg check
throws_ok { $bp->words("aaa") } qr/does not pass the type constraint/, 'type constraint';


