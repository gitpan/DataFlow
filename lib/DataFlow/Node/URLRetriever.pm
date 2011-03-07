package DataFlow::Node::URLRetriever;

#ABSTRACT: An URL-retriever node

use strict;
use warnings;

our $VERSION = '0.91.06';    # VERSION

use Moose;
extends 'DataFlow::Node';

use DataFlow::Node::URLRetriever::Get;

has _get => (
    is      => 'rw',
    isa     => 'DataFlow::Node::URLRetriever::Get',
    lazy    => 1,
    default => sub { DataFlow::Node::URLRetriever::Get->new }
);

has baseurl => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_baseurl',
);

has '+process_item' => (
    default => sub {
        return sub {
            my ( $self, $item ) = @_;

            #warn 'process_item:: item = '.$item;
            my $url =
              $self->has_baseurl
              ? URI->new_abs( $item, $self->baseurl )->as_string
              : $item;

            #$self->debug("process_item:: url = $url");
            return $self->_get->get($url);
          }
    },
);

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

DataFlow::Node::URLRetriever - An URL-retriever node

=head1 VERSION

version 0.91.06

=head1 AUTHOR

Alexei Znamensky <russoz@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Alexei Znamensky.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
