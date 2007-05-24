package Bancuri::Controller::Edit;

use strict;
use warnings;
use base 'Catalyst::Controller';

use Data::Dumper;
use constant REQUIRES_MODERATION => 1;

=head1 NAME

Bancuri::Controller::Edit - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 edit 

=cut

sub edit : Chained('/wiki') PathPart('edit') Args(0) {
	my ( $self, $c ) = @_;
	my $wiki = $c->stash->{'wiki'};
	my $node = $c->stash->{'node'};

	if ( $c->req->method() eq 'GET' ) {
		$c->stash->{'template'} = 'edit.html';
		my %node_data = $wiki->retrieve_node($node);

		$c->stash(
			title => 'Editeaza banc',
			raw => $node_data{'content'},
			checksum => $node_data{'checksum'},
			last_modified => $node_data{'last_modified'},
			version => $node_data{'version'},
			metadata => Dumper $node_data{'metadata'},
		);
		$c->forward(qw/Bancuri::Controller::Moderate/);
	}
	elsif ( $c->req->method() eq 'POST' ) {
		my %actions = (
			preview => 'preview',
			save 	=> 'save',
			cancel 	=> 'redir_show',
		);
		for my $a ( keys %actions ) {
			$c->forward($actions{$a}) if $c->req->params->{$a};
		}
	}
}

sub preview : Private {
	my ( $self, $c ) = @_;
	my $wiki = $c->stash->{'wiki'};
	
	$c->stash->{'template'} = 'preview.html';
    my $raw = $c->req->params->{'raw'};
    my $cooked = $wiki->format($raw);
	# my $ok = $wiki->verify_checksum($node, $checksum);
    $c->stash( 
    	raw => $raw, 
    	text => $cooked,
    	checksum => $c->req->params->{'checksum'},
    );
}

sub save : Private {
	my ( $self, $c ) = @_;
	my $wiki = $c->stash->{'wiki'};
	my $node = $c->stash->{'node'};

	my $raw = $c->req->params->{'raw'};
	my $checksum = $c->req->params->{'checksum'};
	my $written = $wiki->write_node($node, $raw, $checksum, { username => 'vio' }, 1 );
	if ( $written ) {
		$c->forward('redir_show');
	}
	else {
		$c->log->info("CONFLICT!!!");
	}
}

sub redir_show : Private {
	my ( $self, $c ) = @_;
	my $node = $c->stash->{'node'};
	$c->response->redirect( q{/} . $node, 303 );
}

=head1 AUTHOR

Viorel,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
