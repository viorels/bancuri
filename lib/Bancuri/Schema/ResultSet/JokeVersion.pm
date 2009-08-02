package Bancuri::Schema::ResultSet::JokeVersion;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub favorites_for {
    my ($self, %args) = @_;
    my $user_id = $args{'user_id'};

    my $favorites = $self->search({
        'votes.user_id' => $user_id,
        'votes.rating'  => 5,
    }, {
        join        => ['votes', 'joke_id'],
        prefetch    => 'joke_id',
        order_by    => 'votes.date desc',
    });
    
    return $favorites;
}

1