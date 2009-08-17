package Bancuri::Schema::ResultSet::Change;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub search_for_session {
    my ($self, $session_id) = @_;
    $session_id = 'session:' . ( $session_id ? $session_id : '' );

    my $changes = $self->search({ 
        'browser_id.session_id' => $session_id,
    }, { 
        join => 'browser_id', 
    });

    return $changes;
}

sub assign_user {
    my ($self, $user_id) = @_;
    
    $self->search({ user_id => undef })->update({user_id => $user_id});
    
    return $self;
}

1