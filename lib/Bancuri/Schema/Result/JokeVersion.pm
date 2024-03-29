package Bancuri::Schema::Result::JokeVersion;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("joke_version");
__PACKAGE__->add_columns(
  "joke_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "version",
  { data_type => "smallint", default_value => 1, is_nullable => 0, size => 2 },
  "text",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "title",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 64,
  },
  "created",
  {
    data_type => "timestamp without time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
  "parent_version",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "browser_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "rating",
  { data_type => "real", default_value => 0, is_nullable => 0, size => 4 },
  "voted",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "visited",
  { data_type => "integer", default_value => 0, is_nullable => 0, size => 4 },
  "old_rating",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "old_voted",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "old_visited",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "last_visit",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
  "text_sha1",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 40,
  },
);
__PACKAGE__->set_primary_key("joke_id", "version");
__PACKAGE__->add_unique_constraint("pk_joke_version", ["joke_id", "version"]);
__PACKAGE__->belongs_to(
  "user_id",
  "Bancuri::Schema::Result::Users",
  { id => "user_id" },
);
__PACKAGE__->belongs_to(
  "browser_id",
  "Bancuri::Schema::Result::Browser",
  { id => "browser_id" },
);
__PACKAGE__->belongs_to(
  "joke_id",
  "Bancuri::Schema::Result::Joke",
  { id => "joke_id" },
);
__PACKAGE__->has_many(
  "votes",
  "Bancuri::Schema::Result::Vote",
  {
    "foreign.joke_id" => "self.joke_id",
    "foreign.version" => "self.version",
  },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-08-14 20:27:43
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:TH2Bvf6h2oqInjYQ6W9Q+w

__PACKAGE__->mk_group_accessors('simple' => qw/blessed profanity/);

use List::Util qw(sum);
use Digest::SHA qw(sha1_hex);

sub store_column {
    my ( $self, $name, $value ) = @_;
    
    # update digest on text update
    if ($name eq 'text') {
        $self->text_sha1(sha1_hex($value));
    }
    
    $self->next::method($name, $value);
}

sub text_blessed {
    my $self = shift;
    
    unless ( defined $self->blessed ) {
        my $text = $self->text;
        my $profanity;
        if (my $filter = $self->result_source->schema->profanity_filter) {
            ($text, $profanity) = $filter->filter_joke($text);
            $self->blessed($text);
            $self->profanity($profanity);
        }
    }
    
    return $self->blessed;
}

sub has_profanity {
    my ($self) = @_;
    
    unless ( defined $self->profanity ) {
        # This will also set $self->profanity if needed
        $self->text_blessed();
    }
    
    # TODO also check for 'obscen' tag

    return $self->profanity;
}

sub text_teaser {
    my ($self) = @_;

    my $text = $self->text_blessed;
    $text = substr($text, 0, length($text)/2) . " ...";

    return $text;
};

sub rating_round_to_half {
    my ($self) = @_;
    
    return int($self->rating * 2 + .5) / 2;
}

=item vote
Vote on a joke version. Required arguments: rating, user_id, browser_id
Returns the new average rating or undef if user has already voted.
=cut

sub vote {
    my ($self, $rating, $user_id, $browser_id) = @_;

    # TODO transaction ?
    
    my $vote = $self->find_related('votes', {
        browser_id => $browser_id,
        date => 'now()',
    }, { key => 'idx_vote_browser_date' });
    
    my $new_rating;
    unless ($vote) {
        $new_rating = ($self->rating * $self->voted + $rating) / ($self->voted + 1);
        $self->rating( $new_rating );
        $self->voted( $self->voted + 1 );
        $self->update;
        
        $self->create_related('votes', {
            rating => $rating,
            date => 'now()',
            user_id => $user_id,
            browser_id => $browser_id,
        });
    }

    return $new_rating;
}

=item default_title

Generates a default title from text

=cut

sub default_title {
    my ($self) = @_;
    
    my @words = $self->split_words( $self->text_blessed );
    @words = qw(empty) unless @words;
    
    # TODO get this from db schema
    my $title_size = 50; # 64 in db

    # Sum the length of the words and spaces and pop until it's good
    while ( @words 
            and sum( map { length } @words ) + @words > $title_size ) {
        pop @words;
    }

    my $title = join ' ', @words;

    # If it's still too long (one LONG word)
    $title = substr($title, 0, $title_size) if length $title > $title_size;

    return $title;    
}

# http://www.s-anand.net/Splitting_a_sentence_into_words.html

sub split_words {
    my ($self, $text) = @_;

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
