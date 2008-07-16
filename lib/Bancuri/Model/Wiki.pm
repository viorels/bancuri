package Bancuri::Model::Wiki;

use strict;
use warnings;
use base 'Catalyst::Model';

use Bancuri::Wiki;

=head1 NAME

Bancuri::Model::Wiki - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->mk_accessors( 'dbh' ); 

sub ACCEPT_CONTEXT {
	my ($self, $c, @args) = @_; 
	
	#$self->{'dbh'} = $c->model('DBI')->dbh;
	my $new = bless({ %$self }, ref $self);

	$new->dbh($c); 	

	#return $self;
	return $new;
}

sub new { # would be quite sufficient !!!
	my ($class, $c, $args) = @_;
	return Bancuri::Wiki->new(
		Catalyst::Utils::merge_hashes( $args, $class->config )
	);
}

sub get_best {
	return "This is the best";	
}

1;
