package Bancuri::Schema::ResultSet::Users;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

sub search_email_or_openid {
    my ( $self, $id ) = @_;
    
    my $user = $self->find({ email => $id });
    $user = $self->search_openid($id) unless $user;

    return $user;
}

sub search_openid {
    my ( $self, $id ) = @_;
    
    my $user = $self->find({ 'user_openids.identifier' => $id }, 
        { join => 'user_openids' });

    return $user;
}

=item register
Assume nothing ! It can be an email user or openid user.
=cut

sub register {
    my ( $self, $profile ) = @_;
    
    my $email = $profile->{'verifiedEmail'} || $profile->{'email'};
    my $identifier = $profile->{'identifier'};
    
    my $existing_user;
    
    # Only search existing email if email is defined !
    $existing_user = $self->find({ email => $email }) if $email;

    my $new_user = {
        email => $email,
        password => $profile->{'password'},
        name => $profile->{'displayName'},
        birth => $profile->{'birthday'},
        gender => $profile->{'gender'},
        country => $profile->{'address'}{'country'},
    };
    
    my $registered_user;    
    unless ($existing_user) {
        if ( $identifier ) {
            $new_user->{'user_openids'} = [
                { identifier => $identifier }
            ];
        }
        
        $registered_user = $self->create($new_user);
    }
    else {
        if ( $identifier ) {
            $existing_user->create_related('user_openids', {
                identifier => $identifier,
            })
            # TODO update profile also ?
        }
        
        $registered_user = $existing_user;
        
    }

    return $registered_user;
}

=head2 search_needing_email

Search users that prefer to receive the daily joke by email but where only sent
the joke for yesterday (GMT time). 

=cut

sub search_needing_email {
    my ( $self ) = @_;
    
    my $today = $self->result_source->schema->today;
    my $users = $self->search({
        -or => [
            sent_for_day => { '<' => $today },
            sent_for_day => undef,
        ],
        'user_preferences.key' => 'email_joke_for_today',
        'user_preferences.value' => '1',
    }, {
        join => 'user_preferences',
    });
    
    return $users;
}

1;
