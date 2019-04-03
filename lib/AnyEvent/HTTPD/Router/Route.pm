package AnyEvent::HTTPD::Router::Route;
use common::sense;

sub new {
    my $this  = shift;
    my $class = ref($this) || $this;
    my $self  = {
        verb     => shift,
        path     => shift,
        callback => shift,
    };

    return bless $class, $self;
}
