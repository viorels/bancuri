package Bancuri::Schema::ResultSet::Joke;
use strict;
use warnings;
use base 'DBIx::Class::ResultSet';

use Math::Random qw(random_beta);
use DateTime;

=item search_random_joke

Search a random joke with preference for higher rating ones 

=cut

sub search_clean {
    my ($self) = @_;

    # TODO use search_with_tag instead of next 6 lines and test
    my $jokes_obscen = $self->search({
        'tag_id.name' => { '=' => 'obscen' },
    },
    {
        join => { joke_tags => 'tag_id' }
    });

    my $jokes = $self->search({
        'me.id' => { -not_in => $jokes_obscen->get_column('id')->as_query }
    });        

    return $jokes;
};

sub search_with_tag {
    my ($self, $tag) = @_;

    my $jokes = $self->search({
        'tag_id.name' => { '=' => $tag },
    },
    {
        join => { joke_tags => 'tag_id' }
    });

    return $jokes;
}

sub search_not_deleted {
    my ($self) = @_;

    return $self->search({
        deleted => 0,
    });
}

sub random_beta_single {
    my ($self) = @_;
    
    my $count = $self->count();
    # random_beta count=1, a=1.75, b=0.75 => sanse mai mari spre 1 decat spre 0
    my $offset = int( random_beta(1, 1.75, 0.75) * $count );

    my $joke = $self->search( undef, {
        join    => 'current',
        order_by => 'current.rating ASC',  
    })->slice($offset, $offset)->single();

    return $joke;
}

sub get_for_day {
    my ($self, $day) = @_; 
    
    return $self->find({ for_day => $day }, { key => 'idx_joke_for_day' });
}

=item get_all_for_days
Get all jokes of the day (but not from future)
=cut

sub get_all_for_days {
    my ($self) = @_;
    
    my $all_jokes = $self->search({
        -and => [
            for_day => { '!=' => undef },
            for_day => { '<=' => 'now()' },
        ]
    }, { 
        key => 'idx_joke_for_day',
        order_by => 'for_day desc',
        prefetch => [ 'current' ],
    });
    
    return $all_jokes;
}

=item set_for_day 

Set the default joke for_day. If no joke_id specified then a good one is 
searched and set.

=cut

sub set_for_day {
    my ($self, $day, $id) = @_;

    my $good_jokes_first = $self->search_not_deleted->search_clean->search(
        { for_day => undef },
        { join => 'current', order_by => "rating desc" });

    # Search good jokes voted by many
    my $min_votes = 10; # If min votes is raised then the rating is lowered
    my $joke = $good_jokes_first->search({
        voted => { '>' => $min_votes }
    })->slice(0,0)->single;

    # If none found then lower the standards (vote count is ignored)
    # The database is not infinte so this will fail too eventually
    unless ($joke) {
        $joke = $good_jokes_first->slice(0,0)->single;
    }

    # TODO use configured timezone
    $joke->update({ for_day => $day });

    return $joke;
}

sub search_ids {
    my ($self, $ids) = @_;
    
    # TODO version might have changed meanwhile ... 
    my $jokes = $self->search(
        { id => $ids },
        { prefetch => [ 'current' ] } );

    return $jokes;
}

=item add
Add a joke with these params:
- text
- user_id
- browser_id
=cut

sub add {
	my ($self, $text, $user_id, $browser_id) = @_;
	return if $self->bad_joke($text);

    my $version = 1;
	my $joke = $self->create({
        link => undef,
		joke_versions => [{
			version => $version,
			text => $text,
            user_id => $user_id,
            browser_id => $browser_id,
		}],
	});
	
    $joke->create_related('changes', {
        type => 'add',
        to_version => $version,
        user_id => $user_id,
        browser_id => $browser_id,
    });
    
    #$joke->add_tags_by_user(\@tags);
	
	$joke->current->title( $joke->current->default_title );
	$joke->link( $joke->default_link );
	$joke->update;

    return $joke;	
}

sub bad_joke {
    my ( $self, $text ) = @_; 
    
    # Be optimistic
    my $bad = 0;
    
    # Only empty space
    $bad = 1 if $text =~ /^\s*$/;

    # Words too long (words = non-space)
    $bad = 1 if $text =~ /\S{100,}/;
    
    my @words = split /\s+/, $text;
    $bad = 1 if @words < 7;
    
    return $bad;
}

1;
