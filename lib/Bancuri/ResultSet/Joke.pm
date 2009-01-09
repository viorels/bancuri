package Bancuri::ResultSet::Joke;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub search_next_joke {
    my ($self) = @_;

    my $all_jokes = $self->search(
        {},
        { order_by => 'id DESC' },
    );
    my $count = $all_jokes->count;
    warn "COUNT = $count";
    return $all_jokes;
}

sub search_random_joke {
    my ($self) = @_;

    my $count = $self->count();
    my $offset = int(rand($count));
    my $joke = $self->slice($offset, $offset); 

    return $joke->first;
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
    my @jokes = $self->search(
        { id => $ids },
        { prefetch => [ 'current' ] } );

    return \@jokes;
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
