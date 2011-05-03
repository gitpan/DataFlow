package DataFlow::Proc::HTMLFilter;

use strict;
use warnings;

# ABSTRACT: A HTML filtering processor

our $VERSION = '1.111230'; # VERSION

use Moose;
extends 'DataFlow::Proc';

use namespace::autoclean;
use Moose::Util::TypeConstraints 1.01;
use HTML::TreeBuilder::XPath;

has 'search_xpath' => (
    'is'       => 'ro',
    'isa'      => 'Str',
    'required' => 1,
);

has 'result_type' => (
    'is'      => 'ro',
    'isa'     => enum( [qw(NODE HTML VALUE)] ),
    'default' => 'HTML',
);

has 'ref_result' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'default' => 0,
);

has 'nochomp' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'default' => 0,
);

has '+p' => (
    'lazy'    => 1,
    'default' => sub {
        my $self = shift;

        my $proc = sub {
            my $item = shift;

            my $html = HTML::TreeBuilder::XPath->new_from_content($item);

            #warn 'xpath is built';
            #warn 'values if VALUES';
            return $html->findvalues( $self->search_xpath )
              if $self->result_type eq 'VALUE';

            #warn 'not values, find nodes';
            my @result = $html->findnodes( $self->search_xpath );

            #use Data::Dumper; warn 'result = '.Dumper(\@result);
            return () unless @result;
            return @result if $self->result_type eq 'NODE';

            #warn 'wants HTML';
            return map { $_->as_HTML } @result;
        };

        my $proc2 = $self->nochomp ? $proc : sub { return chomp $proc->(@_) };
        my $proc3 =
          $self->ref_result ? sub { return [ $proc2->(@_) ] } : $proc2;

        return $self->ref_result ? sub { return [ $proc->(@_) ] } : $proc;
    },
);

__PACKAGE__->meta->make_immutable;

1;



=pod

=encoding utf-8

=head1 NAME

DataFlow::Proc::HTMLFilter - A HTML filtering processor

=head1 VERSION

version 1.111230

=head1 SYNOPSIS

    use DataFlow::Proc::HTMLFilter;

    my $filter_html = DataFlow::Proc::HTMLFilter->new(
        search_xpath => '//td',
    	result_type  => 'HTML',
	);

    my $filter_value = DataFlow::Proc::HTMLFilter->new(
        search_xpath => '//td',
    	result_type  => 'VALUE',
	);

    my $input = <<EOM;
    <html><body>
      <table>
        <tr><td>Line 1</td><td>L1, Column 2</td>
        <tr><td>Line 2</td><td>L2, Column 2</td>
      </table>
    </html></body>
    EOM

    $filter_html->process_one( $input );
    # @result == '<td>Line 1</td>', ... '<td>L2, Column 2</td>'

    $filter_value->process_one( $input );
    # @result == q{Line 1}, ... q{L2, Column 2}

=head1 DESCRIPTION

This processor type provides a filter for HTML content.
Each item will be considered as a HTML content and will be filtered
using L<HTML::TreeBuilder::XPath>.

=head1 ATTRIBUTES

=head2 search_xpath

This attribute is a XPath string used to filter down the HTML content.
The C<search_xpath> attribute is mandatory.

=head2 result_type

This attribute is a string, but its value B<must> be one of:
C<HTML>, C<VALUE>, C<NODE>. The default is C<HTML>.

=head3 HTML

The result will be the HTML content specified by C<search_xpath>.

=head3 VALUE

The result will be the literal value enclosed by the tag and/or attribute
specified by C<search_xpath>.

=head3 NODE

The result will be a list of L<HTML::Element> objects, as returned by the
C<findnodes> method of L<HTML::TreeBuilder::XPath> class.

Most people will probably use C<HTML> or C<VALUE>, but this option is also
provided in case someone wants to manipulate the HTML elements directly.

=head2 ref_result

This attribute is a boolean, and it signals whether the result list should be
added as a list of items to the output queue, or as a reference to an array
of items. The default is 0 (false).

There is a semantic subtlety here: if C<ref_result> is 1 (true),
then one HTML item (input) may generate one or zero ArrayRef item (output),
i.e. it is a one-to-one mapping.
On the other hand, by keeping C<ref_result> as 0 (false), one HTML item
may produce any number of items as result,
i.e. it is a one-to-many mapping.

=head1 DEPENDENCIES

L<HTML::TreeBuilder::XPath>

L<HTML::Element>

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


