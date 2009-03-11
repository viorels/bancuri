#!/usr/bin/perl 

use strict;
use warnings;

use Encode;
use HTML::Entities;
use List::Util qw(sum);
use Data::Dump qw(pp);
use List::MoreUtils qw(none);
use FindBin;

use lib "$FindBin::Bin/../lib";
use Bancuri::Model::BancuriDB;

my $new_schema = new Bancuri::Model::BancuriDB;

my $old_schema = My::Schema->connect( 
  "dbi:mysql:dbname=bancuri;host=dmz",
  "bancuri",
  "gSj0wGSH",
  { AutoCommit => 0 },
);

# LOAD tags

my %tags;
my $categorii = $old_schema->resultset('Categorii')->search({sectiune=>1});
while ( my $cat = $categorii->next ) {
	$tags{$cat->id} = tags_from_cat($cat->nume);
};

# LOAD banc_cat

my %banc_tag;
my $banc_cat = $old_schema->resultset('BancCat')->search();
while ( my $cat = $banc_cat->next ) {
	$banc_tag{$cat->banc_id} = $cat->cat_id;
};

# LOAD bancuri

my $bancuri = $old_schema->resultset('Bancuri')->search();

# Remove all jokes, versions, redirects and tags
$new_schema->resultset('JokeVersion')->delete();
$new_schema->resultset('Redirect')->delete();
$new_schema->resultset('Tag')->delete();
$new_schema->resultset('Profanity')->delete();

my $joke = $new_schema->resultset('Joke');
$joke->delete();

my $redirect = $new_schema->resultset('Redirect');

my @profanity_words = map { { word => $_ } } profanity(); 
$new_schema->resultset('Profanity')->populate(\@profanity_words);

# profanity + not_profanity - profanity_rare => words tu unfilter
my @unfilter_profanity = 
    grep { my $a = $_; none { $a eq $_ } profanity_rare() } 
        (profanity(), not_profanity());

my $profanity_regex = join q{|}, profanity();
$profanity_regex = qr/^$profanity_regex$/i;

while ( my $banc = $bancuri->next ) {
    # Skip bad jokes
    next if $joke->bad_joke( $banc->banc );
#	next if $banc->id < 4540;

    print q{+ } . $banc->id . "\n";
	
    # Fix encoding
    # TODO check for double encoding !!!
	my $banc_text = encode( "UTF-8", decode_entities($banc->banc) );
    #text => encode("utf8",decode("windows-1250", $banc->banc)),

    # Fix totally wrong line terminators (no such thing as \n\r)
    $banc_text =~ s/\n\r/\n/g;
    
    # Convert dos/mac terminators to unix
    $banc_text =~ s/\r\n|\n|\r/\n/g;
    
    my $obscen;
    ( $banc_text, $obscen ) = unfilter_joke($banc_text);

    # add tags (do in memory join of tables to find old category)
	my @tags = @{$tags{ $banc_tag{ $banc->id } }};
	push @tags, 'obscen' if $obscen and none { $_ eq 'obscen' } @tags;
	my @tag_rows = map { {tag => $_} } @tags; # structure to insert in db

	print "~ @tags\n";

	my $new_joke = $joke->create({
		# TODO pentru bancurile not $banc->ok fa o cerere de moderare

		link => undef,
		joke_versions => [{
			version => 1,
			text => $banc_text,
			created => $banc->data,
			rating => $banc->nota/2,
			voted => $banc->voturi,
			visited => $banc->vizite,
			old_rating => $banc->nota/2,
			old_voted => $banc->voturi,
			old_visited => $banc->vizite,
		}],
		tags => \@tag_rows,
	});

	$new_joke->current->title( $new_joke->current->default_title );
	$new_joke->link( $new_joke->default_link );
	$new_joke->update;
	
	$redirect->create({
	    old_link => $banc->id,
	    new_link => $new_joke->link,
	})

}

# END OF MAIN

sub tags_from_cat {
	my $cat = shift;

	my %transform = (
		'Seci' => ['sec'],
		'Elefant si furnica' => [qw(elefant furnica)],
		'Sir si John' => [qw(sir john)],
		'Elefant si soarece' => [qw(elefant soarece)],
		'Ion si Maria' => [qw(ion maria)],
		'Spermatozoizi' => [qw(spermatozoizi)], # obscen ?
		'Homosexuali' => [qw(homosexuali)], # obscen ?
		'Diverse' => [],
	);
	
	return $transform{$cat} if exists $transform{$cat};

	my $tag = lc $cat ;
	$tag =~ s/\s//g;

	return [ $tag ];
}

sub unfilter_joke {
    my ($joke) = @_;

    my $boundary = qr/(?:\s+|[,.?!():;"'`-])+/;

    my @words = split /($boundary)/, $joke;

    my $obscen = 0;
    for my $word (@words) {
        if ( $word !~ /$boundary/ and $word =~ /\*/ ) {
            $word = unfilter_word($word);
            $obscen++ if $word =~ $profanity_regex;
        }
    }

    my $unfiltered = join q{}, @words;
    return wantarray ? ( $unfiltered, $obscen ) : $unfiltered;
}

sub unfilter_word { 
    my ($word) = @_;

    my $filter = $word;
    $filter =~ s/\*/./g;
    $filter =~ s/\@/a/g;
    $filter =~ s/#/[fhlt]/g;
    
    my @found = grep { /^$filter$/i } @unfilter_profanity;
    if (@found == 1) {
        my $found = shift @found;
        
        if ( $word eq ucfirst $word and $word =~ /^\w/ ) {
            $found = ucfirst $found;
            
            my $uccount = scalar grep { /\w/ and uc eq $_ } split //, $word;
            $found = uc $found if $uccount >= 2;
        };

        warn "$word => $found\n";
        return $found;
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
    clitoris
    clitorisul
    coaie
    coaiele
    coi
    coiul
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
    lindic
    lindicul
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


package My::Schema;
use base qw/DBIx::Class::Schema::Loader/;

__PACKAGE__->loader_options(
	constraint	=> '^(bancuri|categorii|banc_cat)$',
    debug		=> 1,
);


