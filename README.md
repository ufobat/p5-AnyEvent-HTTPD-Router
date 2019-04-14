[![Build Status](https://travis-ci.org/ufobat/p5-AnyEvent-HTTTPD-Router.svg?branch=master)](https://travis-ci.org/ufobat/p5-AnyEvent-HTTTPD-Router)
# NAME

AnyEvent::HTTPD::Router - Adding Routes to AnyEvent::HTTPD

# DESCRIPTION

todo motivation = wenige abhaengigkeiten, schnell, einfach, erweiterbar

# SYNOPSIS

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

# METHODS

- `new()`

    Creates a new `AnyEvent::HTTP::Router` server. The constructor handles following parameters. All further parameters are passed to `AnyEvent::HTTPD`.

    - `dispatcher`

        You can pass your own implementation of your router dispatcher into this Module. This expects the dispatcher to be an instance not a class name.

    - `dispatcher_class`

        You can pass your own implementation of your router dispatcher into this Module. This expects the dispatcher to be a class name.

    - `routes`

        You can add the routes at the constructor. This is an ArrayRef.

- `reg_routes()`

    You can add further routes with this method.

- `*`

    `AnyEvent::HTTPD::Router` subclasses `AnyEvent::HTTPD` so you can use all methods the parent class.

# WRITING YOUR OWN ROUTE DISPATCHER

TODO

# SEE ALSO

- [AnyEvent](https://metacpan.org/pod/AnyEvent)
- [AnyEvent::HTTPD](https://metacpan.org/pod/AnyEvent::HTTPD)

There are a lot of HTTP Router modules in CPAN:

- [HTTP::Router](https://metacpan.org/pod/HTTP::Router)
- [Router::Simple](https://metacpan.org/pod/Router::Simple)
- [Router::R3](https://metacpan.org/pod/Router::R3)
- [Router::Boom](https://metacpan.org/pod/Router::Boom)

# LICENSE

Copyright (C) Martin Barth.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

- Martin Barth (ufobat)
- Paul Koschinski
