package DataFlow::Proc;

use strict;
use warnings;

# ABSTRACT: A data processor class

our $VERSION = '1.111010'; # VERSION

use Moose;
with 'DataFlow::Role::Dumper';

use DataFlow;

use Moose::Util::TypeConstraints 1.01;
use Scalar::Util qw/blessed reftype/;

subtype 'Processor' => as 'CodeRef';
coerce 'Processor' => from 'DataFlow::Proc' => via {
    my $p = $_;
    return sub { $p->process_one(shift) };
};
coerce 'Processor' => from 'DataFlow' => via {
    my $f = $_;
    return sub { $f->process(shift) };
};

has 'name' => (
    'is'  => 'ro',
    'isa' => 'Str',
);

has 'allows_undef_input' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'lazy'    => 1,
    'default' => 0,
);

has 'deref' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'lazy'    => 1,
    'default' => 0,
);

has 'process_into' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'lazy'    => 1,
    'default' => 1,
);

has 'dump_input' => (
    'is'            => 'ro',
    'isa'           => 'Bool',
    'lazy'          => 1,
    'default'       => 0,
    'documentation' => 'Prints a dump of the input load to STDERR',
);

has 'dump_output' => (
    'is'            => 'ro',
    'isa'           => 'Bool',
    'lazy'          => 1,
    'default'       => 0,
    'documentation' => 'Prints a dump of the output load to STDERR',
);

has 'p' => (
    'is'       => 'ro',
    'isa'      => 'Processor',
    'required' => 1,
    'coerce'   => 1,
    'documentation' =>
      'Code reference that returns the result of processing one single item',
);

sub process_one {
    my ( $self, $item ) = @_;

    $self->prefix_dumper( '>>', $item ) if $self->dump_input;
    return unless ( $self->allows_undef_input || defined($item) );

    my @result = $self->_handle($item);
    $self->prefix_dumper( '<<', @result ) if $self->dump_output;

    return @result if wantarray;

    confess('Multiple values in result for a scalar context') if $#result > 0;
    return $result[0];
}

##############################################################################
# code to handle different types of input
#   ex: array-refs, hash-refs, code-refs, etc...

sub _param_type {
    my $p = shift;
    my $r = reftype($p);
    return 'SVALUE' unless $r;
    return 'OBJECT' if blessed($p);
    return $r;
}

sub _handle {
    my ( $self, $item ) = @_;

    my $type = _param_type($item);
    confess('There is no handler for this parameter type!')
      unless exists $self->_handlers->{$type};
    my @result = $self->_handlers->{$type}->( $self->p, $item );
    return @result;
}

##############################################################################
#
#  _handlers
#
#  _handlers is a hash reference, with reference types (and some other special
#  strings) as keys, and code references (a.k.a. handlers) as values.
#
#  For each key, a handler will be defined taking into account whether this
#  processor has process_into == 1 and/or deref == 1.
#

has '_handlers' => (
    'is'      => 'ro',
    'isa'     => 'HashRef[CodeRef]',
    'lazy'    => 1,
    'default' => sub {
        my $me           = shift;
        my $type_handler = {
            'SVALUE' => \&_handle_svalue,
            'OBJECT' => \&_handle_svalue,
            'SCALAR' => $me->process_into ? \&_handle_scalar_ref
            : \&_handle_svalue,
            'ARRAY' => $me->process_into ? \&_handle_array_ref
            : \&_handle_svalue,
            'HASH' => $me->process_into ? \&_handle_hash_ref : \&_handle_svalue,
            'CODE' => $me->process_into ? \&_handle_code_ref : \&_handle_svalue,
        };
        return $type_handler unless $me->deref;

        return {
            'SVALUE' => sub { return $type_handler->{'SVALUE'}->(@_) },
            'OBJECT' => sub { return $type_handler->{'OBJECT'}->(@_) },
            'SCALAR' => sub { return ${ $type_handler->{'SCALAR'}->(@_) } },
            'ARRAY'  => sub { return @{ $type_handler->{'ARRAY'}->(@_) } },
            'HASH'   => sub { return %{ $type_handler->{'HASH'}->(@_) } },
            'CODE'   => sub { return $type_handler->{'CODE'}->(@_)->() },
        };
    },
);

sub _handle_svalue {
    my ( $p, $item ) = @_;
    return $p->($item);
}

sub _handle_scalar_ref {
    my ( $p, $item ) = @_;
    my $r = $p->($$item);
    return \$r;
}

sub _handle_array_ref {
    my ( $p, $item ) = @_;

    #use Data::Dumper; warn 'handle_array_ref :: item = ' . Dumper($item);
    my @r = map { $p->($_) } @{$item};
    return [@r];
}

sub _handle_hash_ref {
    my ( $p, $item ) = @_;
    my %r = map { $_ => $p->( $item->{$_} ) } keys %{$item};
    return {%r};
}

sub _handle_code_ref {
    my ( $p, $item ) = @_;
    return sub { $p->( $item->() ) };
}

__PACKAGE__->meta->make_immutable;
no Moose::Util::TypeConstraints;
no Moose;

1;



=pod

=encoding utf-8

=head1 NAME

DataFlow::Proc - A data processor class

=head1 VERSION

version 1.111010

=head1 SYNOPSIS

	use DataFlow::Proc;

	my $uc = DataFlow::Proc->new(
		p => sub {
			return uc(shift);
		}
	);

	my @res = $uc->process_one( 'something' );
	# @res == qw/SOMETHING/;

	my @res = $uc->process_one( [qw/aaa bbb ccc/] );
	# @res == [qw/AAA BBB CCC/];

Or

	my $uc_deref = DataFlow::Proc->new(
		deref => 1,
		p     => sub {
			return uc(shift);
		}
	);

	my @res = $uc_deref->process_one( [qw/aaa bbb ccc/] );
	# @res == qw/AAA BBB CCC/;

=head1 DESCRIPTION

This is a L<Moose> based class that provides the idea of a processing step in
a data-flow.  It attemps to be as generic and unassuming as possible, in order
to provide flexibility for implementors to make their own specialized
processors as they see fit.

Apart from atribute accessors, an object of the type C<DataFlow::Proc> will
provide only a single method, C<process_one()>, which will process a single
scalar.

=head1 ATTRIBUTES

=head2 name

[Str] A descriptive name for the dataflow. (OPTIONAL)

=head2 allows_undef_input

[Bool] It controls whether C<$self->p->()> will be handed C<undef> as input
or if DataFlow::Proc will filter those out. (DEFAULT = false)

=head2 deref

[Bool] Signals whether the result of the processing will be de-referenced
upon output or if DataFlow::Proc will preserve the original reference.
(DEFAULT = false)

=head2 process_into

[Bool] It signals whether this processor will attempt to process data within
references or not. If process_into is true, then C<process_item> will be
applied into the values referenced by any scalar, array or hash reference and
onto the result of running any code reference.
(DEFAULT = true)

=head2 dump_input

[Bool] Dumps the input parameter to STDERR before processing. See
L<DataFlow::Role::Dumper>. (DEFAULT = false)

=head2 dump_output

[Bool] Dumps the results to STDERR after processing. See
L<DataFlow::Role::Dumper>. (DEFAULT = false)

=head2 p

[CodeRef] The actual work horse for this class. It is treated as a function,
not as a method, as in:

	my $proc = DataFlow::Proc->new(
		p => sub {
			my $data = shift;
			return ucfirst($data);
		}
	);

It only makes sense to access C<$self> when one is sub-classing DataFlow::Proc
and adding new attibutes or methods, in which case one can do as below:

	package MyProc;

	use Moose;
	extends 'DataFlow::Proc';

	has 'x_factor' => ( isa => 'Int' );

	has '+p' => (
		default => sub {        # not the p value, but the sub that returns it
			my $self = shift;
			return sub {
				my $data = shift;
				return $data * int( rand( $self->x_factor ) );
			};
		},
	);

	package main;

	my $proc = MyProc->new( x_factor => 5 );

This sub will be called in array context. There is no other restriction on
what this code reference can or should do. (REQUIRED)

=head1 METHODS

=head2 process_one

Processes one single scalar (or anything else that can be passed in on scalar,
such as references or globs), and returns the application of the function
C<$self->p->()> over the item.

=head1 DEPENDENCIES

L<Scalar::Util>

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


