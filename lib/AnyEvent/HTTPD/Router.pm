package AnyEvent::HTTPD::Router;

use common::sense;
use AnyEvent::HTTPD;
use Carp;

use parent 'AnyEvent::HTTPD';
our $VERSION = '0.0.1';

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = $class->SUPER::new(
        @_
    );

    $self->req_cb(
        '' => sub {
            my $self = shift;
            my $req  = shift;
            $self->dispatch_requests( $req )
        },
        # not_found event handler here..
        'not_found' => sub {
            my $self = shift;
            my $req  = shift;
            ...
        },
    );

    # TODO set via constructor
    # TODO is //= allowed? minimum perl version?
    $self->{route_class} //= 'AnyEvent::HTTPD::Router::Route';
    $self->{_routes} = [];

    return $self;
}

sub routes {
    my $self = shift;
    return @{ $self->{_routes} };
}

sub reg_routes {
    my $self = shift;
    my $route_class = $self->{route_class};
    croak 'arguments to reg_routes are confusing' if @_ % 3 != 0;
    while (my ($verb, $path, $cb) = splice(@_, 0, 3) ) {
        my $route = $route_class->new($verb, $path, $cb);
        push @{ $self->{_routes} }, $route;
    }
}

sub dispatch_requests {
    my $self    = shift;
    my $req     = shift;
    my $matched = 0;
    # TODO documentation: order of the routes is relevant!!
    foreach my $route ($self->routes) {
        if ($route->match( $req )) {
            $self->event( xxx => $req );
            ++$matched;
            last;
        }
    }
    unless ($matched) {
        # TODO document not_found event
        $self->event(not_found => $req);
    }
}

1;

