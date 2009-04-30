package Bancuri::Controller::Role::Response;
use Moose::Role;

sub redirect {
    my ( $self, $c, $url, $status ) = @_;
    
	unless ( $url =~ m{^https?://} ) {
	   $url = $c->uri_for( $url );
	};

    unless ( $status ) {
        my $method = $c->request->method;
        if ( $method eq 'GET' ) {
            $status = 301; # Moved Permanently
        }
        elsif ( $method eq 'POST' ) {
            $status = 303; # See Other
        }
        else {
            $status = 302; # Temporary Redirect
        }
    }    
    
	$c->response->redirect( $url, $status );
	$c->detach();
}

1