package Bancuri::Model::Joke;
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

1;
