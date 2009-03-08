#!/usr/bin/perl

use strict;
use warnings;

use List::MoreUtils qw(none);
use Perl6::Slurp;

my @match_profanity = (profanity(), not_profanity());
@match_profanity = grep { my $a = $_; none { $a eq $_ } profanity_rare() } @match_profanity;

my $boundary = qr/(?:\s+|[,.?!():;"'`-])+/;

my $joke = slurp '/tmp/banc';

#print $joke;
my @words = split /($boundary)/, $joke;
for my $word (@words) {
    $word = unfilter_word($word) unless $word =~ /$boundary/;
}
print(join q{}, @words);
exit;

sub unfilter_word { 
    my ($word) = @_;
    my $filter = $word;
    $filter =~ s/\*/./g;
    $filter =~ s/\@/a/g;
    $filter =~ s/#/[fhlt]/g;
    
    my @found = grep { /^$filter$/i } @match_profanity;
    if (@found == 1) {
        return shift @found;
    }
    else {
        return $word;
    }
};

sub profanity {qw(
    caca
    cacarea
    cacat
    cacatu
    cace
    cur
    curu
    curului
    curva
    curve
    fut
    futa
    futai
    fute
    futea
    futeam
    futeati
    futeau
    futel
    futem
    futeo
    futeti
    futi
    futu
    futui
    futut
    futute
    fututi
    homo
    homosexual
    homosexuale
    homosexuali
    homosexualii
    homosexualilor
    homosexualitatii
    homosexualu
    homosexualul
    homosexualului
    laba
    labagiu
    lesbiana
    muie
    nefutut
    penis
    pis
    pisa
    pisat
    pise
    pizda
    pizde
    pizdei
    pizdii
    pizdele
    pizdoase
    pizdos
    pizdulita
    pula
    pulan
    pule
    pulele
    puli
    pulica
    pulicica
    pulii
    pulile
    sex
    sexi
    sexual
    sexuala
    sexuale
    sexul
    sexului
    sperma
    spermatozoid
    spermatozoidul
    spermatozoizi
    spermatozoizii
    spermeaza
    sula
    vagin
)};

sub profanity_rare {qw(
    pisa
    pise
    pulile
    pizdii
)};    

sub not_profanity {qw(
    populara
    populatia
    populatiei
)};

