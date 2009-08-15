package Bancuri::View::JSON;

use strict;
use base 'Catalyst::View::JSON';

use HTML::Entities;

__PACKAGE__->config({
    expose_stash    => qr/^json_/,
    encoding        => 'utf-8',
});

sub process {
    my $self = shift;
    my ($c) = @_;
#    $self->filter_stash($c->stash);
    $self->SUPER::process(@_);
}

sub filter_stash {
    my $self = shift;
    my ($stash) = @_;

    if ( exists $stash->{'json_joke_versions'} ) {
        my $versions = $stash->{'json_joke_versions'};
        for my $ver (@$versions) {
            $ver->{'text'} = html_line_break(html_entity($ver->{'text'}));
            $ver->{'text'} = html_entity($ver->{'text'});
        }
    }
}

sub html_entity {
    my ($text) = @_;
    return encode_entities($text);
}

sub html_line_break  {
    my ($text) = @_;
    $text =~ s|(\r?\n)|<br />$1|g;
    return $text;
}


=head1 NAME

Bancuri::View::JSON - Catalyst JSON View

=head1 SYNOPSIS

See L<Bancuri>

=head1 DESCRIPTION

Catalyst JSON View.

=head1 AUTHOR

Viorel Stirbu,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
