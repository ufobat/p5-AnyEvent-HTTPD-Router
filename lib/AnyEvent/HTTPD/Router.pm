package AnyEvent::HTTPD::Router;

use common::sense;
use parent 'AnyEvent::HTTPD';

use AnyEvent::HTTPD;
use Carp;

use AnyEvent::HTTPD::Router::DefaultDispatcher;
our $VERSION = '0.0.1';

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my %args  = @_;


    # todo documentation how to overwrite your dispathing
    my $dispatcher       = delete $args{dispatcher};
    my $dispatcher_class = delete $args{dispatcher_class}
        || 'AnyEvent::HTTPD::Router::DefaultDispatcher';

    my $self = $class->SUPER::new(%args);

    $self->{dispatcher}  = defined $dispatcher
        ? $dispatcher
        : $dispatcher_class->new();

    $self->reg_cb(
        'request' => sub {
            my $self = shift;
            my $req  = shift;
            my $matched = $self->dispatcher->match( $self, $req );
        },
    );

    if ($args{routes}) {
        $self->reg_routes( @{ $args{routes} } );
    }

    return $self;
}

sub dispatcher { shift->{dispatcher} }

sub reg_routes {
    my $self = shift;

    croak 'arguemnts to reg_routes are required' if @_ == 0;
    croak 'arguments to reg_routes are confusing' if @_ % 3 != 0;
    while (my ($verbs, $path, $cb) = splice(@_, 0, 3) ) {
        $self->dispatcher->add_route($verbs, $path, $cb);
    }

    # TODO need to get http methods into allowed methods
    # from routes
}

1;

