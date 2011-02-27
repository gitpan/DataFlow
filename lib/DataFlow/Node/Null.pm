package DataFlow::Node::Null;

#ABSTRACT: A null node, will discard any input and return undef in the output

use strict;
use warnings;

our $VERSION = '0.91.05';    # VERSION

use Moose;
extends 'DataFlow::Node::NOP';

override 'input' => sub { };

__PACKAGE__->meta->make_immutable;

1;

=pod

=head1 NAME

DataFlow::Node::Null - A null node, will discard any input and return undef in the output

=head1 VERSION

version 0.91.05

=head1 SYNOPSIS

    use DataFlow::Null;

    my $null = DataFlow::Node::Null->new;

    my $result = $null->process( 'abc' );
    # $result == undef

=head1 DESCRIPTION

This class represents a null node: it will return undef regardless of any input
provided to it.

=head1 NAME

DataFlow::Node::Null - A null node, will discard any input and return undef in the output

=head1 METHODS

The interface for C<DataFlow::Node::Null> is the same of
C<DataFlow::Node>.

=head1 DEPENDENCIES

L<DataFlow::Node>

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

Please report any bugs or feature requests to
C<bug-dataflow@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

Alexei Znamensky <russoz@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Alexei Znamensky.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

__END__
