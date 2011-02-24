package DataFlow::Node::URLRetriever::Get::Mechanize;

#ABSTRACT: A HTTP Getter implementation using WWW::Mechanize

use strict;
use warnings;

our $VERSION = '0.91.04';    # VERSION

use Moose::Role;

use WWW::Mechanize;

sub _make_obj {
    my $self = shift;
    return WWW::Mechanize->new(
        agent   => $self->agent,
        onerror => sub { $self->confess(@_) },
        timeout => $self->timeout
    );
}

sub _content {
    my ( $self, $response ) = @_;

    #print STDERR "mech _content\n";
    return $response->content;
}

1;

__END__

=pod

=head1 NAME

DataFlow::Node::URLRetriever::Get::Mechanize - A HTTP Getter implementation using WWW::Mechanize

=head1 VERSION

version 0.91.04

=head1 AUTHOR

Alexei Znamensky <russoz@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Alexei Znamensky.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
