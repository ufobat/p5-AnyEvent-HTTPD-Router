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
- `reg_routes()`
- `*`

    `AnyEvent::HTTPD::Router` subclasses `AnyEvent::HTTPD` so you can use all methods the parent class.

# WRITING YOUR OWN ROUTE DISPATCHER

TODO

# SEE ALSO

- [AnyEvent](https://metacpan.org/pod/AnyEvent)
- [AnyEvent::HTTPD](https://metacpan.org/pod/AnyEvent::HTTPD)

There are various different Router Implementations that you could use in your own Route Dispatcher.

- `HTTP::Router`
- .... TODO

# LICENSE

Copyright (C) Martin Barth.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

# AUTHOR

- Martin Barth <martin@senfdax.de>
- Paul Koschinski
