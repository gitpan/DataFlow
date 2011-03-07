package DataFlow::Node::URLRetriever::Get::Curl;

#ABSTRACT: A HTTP Getter implementation using Curl

use strict;
use warnings;

our $VERSION = '0.91.06';    # VERSION

use Moose::Role;
use LWP::Curl;

sub _make_obj {
    return LWP::Curl->new;
}

1;

__END__

=pod

=head1 NAME

DataFlow::Node::URLRetriever::Get::Curl - A HTTP Getter implementation using Curl

=head1 VERSION

version 0.91.06

=head1 AUTHOR

Alexei Znamensky <russoz@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Alexei Znamensky.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
