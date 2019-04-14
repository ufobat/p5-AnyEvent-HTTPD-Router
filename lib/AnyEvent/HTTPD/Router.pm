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
 );

 $httpd->run();

=head1 METHODS

=over

=item * C<new()>

=item * C<reg_routes()>

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

There are various different Router Implementations that you could use in your own Route Dispatcher.

=over

=item C<HTTP::Router>

=item .... TODO

=back

=head1 LICENSE

Copyright (C) Martin Barth.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

=over

=item * Martin Barth E<lt>martin@senfdax.deE<gt>

=item * Paul Koschinski

=back

=cut
