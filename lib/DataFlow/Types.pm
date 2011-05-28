package DataFlow::Types;

use strict;
use warnings;

# ABSTRACT: Type definitions for DataFlow

our $VERSION = '1.111480'; # VERSION

use MooseX::Types -declare => [
    qw(ProcessorChain Processor _TypePolicy Encoder Decoder HTMLFilterTypes),
    qw(ConversionSubs ConversionDirection)
];

use namespace::autoclean;

use MooseX::Types::Moose qw/Str CodeRef ArrayRef HashRef/;
class_type 'DataFlow';
class_type 'DataFlow::Proc';
role_type 'DataFlow::Role::TypePolicy';

use Moose::Util::TypeConstraints 1.01;
use Scalar::Util qw/blessed/;
use Encode;

#################### DataFlow ######################

sub _load_class {
    my $str = shift;
    if ( $str =~ m/::/ ) {
        eval "use $str";    ## no critic
        return $str unless $@;
    }
    my $class = "DataFlow::Proc::$str";
    eval "use $class";      ## no critic
    return $class unless $@;
    eval "use $str";        ## no critic
    return $str unless $@;
    die qq{Cannot load class from '$str'};
}

sub _str_to_proc {
    my ( $str, $params ) = @_;
    my $class = _load_class($str);
    my $obj   = eval {
        ( defined($params) and ( ref($params) eq 'HASH' ) )
          ? $class->new($params)
          : $class->new;
    };
    die "$@" if "$@";
    return $obj;
}

# subtypes
subtype 'ProcessorChain' => as 'ArrayRef[DataFlow::Proc]' =>
  where { scalar @{$_} > 0 } =>
  message { 'DataFlow must have at least one processor' };
coerce 'ProcessorChain' => from 'ArrayRef' => via {
    my @list = @{$_};
    my @res  = ();
    while ( my $proc = shift @list ) {
        my $ref = ref($proc);
        if ( $ref eq '' ) {    # String?
            push @res,
              ref( $list[0] ) eq 'HASH'
              ? _str_to_proc( $proc, shift @list )
              : _str_to_proc($proc);
        }
        elsif ( $ref eq 'CODE' ) {
            push @res, DataFlow::Proc->new( p => $proc );
        }
        elsif ( blessed($proc) ) {
            if ( $proc->isa('DataFlow::Proc') ) {
                push @res, $proc;
            }
            elsif ( $proc->isa('DataFlow') ) {
                push @res,
                  DataFlow::Proc->new( p => sub { $proc->process(@_) } );
            }
            else {
                die q{Invalid object (} . $ref
                  . q{) passed instead of a processor};
            }
        }
        else {
            die q{Invalid element (}
              . join( q{,}, $ref, $proc )
              . q{) passed instead of a processor};
        }
    }
    return [@res];
},
  from
  'Str' => via { [ _str_to_proc($_) ] },
  from
  'CodeRef' => via { [ DataFlow::Proc->new( p => $_ ) ] },
  from
  'DataFlow'            => via { $_->procs },
  from 'DataFlow::Proc' => via { [$_] };

#################### DataFlow::Proc ######################

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

#################### DataFlow::Proc::Converter ######################

enum 'ConversionDirection' => [ 'CONVERT_TO', 'CONVERT_FROM' ];

subtype 'ConversionSubs' => as 'HashRef[CodeRef]' => where {
    scalar( keys %{$_} ) == 2
      && exists $_->{CONVERT_TO}
      && exists $_->{CONVERT_FROM};
} => message { q(Invalid 'ConversionSubs' hash) };

#################### DataFlow::Proc::Encoding ######################

subtype 'Decoder' => as 'CodeRef';
coerce 'Decoder' => from 'Str' => via {
    my $encoding = $_;
    return sub { return decode( $encoding, shift ) };
};

subtype 'Encoder' => as 'CodeRef';
coerce 'Encoder' => from 'Str' => via {
    my $encoding = $_;
    return sub { return encode( $encoding, shift ) };
};

#################### DataFlow::Proc::HTMLFilter ######################

enum 'HTMLFilterTypes', [qw(NODE HTML VALUE)];

1;


__END__
=pod

=encoding utf-8

=head1 NAME

DataFlow::Types - Type definitions for DataFlow

=head1 VERSION

version 1.111480

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

