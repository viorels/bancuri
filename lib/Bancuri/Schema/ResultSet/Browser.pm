package Bancuri::Schema::ResultSet::Browser;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Data::Dump qw(pp);

sub find_or_create_unique {
    my ($self, $session_id, $ip, $useragent_name) = @_;
    $session_id = "session:$session_id";
    my $schema = $self->result_source->schema;
    
    my $browser = $self->search({ 
        session_id          => $session_id,
        ip                  => $ip,
        'useragent_id.name' => $useragent_name,
    }, { 
        join => 'useragent_id' 
    })->single();
    
    unless ($browser) {
        $browser = $self->create({
            session_id      => $session_id,
            ip              => $ip,
            useragent_id    => { name => $useragent_name },
        });
    }

    return $browser;
}

1