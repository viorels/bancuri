package Bancuri::Schema::ResultSet::Joke;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Math::Random qw(random_beta);
use List::Util qw(sum);

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
use the yesterday one (or day before). Otherwise assign a assign one. If all
fails then Titanic doesn't (the first joke). 

=cut

sub search_for_day {
    my ($self, $day, $noon) = @_;
    
    my $joke = $self->search({ for_day => $day })->first;
    if (!$joke and "before_noon") {
        $joke = $self->search(
            { for_day => {'<' => $day} },
            { order_by => "for_day desc" }
        )->slice(0,0)->first;
    };
    unless ($joke) {
        $joke = $self->set_for_day($day);
    }
    unless ($joke) {
        $joke = $self->first;
    }
    return $joke;
}

sub set_for_day {
    my ($self, $day, $id) = @_;

    # select * from joke_current where votes > 10 and for_day is null order by stars desc limit 1;

    return;    
}

sub search_ids {
    my ($self, $ids) = @_;
    
    # TODO version might have changed meanwhile ... 
    my $jokes = $self->search(
        { id => $ids },
        { prefetch => [ 'current' ] } );

    return $jokes;
}

sub new_link_from_title {
    my ($self, $title) = @_;
    
    # TODO get link size from schema
    my $link_size = 40;

    my $link;
    my @words = split /\s/, $title;
    
    my $use_id = 0;
    my $increment_title = sub {
        my @link = @words;
        if ( $use_id ) {
            while ( sum( map { length } @link ) + @link + length $use_id > $link_size ) {
                pop @link;  
            };
            push @link, $use_id;
        }
        
        # Try next id if we get called again;
        $use_id++;

        return join '-', @link;
    };

    do {
        $link = $increment_title->();
    } while ( $self->find({ link => $link }) );

    return $link;
}

sub add {
	my ($self) = @_;
	
	# http://www.gossamer-threads.com/lists/catalyst/users/18185#18185
	
	# $schema->txn_do($coderef);
	# http://search.cpan.org/~ash/DBIx-Class-0.08010/lib/DBIx/Class/Storage.pm#txn_do
	# add a joke ...
	# return $self->price * $self->currency->rate; (use related tables)
}

1;
