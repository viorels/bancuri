package Bancuri::Schema::Result::JokeVersion;

use strict;
use warnings;

use base 'DBIx::Class';

__PACKAGE__->load_components("InflateColumn::DateTime", "Core");
__PACKAGE__->table("joke_version");
__PACKAGE__->add_columns(
  "joke_id",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "version",
  { data_type => "smallint", default_value => 1, is_nullable => 0, size => 2 },
  "text",
  {
    data_type => "text",
    default_value => undef,
    is_nullable => 1,
    size => undef,
  },
  "title",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 64,
  },
  "comment",
  {
    data_type => "character varying",
    default_value => undef,
    is_nullable => 1,
    size => 255,
  },
  "created",
  {
    data_type => "timestamp without time zone",
    default_value => "now()",
    is_nullable => 1,
    size => 8,
  },
  "parent_version",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "user_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "browser_id",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "rating",
  { data_type => "real", default_value => undef, is_nullable => 1, size => 4 },
  "voted",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "visited",
  { data_type => "integer", default_value => undef, is_nullable => 1, size => 4 },
  "old_rating",
  { data_type => "real", default_value => undef, is_nullable => 0, size => 4 },
  "old_voted",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "old_visited",
  { data_type => "integer", default_value => undef, is_nullable => 0, size => 4 },
  "last_visit",
  { data_type => "date", default_value => undef, is_nullable => 1, size => 4 },
  "banned",
  {
    data_type => "boolean",
    default_value => "false",
    is_nullable => 1,
    size => 1,
  },
);
__PACKAGE__->set_primary_key("joke_id", "version");
__PACKAGE__->add_unique_constraint("pk_joke_version", ["joke_id", "version"]);
__PACKAGE__->belongs_to(
  "user_id",
  "Bancuri::Schema::Result::Users",
  { id => "user_id" },
);
__PACKAGE__->belongs_to(
  "joke_id",
  "Bancuri::Schema::Result::Joke",
  { id => "joke_id" },
);
__PACKAGE__->has_many(
  "votes",
  "Bancuri::Schema::Result::Vote",
  {
    "foreign.joke_id" => "self.joke_id",
    "foreign.version" => "self.version",
  },
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-02-22 14:13:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:L3CZYehHcIszIGABYWE4zw

sub text_teaser {
    my ($self) = @_;

    my $text = $self->text;
    $text = substr($text, 0, length($text)/2) . " ...";

    return $text;
};

sub vote {
    my ($self, $vote, $weight ) = @_;

    # TODO implement using stored procedure;
    my $new_rating = ($self->rating * $self->voted + $vote) / ($self->voted + 1);
    $self->rating( $new_rating );
    $self->voted( $self->voted + 1 );
    $self->update;

    return $self->rating();
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;