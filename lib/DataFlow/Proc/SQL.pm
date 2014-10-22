package DataFlow::Proc::SQL;

use strict;
use warnings;

# ABSTRACT: A processor that generates SQL clauses

our $VERSION = '1.111450'; # VERSION

use Moose;
extends 'DataFlow::Proc';

use namespace::autoclean;
use SQL::Abstract;

has '_sql' => (
    'is'      => 'ro',
    'isa'     => 'SQL::Abstract',
    'lazy'    => 1,
    'default' => sub { return SQL::Abstract->new; },
);

has 'table' => (
    'is'       => 'ro',
    'isa'      => 'Str',
    'required' => 1
);

has '+p' => (
    'default' => sub {
        my $self = shift;
        my $sql  = $self->_sql;

        return sub {
            my $data = shift;

            my ( $insert, @bind ) = $sql->insert( $self->table, $data );

            # TODO: regex ?
            map { $insert =~ s/\?/'$_'/; } @bind;
            print $insert . "\n";
          }
    }
);

__PACKAGE__->meta->make_immutable;

1;


__END__
=pod

=encoding utf-8

=head1 NAME

DataFlow::Proc::SQL - A processor that generates SQL clauses

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

