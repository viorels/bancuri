package Bancuri::Schema;

use strict;
use warnings;

use base 'DBIx::Class::Schema';

__PACKAGE__->load_namespaces(
    result_namespace => 'Result',
    resultset_namespace => 'ResultSet',
);


# Created by DBIx::Class::Schema::Loader v0.04005 @ 2009-02-15 05:55:40
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:FPQvgnKB8pHlpIfzF31+HA

use DateTime;
use Bancuri::Profanity;

sub profanity_filter {
    my ($self) = @_;
    
    unless ( $self->{'_profanity_filter'} ) {
        my @words = $self->resultset('Profanity')->get_column('word')->all;
        my $filter = Bancuri::Profanity->new( words => \@words );
        $self->{'_profanity_filter'} = $filter;
    }
    
    return $self->{'_profanity_filter'};
}

=head2 today

Today in GMT time.

=cut

sub today {
    my ($self) = @_;
    return DateTime->now->ymd;
}

# You can replace this text with custom content, and it will be preserved on regeneration
1;
