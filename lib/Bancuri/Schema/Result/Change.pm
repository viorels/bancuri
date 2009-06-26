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

sub vote {
    my ($self, $rating, $user_id, $session_id, $ip, $useragent) = @_;

    # TODO check if user_id is defined !

    my $browser = $self->result_source->schema->resultset('Browser')
        ->find_or_create_unique($session_id, $ip, $useragent); 
    
    my $vote = $self->find_related('change_votes', {
        user_id => $user_id,
        browser_id => $browser->id,
        date => 'now()',
    }, { key => 'pk_change_vote' });
    
    my $new_rating;
    unless ($vote) {
        $self->create_related('change_votes', {
            user_id => $user_id,
            browser_id => $browser->id,
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

# You can replace this text with custom content, and it will be preserved on regeneration
1;
