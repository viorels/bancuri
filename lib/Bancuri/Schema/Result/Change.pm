package Bancuri::Schema::Result::Change;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("change");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('change_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "joke_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "from_version",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "to_version",
  {
    data_type => "smallint",
    default_value => undef,
    is_nullable => 1,
    size => 2,
  },
  "type",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 0,
    size => 8,
  },
  "comment",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "browser_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "rating",
  { data_type => "real", default_value => 0, is_nullable => 0, size => 4 },
  "approved",
  { data_type => "boolean", default_value => undef, is_nullable => 1, size => 1 },
  "proposed",
  {
    data_type => "timestamp without time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
  "decided",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
  "verified",
  {
    data_type => "timestamp without time zone",
    default_value => undef,
    is_nullable => 1,
    size => 8,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("pk_change", ["id"]);
__PACKAGE__->belongs_to(
  "user_id",
  "Bancuri::Schema::Result::Users",
  { id => "user_id" },
);
__PACKAGE__->belongs_to(
  "browser_id",
  "Bancuri::Schema::Result::Browser",
  { id => "browser_id" },
);
__PACKAGE__->belongs_to(
  "joke_id",
  "Bancuri::Schema::Result::Joke",
  { id => "joke_id" },
);
__PACKAGE__->has_many(
  "change_votes",
  "Bancuri::Schema::Result::ChangeVote",
  { "foreign.change_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04006 @ 2009-06-26 17:42:11
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:LfapE+zql3TFBuVrHaCxVg

use List::MoreUtils;

__PACKAGE__->has_one(
  "from",
  "Bancuri::Schema::Result::JokeVersion",
  { "foreign.joke_id" => "self.joke_id",
    "foreign.version" => "self.from_version" },
);

__PACKAGE__->has_one(
  "to",
  "Bancuri::Schema::Result::JokeVersion",
  { "foreign.joke_id" => "self.joke_id",
    "foreign.version" => "self.to_version" },
);

=item vote
Vote on a change. Required arguments: rating, user_id, browser_id
Returns the new average rating or undef if user has already voted.
=cut

sub vote {
    my ($self, $rating, $user_id, $browser_id) = @_;

    # TODO check if user_id is defined !
    
    my $vote = $self->find_related('change_votes', {
        user_id => $user_id,
        browser_id => $browser_id,
        date => 'now()',
    }, { key => 'pk_change_vote' });
    
    my $new_rating;
    unless ($vote) {
        $self->create_related('change_votes', {
            user_id => $user_id,
            browser_id => $browser_id,
            date => 'now()',
            rating => $rating,
        });

        $new_rating = $self->search_related('change_votes')
            ->get_column('rating')->func('avg');
            
        $self->rating( $new_rating );
        $self->update;
    }

    return $new_rating;
}

=item decide
Decide if the vote is over.
If so return approved=1/0, otherwise return undef
=cut

sub decide {
    my ($self) = @_;

    my $approved = undef;
    my @votes = $self->search_related('change_votes')->all;
    
    # XXX compare with float rating ?
    if (@votes >= 1 and $self->rating != 0) {
        $approved = $self->rating > 0 ? 1 : 0;

        $self->approved($approved);
        $self->decided('now()');
        $self->update;

        $self->joke_rollback unless $approved;
        
        # Increment/decrement karma with the change's rating
        $self->change_proposer_karma($self->rating);
    }
    
    return $approved;
}

sub change_proposer_karma {
    my ($self, $change) = @_;
    
    my $old_karma = $self->user_id->karma || 0;
    warn "*** CHANGE karma $old_karma + $change";
    $self->user_id->karma($old_karma + $change);
    $self->user_id->update;
} 

=item joke_rollback
Rollback the joke change if it was not approved
=cut

sub joke_rollback {
    my ($self) = @_;
    
    my $approved = $self->approved;
    if (defined $approved and not $approved) {
        my $joke = $self->joke_id;
            
        # Rollback change
        if ($self->type eq 'add') {
            $joke->deleted(1);
        }
        elsif ($self->type eq 'delete') {
            $joke->deleted(0);
        }
        elsif ($self->type eq 'edit') {
            warn "ROLLBACK edit";
            if (defined $self->from_version and $self->to_version == $joke->version) {
                warn "FROM ". $self->from_version. " TO ". $self->to_version;
                $joke->version( $self->from_version );
            }
        }

        $joke->update;
    }
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
