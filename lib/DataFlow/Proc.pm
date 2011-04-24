package DataFlow::Proc;

use strict;
use warnings;

# ABSTRACT: A data processor class

our $VERSION = '1.111140'; # VERSION

use Moose;
with 'DataFlow::Role::Dumper';

use namespace::autoclean;
use DataFlow;
use DataFlow::Role::TypePolicy;

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

subtype '_TypePolicy' => as 'DataFlow::Role::TypePolicy';
coerce '_TypePolicy' => from 'Str' => via { _make_typepolicy($_) };

sub _make_typepolicy {
    my $class = 'DataFlow::TypePolicy::' . shift;
    my $obj;
    eval 'use ' . $class . '; $obj = ' . $class . '->new()';    ## no critic
    die $@ if $@;
    return $obj;
}

has 'name' => (
    'is'        => 'ro',
    'isa'       => 'Str',
    'predicate' => 'has_name',
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

has 'type_policy' => (
    'is'       => 'ro',
    'does'     => '_TypePolicy',
    'coerce'   => 1,
    'required' => 1,
    'lazy'     => 1,
    'default'  => sub {
        my $self = shift;
        return $self->process_into ? 'ProcessInto' : 'Scalar';
    },
);

has 'p' => (
    'is'       => 'ro',
    'isa'      => 'Processor',
    'required' => 1,
    'coerce'   => 1,
    'documentation' =>
      'Code reference that returns the result of processing one single item',
);

sub _process {
    my ( $self, $item ) = @_;
    return $self->type_policy->apply( $self->p, $item );
}

sub _deref {
    my $value = shift;
    my $ref = reftype($value) || '';
    return ${$value}  if $ref eq 'SCALAR';
    return @{$value}  if $ref eq 'ARRAY';
    return %{$value}  if $ref eq 'HASH';
    return $value->() if $ref eq 'CODE';
    return $value;
}

sub process_one {
    my ( $self, $item ) = @_;

    $self->prefix_dumper( $self->has_name ? $self->name . ' <<' : '<<', $item )
      if $self->dump_input;
    return () unless ( $self->allows_undef_input || defined($item) );

    my @result =
      $self->deref
      ? map { _deref($_) } ( $self->_process($item) )
      : $self->_process($item);

    $self->prefix_dumper( $self->has_name ? $self->name . ' >>' : '>>',
        @result )
      if $self->dump_output;
    return @result;
}

__PACKAGE__->meta->make_immutable;

1;



=pod

=encoding utf-8

=head1 NAME

DataFlow::Proc - A data processor class

=head1 VERSION

version 1.111140

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

[Bool] It controls whether C<< $self->p->() >> will accept C<undef> as input
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
C<< $self->p->() >> over the item.

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


