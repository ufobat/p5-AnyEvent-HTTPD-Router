package AnyEvent::HTTPD::Router;

use common::sense;
use AnyEvent::HTTPD;
use Carp;

use parent 'AnyEvent::HTTPD';
our $VERSION = '0.0.1';

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my %args  = @_;

    # todo documentation how to overwrite your dispathing
    my $dispatcher       = delete $args{dispatcher};
    my $dispatcher_class = delete $args{dispatcher_class};
    my $self             = $class->SUPER::new(%args);
    $self->{dispatcher}  = defined $dispatcher
        ? $dispatcher
        : $dispatcher_class->new();


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

    # TODO bless
    return $self;
}

sub dispatcher {
    my $self = shift;
    $self->{dispatcher} = shift if @_ == 1;
    return $self->{dispatcher};
}

sub reg_routes {
    my $self = shift;
    my $route_class = $self->{route_class};
    croak 'arguments to reg_routes are confusing' if @_ % 3 != 0;
    while (my ($verbs, $path, $cb) = splice(@_, 0, 3) ) {
        $self->dispatcher->add_route($verbs, $path, $cb);
    }
}

sub dispatch_requests {
    my $self    = shift;
    my $req     = shift;
    my $matched = $self->dispatcher->match( $req );

    unless ($matched) {
        # TODO document not_found event
        $self->event(not_found => $req);
    }
}

1;

