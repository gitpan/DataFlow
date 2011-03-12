package DataFlow::Node::CSV;

use strict;
use warnings;

# ABSTRACT: A CSV converting node
# ENCODING: utf8

our $VERSION = '0.91.10';    # VERSION

use Moose;
extends 'DataFlow::Node';

use Moose::Util::TypeConstraints;
use Text::CSV;

has 'headers' => (
    'is'        => 'rw',
    'isa'       => 'ArrayRef[Str]',
    'predicate' => 'have_headers',
);

has '_header_unused' => (
    'is'      => 'rw',
    'isa'     => 'Bool',
    'default' => 1,
    'clearer' => '_use_header',
);

enum '_direction_type' => [qw/FROM_CSV TO_CSV/];

has 'direction' => (
    'is'       => 'ro',
    'isa'      => '_direction_type',
    'required' => 1,
);

has 'text_csv_opts' => (
    'is'        => 'ro',
    'isa'       => 'HashRef',
    'predicate' => 'has_text_csv_opts',
);

has 'csv' => (
    'is'      => 'ro',
    'isa'     => 'Text::CSV',
    'default' => sub {
        my $self = shift;

        return $self->has_text_csv_opts
          ? Text::CSV->new( $self->text_csv_opts )
          : Text::CSV->new();
    },
);

sub _combine {
    my ( $self, $e ) = @_;
    $self->csv->combine( @{$e} );
    return $self->csv->string;
}

sub _to_csv {
    my ( $self, $data ) = @_;
    if ( $self->_header_unused ) {
        $self->_header_unused(0);
        return ( $self->_combine( $self->headers ), $self->_combine($data) );
    }

    return $self->_combine($data);
}

sub _parse {
    my ( $self, $line ) = @_;
    $self->csv->parse($line);
    return [ $self->csv->fields ];
}

sub _from_csv {
    my ( $self, $csv_line ) = @_;
    if ( $self->_header_unused ) {
        $self->_header_unused(0);
        $self->headers( $self->_parse($csv_line) );
        return;
    }
    return $self->_parse($csv_line);
}

has '+process_into' => ( 'default' => 0, );

has '+process_item' => (
    'lazy'    => 1,
    'default' => sub {
        return \&_to_csv if shift->direction eq 'TO_CSV';
        return \&_from_csv;
    }
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=pod

=encoding utf8

=head1 NAME

DataFlow::Node::CSV - A CSV converting node

=head1 VERSION

version 0.91.10

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
