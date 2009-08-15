package Bancuri::Schema::ResultSet::Change;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub search_for_session {
    my ($self, $session_id) = @_;
    
    my $changes = $self->search({ 
        'session_ref_id.id' => "session:$session_id",
    }, { 
        join => { browser_id => 'session_ref_id' }, 
    });
        
    return $changes;
}


1