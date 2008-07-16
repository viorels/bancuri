package Bancuri::Wiki;

use strict;
use warnings;

our $VERSION = '0.01';

sub new {
	my ($class, %args) = @_;	

	my $self = {};
	bless $self, $class;
	
	return $self;	
}

1;
