package Bancuri::Wiki;

use strict;
use warnings;

our $VERSION = '0.01';

sub new {
	my ($class, %args) = @_;	
    warn "@_\n";

	my $self = {};
	bless $self, $class;
	
	return $self;	
}

1;
