package DataFlow::Node::Dumper;

#ABSTRACT: A debugging node that will dump data to STDERR

use strict;
use warnings;

our $VERSION = '0.91.06';    # VERSION

use Moose;
extends 'DataFlow::Node';

use Data::Dumper;

has '+process_item' => (
    default => sub {
        return sub {
            my ( $self, $item ) = @_;
            $self->raw_dumper($item);
            return $item;
          }
    }
);

__PACKAGE__->meta->make_immutable;

1;

=pod

=head1 NAME

DataFlow::Node::Dumper - A debugging node that will dump data to STDERR

=head1 VERSION

version 0.91.06

=head1 SYNOPSIS

    use DataFlow::Dumper;

    my $nop = DataFlow::Node::Dumper->new;

    my $result = $nop->process( 'abc' );
    # $result == undef

=head1 DESCRIPTION

Dumper node. Every item passed to its input will be printed in the C<STDERR>
file handle, using L<Data::Dumper>.

=head1 NAME

DataFlow::Node::Dumper - Dumper node, will print every input item to STDERR with Data::Dumper

=head1 METHODS

The interface for C<DataFlow::Node::Dumper> is the same of
C<DataFlow::Node>.

=head1 DEPENDENCIES

L<Data::Dumper>

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
