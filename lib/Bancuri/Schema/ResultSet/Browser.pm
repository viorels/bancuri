package Bancuri::Schema::ResultSet::Browser;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub find_or_create_unique {
    my ($self, $session_id, $ip, $useragent_name) = @_;
    my $schema = $self->result_source->schema;
    
    my $browser;
    if ( $session_id and $ip and $useragent_name ) {
        $browser = $self->search({ 
            session_id          => "session:$session_id",
            ip                  => $ip,
            'useragent_id.name' => $useragent_name,
        }, { 
            join => 'useragent_id' 
        })->single();
    }
    
    unless ($browser) {
        $browser = $self->create({
            session_id      => ( $session_id ? "session:$session_id" : undef ),
            ip              => $ip,
            useragent_id    => { name => $useragent_name },
        });
    }

    return $browser;
}

1