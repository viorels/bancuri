package Bancuri::Response;
use Moose;
extends 'Catalyst::Response';

around 'redirect' => sub {
    my $orig = shift;
    my $self = shift;
    my ($location, $status) = @_;
    
    # Behave as an accessor
    return $self->$orig() unless @_;  

    my $method = $self->_context->request->method;
    
    # Set better defaults for response codes
    # http://sebastians-pamphlets.com/the-anatomy-of-http-redirects-301-302-307
    unless ($status) {
        if ($method eq 'GET' or $method eq 'HEAD') {
            $status = 301; # Moved Permanently
        }
        elsif ($method eq 'POST') {
            $status = 303; # See Other (POST-Redirect-GET pattern)
        }
    }

    return $self->$orig($location, $status);
};

1