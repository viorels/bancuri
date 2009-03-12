package Bancuri::Schema::ResultSet::Joke;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Math::Random qw(random_beta);
use DateTime;

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

=head2 search_for_day 

Search the default joke for_day. If none found and time is still early then 
use the yesterday one (or day before). Otherwise assign one. If all
fails then Titanic doesn't (the first joke). 
This function does NOT work for any day, as it assigns

=cut

sub search_for_day {
    my ($self, $day, $tz) = @_;
    
    my $joke = $self->get_for_day($day);

    if (!$joke and "before_noon") {
        $joke = $self->search(
            { for_day => {'<' => $day} },
            { order_by => "for_day desc" }
        )->slice(0,0)->single;
    };
    unless ($joke) {
        $joke = $self->set_for_day($day);
    }
    unless ($joke) {
        $joke = $self->slice(0,0)->single;
    }
    return $joke;
}

sub get_for_day {
    my ($self, $day) = @_;

    return $self->find({ for_day => $day }, { key => 'idx_joke_for_day' });
};

sub set_for_day {
    my ($self, $day, $id) = @_;

    my $min_votes = 10; # If min votes is raised then the rating is lowered
    my $joke = $self->search(
        { for_day => undef, voted => { '>' => $min_votes } },
        { join => 'current', order_by => "rating desc" })->slice(0,0)->single;

    # TODO use configured timezone
    $joke->update({ for_day => 'now()' });

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
