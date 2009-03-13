package Bancuri::Schema::ResultSet::Joke;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Math::Random qw(random_beta);
use DateTime;

=item search_random_joke

Search a random joke with preference for higher rating ones 

=cut

sub search_random_joke {
    my ($self) = @_;

    my $count = $self->count();
    
    # random_beta count=1, a=1.75, b=0.75 => sanse mai mari spre 1 decat spre 0
    my $offset = int( random_beta(1, 1.75, 0.75) * $count );

    my $joke = $self->search( undef, {
        join    => 'current',
        order_by => 'current.rating ASC',  
    })->slice($offset, $offset);

    return $joke;
};

=item set_for_day 

Set the default joke for_day. If no joke_id specified then a good one is 
searched and set.

=cut

sub set_for_day {
    my ($self, $day, $id) = @_;

    my $good_jokes = $self->search(
        { for_day => undef },
        { join => 'current', order_by => "rating desc" });

    # Search good jokes voted by many
    my $min_votes = 10; # If min votes is raised then the rating is lowered
    my $joke = $good_jokes->search({
        voted => { '>' => $min_votes }
    })->slice(0,0)->single;

    # If none found then lower the standards (vote count is ignored)
    # The database is not infinte so this will fail too eventually
    unless ($joke) {
        $joke = $good_jokes->slice(0,0)->single;
    }

    # TODO use configured timezone
    $joke->update({ for_day => $day });

    return $joke;
}

sub search_ids {
    my ($self, $ids) = @_;
    
    # TODO version might have changed meanwhile ... 
    my $jokes = $self->search(
        { id => $ids },
        { prefetch => [ 'current' ] } );

    return $jokes;
}

sub add {
	my ($self, $text) = @_;
	return if $self->bad_joke($text);

	my $joke = $self->create({
		# TODO pentru bancurile not $banc->ok fa o cerere de moderare

        link => undef,
		joke_versions => [{
			version => 1,
			text => $text,
		}],
	});
	
	$joke->current->title( $joke->current->default_title );
	$joke->link( $joke->default_link );
	$joke->update;

    return $joke;	
}

sub bad_joke {
    my ( $self, $text ) = @_; 
    
    # Be optimistic
    my $bad = 0;
    
    # Only empty space
    $bad = 1 if $text =~ /^\s*$/;

    # Words too long (words = non-space)
    $bad = 1 if $text =~ /\S{100,}/;
    
    my @words = split /\s+/, $text;
    $bad = 1 if @words < 7;
    
    return $bad;
}

1;
