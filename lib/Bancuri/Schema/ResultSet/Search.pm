package Bancuri::Schema::ResultSet::Search;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub save_search {
    my ($self, $keywords) = @_;
    
    # TODO normalise queries ?
    my $search = $self->find_or_create({ keywords => $keywords });
    $search->times($search->times + 1);
    $search->last('now()');
    $search->update;

    return;
}

1