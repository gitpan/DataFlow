package DataFlow::Chain;

use strict;
use warnings;

# ABSTRACT: A "super-node" that can link a sequence of nodes
# ENCODING: utf8

our $VERSION = '0.91.10';    # VERSION

use Moose;
extends 'DataFlow::Node';

use DataFlow::Node;
use List::Util qw/reduce/;

has 'links' => (
    'is'       => 'ro',
    'isa'      => 'ArrayRef[DataFlow::Node]',
    'required' => 1,
);

sub _first_link { return shift->links->[0] }
sub _last_link  { return shift->links->[-1] }

has '+process_item' => (
    'default' => sub {
        return sub {
            my ( $self, $item ) = @_;

            #use Data::Dumper;
            #warn 'chain          = '.Dumper($self);
            #warn 'chain :: links = '.Dumper($self->links);
            $self->confess('Chain has no nodes, cannot process_item()')
              unless scalar @{ $self->links };

            $self->_first_link->input($item);
            return $self->_reduce->output;
        },;
    },
);

sub _reduce {
    return reduce {
        $a->process_input;

        # always flush the output queue
        $b->input( $a->output );
        $b;
    }
    @{ shift->links };
}

override 'process_input' => sub {
    my $self = shift;
    return unless ( $self->has_input || $self->_chain_has_data );

    # empty existing data in the pipe
    while ( $self->_chain_has_data ) {
        my $last = $self->_reduce;
        $self->_add_output( $last->output );
    }

    unless ( $self->has_output ) {
        my $item = $self->_dequeue_input;
        $self->_add_output( $self->_handle_list($item) );
    }
};

sub _chain_has_data {
    return 0 != scalar( grep { $_->has_input } @{ shift->links } );
}

before 'flush' => sub {
    my $self = shift;
    $self->_first_link->input( $self->_dequeue_input );
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;

=pod

=encoding utf8

=head1 NAME

DataFlow::Chain - A "super-node" that can link a sequence of nodes

=head1 VERSION

version 0.91.10

=head1 SYNOPSIS

    use DataFlow::Node;
    use DataFlow::Chain;

    my $chain = DataFlow::Chain->new(
        links => [
            DataFlow::Node->new(
                process_item => sub {
                    shift; return uc(shift);
                }
            ),
            DataFlow::Node->new(
                process_item => sub {
                    shift; return reverse shift ;
                }
            ),
        ],
    );

    my $result = $chain->process( 'abc' );
    # $result == 'CBA'

=head1 DESCRIPTION

This is a L<Moose> based class that provides the idea of a chain of steps in
a data-flow.
One might think of it as the actual definition of the data flow, but this is a
limited, linear, flow, and there is room for a lot of improvements.

A C<DataFlow::Chain> object accepts input like a regular
C<DataFlow::Node>, but it injects that input into the first link of the
chain, and pumps the output of each link into the input of the next one,
similarly to pipes in a shell command line. The output of the last link of the
chain will be used as the output of the entire chain.

=head1 DEPENDENCIES

L<DataFlow::Node>

L<List::Util>

=head1 AUTHOR

Alexei Znamensky <russoz@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Alexei Znamensky.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests through the web interface at
L<http://github.com/russoz/DataFlow/issues>.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit L<http://www.perl.com/CPAN/> to find a CPAN
site near you, or see L<http://search.cpan.org/dist/DataFlow/>.

The development version lives at L<http://github.com/russoz/DataFlow>
and may be cloned from L<git://github.com/russoz/DataFlow.git>.
Instead of sending patches, please fork this project using the standard
git and github infrastructure.

=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT
WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER
PARTIES PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND,
EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE. THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE
SOFTWARE IS WITH YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME
THE COST OF ALL NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE LIABLE
TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL, OR
CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE
SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES.

=cut

__END__