package DataFlow::Role::Converter;

use strict;
use warnings;

# ABSTRACT: A role for format-conversion processors

our $VERSION = '1.111450'; # VERSION

use MooseX::Role::Parameterized;
use Moose::Util::TypeConstraints 1.01;

parameter 'type_attr' => (
    'isa'      => 'Str',
    'required' => 1,
);

parameter 'type_class' => (
    'isa'      => 'Str',
    'required' => 1,
);

parameter 'type_class_imports' => (
    'isa'       => 'ArrayRef',
    'predicate' => 'has_imports',
);

parameter 'type_short' => (
    'isa'      => 'Str',
    'required' => 1,
);

role {
    my $p = shift;

    my $attr     = $p->type_attr;
    my $class    = $p->type_class;
    my $opts     = $attr . '_opts';
    my $has_opts = 'has_' . $opts;
    my $short    = $p->type_short;

    my $direction_from = 'FROM_' . uc($short);
    my $direction_to   = 'TO_' . uc($short);

    has 'direction' => (
        is       => 'ro',
        isa      => enum( [ $direction_from, $direction_to ] ),
        required => 1,
    );

    has $opts => (
        is        => 'ro',
        isa       => 'Ref',
        predicate => $has_opts,
    );

    has $attr => (
        is      => 'ro',
        isa     => $class,
        lazy    => 1,
        default => sub {
            my $self = shift;
            return $self->_attr_default;
        },
    );

    method '_attr_default' => sub {
        my $self = shift;
        my $options = $self->$opts || +{};

        my $use_clause = "use $class";
        $use_clause .= " (@{ $p->type_class_imports })" if $p->has_imports;

        eval $use_clause;    ## no critic
        my $o = $class->new($options);
        eval "no $class";    ## no critic

        return $o;
    };
};

1;


__END__
=pod

=encoding utf-8

=head1 NAME

DataFlow::Role::Converter - A role for format-conversion processors

=head1 VERSION

version 1.111450

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

