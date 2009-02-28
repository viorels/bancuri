#!/usr/bin/perl 

use strict;
use warnings;

use Encode;
use HTML::Entities;
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

my $joke = $new_schema->resultset('Joke');
$joke->delete();

my $redirect = $new_schema->resultset('Redirect');

while ( my $banc = $bancuri->next ) {
	my @tags = @{$tags{ $banc_tag{ $banc->id } }};
	my @tag_rows = map { {tag => $_} } @tags; # structure to insert in db
	
	# TODO add tags
	print $banc->id, " @tags\n";

    # Skip bad jokes
    next if $joke->bad_joke( $banc->banc );
#	next if $banc->id < 4540;
	
    # Fix encoding
    # TODO check for double encoding !!!
	my $banc_text = encode( "UTF-8", decode_entities($banc->banc) );
    #text => encode("utf8",decode("windows-1250", $banc->banc)),

    # Fix totally wrong line terminators (no such thing as \n\r)
    $banc_text =~ s/\n\r/\n/g;
    
    # Convert dos/mac terminators to unix
    $banc_text =~ s/\r\n|\n|\r/\n/g;

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


