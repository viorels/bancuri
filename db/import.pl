#!/usr/bin/perl 

use strict;
use warnings;

use Encode;
use HTML::Entities;
use Data::Dumper;

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

while ( my $banc = $bancuri->next ) {
	my @tags = @{$tags{ $banc_tag{ $banc->id } }};
	my @tag_rows = map { {tag => $_} } @tags; # structure to insert in db
	
	# TODO add tags
	print $banc->id, " @tags\n";

#	next if $banc->id < 4540;
	
    # Fix encoding
    # TODO check for double encoding !!!
	my $banc_text = encode( "UTF-8", decode_entities($banc->banc) );

    # Fix line terminators
    $banc_text =~ s/\n\r/\n/g;
	
	$joke->create({
        # TODO !!! SALVEAZA NUMARUL DE VIZUALIZARI LA MOMENTUL IMPORT-ULUI
        #      ... in coloana old_views pentru a compara ulterior noua distributie neuniforma p(x) = x
		# TODO create a nice link, redirect and title !!!
		# TODO pentru bancurile not $banc->ok fa o cerere de moderare

		'link' => $banc->id,
		joke_versions => [{
			version => 1,
			#text => encode("utf8",decode("windows-1250", $banc->banc)),
			text => $banc_text,
			created => $banc->data,
			user_id => $banc->user,
			stars => $banc->nota/2,
			votes => $banc->voturi,
			views => $banc->vizite,
		}],
		tags => \@tag_rows,
	});

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


