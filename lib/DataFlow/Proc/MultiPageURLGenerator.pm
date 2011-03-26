package DataFlow::Proc::MultiPageURLGenerator;

use strict;
use warnings;

# ABSTRACT: A processor that generates multi-paged URL lists
# ENCODING: utf8

our $VERSION = '0.950000';    # VERSION

use Moose;
extends 'DataFlow::Proc';

use Carp;

has 'first_page' => (
    'is'      => 'ro',
    'isa'     => 'Int',
    'default' => 1,
);

has 'last_page' => (
    'is'       => 'ro',
    'isa'      => 'Int',
    'required' => 1,
    'lazy'     => 1,
    'default'  => sub {
        my $self = shift;

        #warn 'last_page';
        confess(q{DataFlow::Proc::MultiPageURLGenerator: paged_url not set!})
          unless $self->has_paged_url;
        return $self->produce_last_page->( $self->_paged_url );
    },
);

# calling convention for the sub:
#   - $self
#   - $url (Str)
has 'produce_last_page' => (
    'is'      => 'ro',
    'isa'     => 'CodeRef',
    'lazy'    => 1,
    'default' => sub { confess(q{produce_last_page not implemented!}); },
);

# calling convention for the sub:
#   - $self
#   - $paged_url (Str)
#   - $page      (Int)
has 'make_page_url' => (
    'is'       => 'ro',
    'isa'      => 'CodeRef',
    'required' => 1,
);

has '_paged_url' => (
    'is'        => 'rw',
    'isa'       => 'Str',
    'predicate' => 'has_paged_url',
    'clearer'   => 'clear_paged_url',
);

has '+p' => (
    'default' => sub {
        my $self = shift;

        return sub {
            my $url = shift;

            $self->_paged_url($url);

            my $first = $self->first_page;
            my $last  = $self->last_page;
            $first = 1 + $last + $first if $first < 0;

            my @result =
              map { $self->make_page_url->( $self, $url, $_ ) } $first .. $last;

            $self->clear_paged_url;
            return [@result];
        };
    },
);

__PACKAGE__->meta->make_immutable;
no Moose;

1;

__END__

=pod

=encoding utf8

=head1 NAME

DataFlow::Proc::MultiPageURLGenerator - A processor that generates multi-paged URL lists

=head1 VERSION

version 0.950000

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
