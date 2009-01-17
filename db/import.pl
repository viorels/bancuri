#!/usr/bin/perl 

use strict;
use warnings;

use Encode;
use HTML::Entities;
use Data::Dumper;
use List::Util qw(sum);

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

#print Dumper \%tags;

# LOAD banc_cat

my %banc_tag;
my $banc_cat = $old_schema->resultset('BancCat')->search();
while ( my $cat = $banc_cat->next ) {
	$banc_tag{$cat->banc_id} = $cat->cat_id;
};

# LOAD bancuri

my $bancuri = $old_schema->resultset('Bancuri')->search();

# Remove all jokes and versions
$new_schema->resultset('JokeVersion')->delete();

my $joke = $new_schema->resultset('Joke');
$joke->delete();

my $redirect = $new_schema->resultset('Redirect');

while ( my $banc = $bancuri->next ) {
	my @tags = @{$tags{ $banc_tag{ $banc->id } }};
	my @tag_rows = map { {tag => $_} } @tags; # structure to insert in db
	
	# TODO add tags
	print $banc->id, " @tags\n";

#	next if $banc->id < 4540;
	
    # Fix encoding
    # TODO check for double encoding !!!
	my $banc_text = encode( "UTF-8", decode_entities($banc->banc) );
    #text => encode("utf8",decode("windows-1250", $banc->banc)),

    # Fix line terminators
    $banc_text =~ s/\n\r/\n/g;
    
    my $title = make_title($banc_text);
    my $link = $joke->new_link_from_title($title);
	
	my $new_joke = $joke->create({
        # TODO !!! SALVEAZA NUMARUL DE VIZUALIZARI LA MOMENTUL IMPORT-ULUI
        #      ... in coloana old_views pentru a compara ulterior noua distributie neuniforma p(x) = x
		# TODO create a nice link, redirect and title !!!
		# TODO pentru bancurile not $banc->ok fa o cerere de moderare

		'link' => $link,
		joke_versions => [{
			version => 1,
			text => $banc_text,
			title => $title,
			created => $banc->data,
			rating => $banc->nota/2,
			raters => $banc->voturi,
			views => $banc->vizite,
		}],
		tags => \@tag_rows,
	});
	
	$redirect->create({
	    old_link => $banc->id,
	    new_link => $link,
	})

}

sub make_title {
    my ($text) = @_;
    
    my @words = split_words($text);
    @words = qw(empty) unless @words;
    
    # TODO get this from db schema
    my $title_size = 50; # 64 in db

    # Sum the length of the words and spaces
    my $i = 0;
    # TODO check if off by one !... workaround = join words 0..$i-1
    while ( sum( map { length } @words[0..$i] ) + $i < $title_size
            and $i < $#words ) {
        $i++;
    }

    my $title = join ' ', @words[0..$i-1];

    # TODO If there is just one LONG word the result will be 0 or > $title_size !
    # This is not a good fix ...
    $title = substr($title, 0, $title_size) if length $title > $title_size;

    return $title;    
}

# http://www.s-anand.net/Splitting_a_sentence_into_words.html

sub split_words {
    my ($text) = @_;

    my $boundary = qr/
        [\s+ \! \? \;\(\)\[\]\{\}\<\> " ]
 
# ... by COMMA, unless it has numbers on both sides: 3,000,000
|       (?<=\D) ,
|       , (?=\D)
 
# ... by FULL-STOP, SINGLE-QUOTE, HYPHEN, AMPERSAND, unless it has a letter on both sides
|       (?<=\W) [\.\-\&]
|       [\.\-\&] (?=\W)
 
# ... by QUOTE, unless it follows a letter (e.g. McDonald's, Holmes')
|       (?<=\W) [']
 
# ... by SLASH, if it has spaces on at least one side. (URLs shouldn't be split)
|       \s \/
|       \/ \s
 
# ... by COLON, unless it's a URL or a time (11:30am for e.g.)
|       \:(?!\/\/|\d)
    /x;
    
    my @words = split $boundary, $text;
    my @true_words = grep { length } @words;
    
    return @true_words;
}

1;

sub tags_from_cat {
	my $cat = shift;

	my %transform = (
		'Seci' => ['sec'],
		'Elefant si furnica' => [qw(elefant furnica)],
		'Sir si John' => [qw(sir john)],
		'Elefant si soarece' => [qw(elefant soarece)],
		'Ion si Maria' => [qw(ion maria)],
		'Spermatozoizi' => [qw(spermatozoizi obscen)],
		'Homosexuali' => [qw(homosexuali obscen)],
		'Diverse' => [],
	);
	
	return $transform{$cat} if exists $transform{$cat};

	my $tag = lc $cat ;
	$tag =~ s/\s//g;

	return [ $tag ];
}

package My::Schema;
use base qw/DBIx::Class::Schema::Loader/;

__PACKAGE__->loader_options(
	constraint	=> '^(bancuri|categorii|banc_cat)$',
    debug		=> 1,
);


