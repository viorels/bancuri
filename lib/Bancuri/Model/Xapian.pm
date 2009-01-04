package Bancuri::Model::Xapian;

use strict;
use base 'Catalyst::Model::Xapian';

use Search::Tools;
use Search::Tools::UTF8;

__PACKAGE__->config(
    index           => 'index',
    language        => 'romanian',
);

sub highlight {
    my ($self, $texts, $keywords) = @_;
    
    my $regex   = Search::Tools->regexp(query => $keywords);
    my $snipper = Search::Tools->snipper(query => $regex);
    my $hiliter = Search::Tools->hiliter(query => $regex);
    
    my @highlighted;
    for my $text ( @$texts ) {
        push @highlighted, $hiliter->light( $snipper->snip( to_utf8( $text ) ) );
    }
    
    return \@highlighted;
}

=head1 NAME

Bancuri::Model::Xapian - Xapian Model Component

=head1 SYNOPSIS

    Very simple to use

=head1 DESCRIPTION

Very nice component.

=head1 AUTHOR

Clever guy

=head1 LICENSE

This library is free software . You can redistribute it and/or modify it under
the same terms as perl itself.

=cut

1;
