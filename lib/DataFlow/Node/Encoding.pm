package DataFlow::Node::Encoding;

#ABSTRACT: A encoding conversion node

use strict;
use warnings;

our $VERSION = '0.91.04';    # VERSION

use Moose;
extends 'DataFlow::Node';

use Encode;

has 'input_encoding' => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_input_encoding',
);

has 'output_encoding' => (
    is        => 'ro',
    isa       => 'Str',
    predicate => 'has_output_encoding',
);

has '+process_item' => (
    default => sub {
        return sub {
            my ( $me, $item ) = @_;
            return $item unless ref($item) ne '';
            my $data =
              $me->has_input_encoding
              ? decode( $me->input_encoding, $item )
              : $item;
            return $me->has_output_encoding
              ? encode( $me->output_encoding, $data )
              : $data;
          }
    },
);

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

DataFlow::Node::Encoding - A encoding conversion node

=head1 VERSION

version 0.91.04

=head1 AUTHOR

Alexei Znamensky <russoz@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Alexei Znamensky.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
