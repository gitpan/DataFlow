package DataFlow::Node::NOP;

#ABSTRACT: A No-Op node, input data is passed unmodified to the output

use strict;
use warnings;

our $VERSION = '0.91.06';    # VERSION

use Moose;
extends 'DataFlow::Node';

has '+process_item' => (
    default => sub {
        return sub { shift; my $item = shift; return $item; }
    },
);

__PACKAGE__->meta->make_immutable;

1;

=pod

=head1 NAME

DataFlow::Node::NOP - A No-Op node, input data is passed unmodified to the output

=head1 VERSION

version 0.91.06

=head1 SYNOPSIS

    use DataFlow::NOP;

    my $nop = DataFlow::Node::NOP->new;

    my $result = $nop->process( 'abc' );
    # $result == 'abc'

=head1 DESCRIPTION

This class represents a no-op node: the very input is passed without
modifications to the output.

This class is more useful as parent class than by itself.

=head1 NAME

DataFlow::Node::NOP - A No-Op node, input data is passed unmodified to the output

=head1 METHODS

The interface for C<DataFlow::Node::NOP> is the same of
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
