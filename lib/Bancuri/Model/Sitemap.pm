package Bancuri::Model::Sitemap;

use strict;
use warnings;
use parent 'Catalyst::Model';

use URI;
use DateTime;
use Search::Sitemap;
use Data::Dump qw(pp);

=head1 NAME

Bancuri::Model::Sitemap - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=item2 update

Sitemap file update. Reqires these arguments:
- sitemap_file, path to sitemap.xml.gz file
- base_url, e.g. http://www.bancuri.com/
- schema, schema object

=cut

sub update {
    my ($self, %args) = @_;
  
    my $sitemap_file = $args{'sitemap_file'}->stringify;
    my $url = URI->new( $args{'base_url'} );
    my $schema = $args{'schema'};

    my $map = Search::Sitemap->new();
    $map->read( $sitemap_file );
  
    # Main page, changes daily
    $map->add( Search::Sitemap::URL->new(
        loc        => $args{'base_url'},
        lastmod    => DateTime->now->ymd,
        changefreq => 'daily',
        priority   => 1.0,
    ) );

    my $jokes = $schema->resultset('Joke')->search_not_deleted->search_clean;

    while ( my $joke = $jokes->next ) {
        $url->path($joke->link);
        
        # Jokes don't change as much, and have a lower priority
        $map->add( {
            loc        => $url->as_string(),
            changefreq => 'weekly',
            priority   => 0.9, # lower priority than the home page
        } );
    };
  
    $map->write( $sitemap_file );
}


=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
