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

sub search_ids {
    my ($self, $ids) = @_;
    
    # TODO version might have changed meanwhile ... 
    my @jokes = $self->search({ id => $ids });
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
