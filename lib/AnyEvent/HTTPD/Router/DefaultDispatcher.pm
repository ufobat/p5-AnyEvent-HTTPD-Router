package AnyEvent::HTTPD::Router::DefaultDispatcher;

use common::sense;
use Carp;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = {
        routes => {}
    };

    return bless $class, $self;
}

sub add_routes {
    my $self  = shift;
    my $verbs = shift;
    my $path  = shift;
    my $cb    = shift;

    unless (exists $self->{routes}->{$path}) {
        my @segments = split /\//, $path;
        $self->{routes}->{$path} = {
            seqments  => \@seqments, # something to improve speed
            callbacks => {},         # method/path => cb mapping
        };
    }

    my $NEED_A_NAME = $self->{routes}->{$path};

    $verbs = ref($verbs) eq 'ARRAY' ? $verbs  : [ $verbs ];
    foreach my $verb (@$verbs) {
        $NEED_A_NAME->{callbacks}->{$verb} = $cb;
    }
}

# TODO doku:
# if you subclass AnyEvent::HTTPD::Request
# you might need to change the match code.
sub match {
    my $self = shift;
    my $req  = shift;
    my $matched = 0;
    my @path   = $req->url->path_segments;
    my $method = $req->method;

    # TODO: is that correct?
    # accept verb only for GET and POST
    if ($method eq 'GET' or $method eq 'POST') {
        if (@path[-1] =~ s/:(\w+)$//) { # TODO regex for verbs
            $method = $1
        }
    }

    # sort because we want to have reproducable
    # behaviour for match
    foreach my $path (keys %{ $self->{routes} }) {
        my $NEED_A_NAME = $self->{routes}->{$path};
        # step 1: match the paths
        if (my %variables = _match_paths(\@path, $NEED_A_NAME->seqments)) {
            if (exists $NEED_A_NAME->{callbacks}->{$method}) {
                my $cb = $NEED_A_NAME->{callbacks}->{$method};
                $matched = 1;
                $cb->($req, \%variables);
                last;
            }
        }
    }
    return $matched;
}

sub _match_path {
    my $request_path_seq;
    my $routing_path_seq;

    my $request_seq;
    my $routing_seq;
    my %variables;

    while (@$request_path_seq) {
        $request_seq = shift @$request_path_seq; # always defined
        $routing_seq = shift @$routing_path_seq; # maybe undef

        # TODO not sure if we need to do that explicty, (same as else)
        # PK: we get a lot of warnings otherwise 
        if (not defined $routing_seq) {
            return;
        }
        
        if ($routing_seq eq '*') {
            # done with all matching,
            # * slurps all the $request_seq that still might come
            return \%variables
        } elsif ($routing_seq eq $request_seq) {
            # go on with matching
        } elsif ($routing_seq =~ m/^\:(.+)$/) {
            # remember the variable
            my $var_name = $1;
            $variables{$var_name} = $request_seq;
        } else {
            # mismatch
            return;
        }
    }

    return \%variables;
}

1;
