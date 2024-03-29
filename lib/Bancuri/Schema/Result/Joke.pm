package Bancuri::Schema::Result::Joke;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("joke");
__PACKAGE__->add_columns(
  "id",
  {
    data_type => "integer",
    default_value => "nextval('joke_id_seq'::regclass)",
    is_nullable => 0,
    size => 4,
  },
  "version",
  { data_type => "smallint", default_value => 1, is_nullable => 1, size => 2 },
  "link",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 64,
  },
  "for_day",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
  "changed",
  {
    data_type => "timestamp without time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
  "deleted",
  {
    data_type => "boolean",
    default_value => "false",
    is_nullable => 1,
    size => 1,
  },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint("idx_joke_for_day", ["for_day"]);
__PACKAGE__->add_unique_constraint("pk_joke", ["id"]);
__PACKAGE__->add_unique_constraint("idx_joke_link", ["link"]);
__PACKAGE__->has_many(
  "changes",
  "Bancuri::Schema::Result::Change",
  { "foreign.joke_id" => "self.id" },
);
__PACKAGE__->has_many(
  "joke_tags",
  "Bancuri::Schema::Result::JokeTag",
  { "foreign.joke_id" => "self.id" },
);
__PACKAGE__->has_many(
  "joke_versions",
  "Bancuri::Schema::Result::JokeVersion",
  { "foreign.joke_id" => "self.id" },
);
__PACKAGE__->has_many(
  "visits",
  "Bancuri::Schema::Result::Visit",
  { "foreign.joke_id" => "self.id" },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-03-20 00:27:10
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:BMyTTmNaSa/TvEQbdB1GiQ

__PACKAGE__->mk_group_accessors('simple' => qw/position text_snippet/);

__PACKAGE__->has_one(
  "current",
  "Bancuri::Schema::Result::JokeVersion",
  { "foreign.joke_id" => "self.id",
    "foreign.version" => "self.version" },
);

__PACKAGE__->many_to_many(tags => 'joke_tags', 'tag_id');

use List::Util qw(sum);
use Search::Tools::Transliterate;

sub first {
    my ($self) = @_;
    
    my $first = $self->find_related('joke_versions', {
        version => 1,
    });
    
    return $first; 
}

=item remove
Remove a joke (mark as deleted).
Required argument hash keys: user_id, browser_id, comment 
=cut

sub remove {
    my ($self, %params) = @_;
    
    unless ( $self->deleted ) {
        $self->deleted(1);
        $self->update;
        $self->create_related('changes', {
            type => 'delete',
            from_version => $self->version,
            %params,
        });
    }    
}

=item add_version

Adds a new version to the current joke, including entry in the change table
Parameters (hash) :
    - text
    - title
    - parent_version
    - user_id
    - browser_id
    - comment
Returns : undef

=cut 

sub add_version {
    my ($self, %new_version) = @_;
    
    # XXX: version race condition !
    $new_version{'version'} = $self->search_related('joke_versions')
        ->get_column('version')->max + 1;

    my %change = (
        from_version    => $self->version,
        to_version      => $new_version{'version'},
        type            => 'edit', 
    );
    $change{$_} = $new_version{$_} for qw(user_id browser_id comment);
        
    # We need change comment but not version comment
    delete $new_version{'comment'};
    
    $self->create_related('joke_versions', \%new_version);
    $self->create_related('changes', \%change);
    $self->version($new_version{'version'});
    $self->update;
    
    return;
}

=item requires_moderation
Does the node require moderation ? 
If so then return change object. Otherwise return undef. 
=cut

sub requires_moderation {
    my ($self, $current_user) = @_;
    
    # Current version or undef if deleted
    my $curent_version = $self->deleted ? undef : $self->version;

    # Search for the latest change request leading to current version
    # Assume that it can only return an unmoderated change or an accepted one
    # as rejected changes do not lead to current versions
	my $change = $self->search_related('changes', {
	    to_version => $curent_version,
        -or => [
            approved => 1,
            approved => undef,
        ],
    }, {
        order_by => 'proposed DESC',
    })->slice(0,0)->single;

    # If we've found an approved change then there's no need for moderation
    if (defined $change and $change->approved) {
        $change = undef;
    }
    
    return $change;
}

sub default_link {
    my ($self) = @_;
    
    my $link;
    # TODO get max link size from schema
    my $link_size = 40;

    # Convert UTF-8 to ascii where possible, lowercase 
    # and strip illegal url chars
    my $tr = Search::Tools::Transliterate->new();
    my $title = $tr->convert( $self->current->title );
    $title = lc $title;
    $title =~ s/[^0-9a-z \Q$-_.+!*'()\E]//g;
 
    my @words = split /\s/, $title;
    
    # Remove first -
    $words[0] =~ s/^-//;
    
    my $use_id = 0;
    do {
        my @link = @words;
        if ( $use_id ) {
            # Link length = sum of all words length + number of spaces 
            #        + length of id
            while ( sum( map { length } @link ) + @link + 
                    length $use_id > $link_size ) {
                pop @link;  
            };
            push @link, $use_id;
        }
        
        # Try next id if we get called again;
        $use_id++;

        $link = join '-', @link;
    } while ( $self->result_source->resultset->find({ link => $link }) );

    return $link;
}

sub add_tags_by_user {
    my ( $self, $tags, $user ) = @_;

    my $user_id = $user ? $user->id : undef;
    my $schema = $self->result_source->schema;

    for my $tag_name ( @$tags ) {
        my $tag = $schema->resultset('Tag')->find_or_create({ name => $tag_name });
        $schema->resultset('JokeTag')->find_or_create({ 
            joke_id => $self->id,
            tag_id => $tag->id, 
            user_id => $user_id 
        }, { key => 'idx_joke_tag_unique' });
    }

    return;
}

1;
