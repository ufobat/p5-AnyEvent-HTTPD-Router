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
    my $routes           = delete $args{routes};
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

    if ($routes) {
        $self->reg_routes( @$routes );
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

__END__

=encoding utf-8

=head1 NAME

AnyEvent::HTTPD::Router - Adding Routes to AnyEvent::HTTPD

=head1 DESCRIPTION

todo motivation = wenige abhaengigkeiten, schnell, einfach, erweiterbar

=head1 SYNOPSIS

 use AnyEvent::HTTPD::Router;

 my $httpd       = AnyEvent::HTTPD::Router->new( port => 1337 );
 my $all_methods = [qw/GET DELETE HEAD POST PUT PATCH/];

 $httpd->reg_routes(
     GET => '/index.txt' => sub {
         my ( $httpd, $req ) = @_;
         $httpd->stop_request;
         $req->respond([ 200, 'ok', { 'Content-Type' => 'text/plain', }, "test!" ] );
     },
     $all_methods => '/my-method' => sub {
         my ( $httpd, $req ) = @_;
         $httpd->stop_request;
         $req->respond([ 200, 'ok', { 'X-Your-Method' => $req->method }, '' ]);
     },
     GET => '/calendar/:year/:month/:day' => sub {
         my ( $httpd, $req, $param ) = @_;
         my $calendar_entries = get_cal_entries($param->{year}, $param->{month}, $param->{day});

         $httpd->stop_request;
         $reg->respond([ 200, 'ok', { 'Content-Type' => 'application/json'}, to_json($calendar_entries)]);
     },
     GET => '/static-files/*' => sub {
         my ( $httpd, $req, $param ) = @_;
         my $requeted_file = $param->{'*'};
         my ($content, $content_type) = black_magic($requested_file);

         $httpd->stop_request;
         $req->respond([ 200, 'ok', { 'Content-Type' => $content_type }, $content ]);
     }
 );

 $httpd->run();

=head1 METHODS

=over

=item * C<new()>

Creates a new C<AnyEvent::HTTP::Router> server. The constructor handles following parameters. All further parameters are passed to C<AnyEvent::HTTPD>.

=over

=item * C<dispatcher>

You can pass your own implementation of your router dispatcher into this Module. This expects the dispatcher to be an instance not a class name.

=item * C<dispatcher_class>

You can pass your own implementation of your router dispatcher into this Module. This expects the dispatcher to be a class name.

=item * C<routes>

You can add the routes at the constructor. This is an ArrayRef.

=back

=item * C<reg_routes()>

You can add further routes with this method.

=item * C<*>

C<AnyEvent::HTTPD::Router> subclasses C<AnyEvent::HTTPD> so you can use all methods the parent class.

=back

=head1 WRITING YOUR OWN ROUTE DISPATCHER

TODO

=head1 SEE ALSO

=over

=item * L<AnyEvent>

=item * L<AnyEvent::HTTPD>

=back

There are a lot of HTTP Router modules in CPAN:

=over

=item * L<HTTP::Router>

=item * L<Router::Simple>

=item * L<Router::R3>

=item * L<Router::Boom>

=back

=head1 LICENSE

Copyright (C) Martin Barth.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 CONTRIBUTORS

=over

=item Paul Koschinski

=back

=head1 AUTHOR

Martin Barth (ufobat)

=cut
