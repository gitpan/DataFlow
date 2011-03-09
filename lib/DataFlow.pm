package DataFlow;

use strict;
use warnings;

# ABSTRACT: A framework for dataflow processing
# ENCODING: utf8

our $VERSION = '0.91.09';    # VERSION

1;

__END__

=pod

=encoding utf8

=head1 NAME

DataFlow - A framework for dataflow processing

=head1 VERSION

version 0.91.09

=head1 SYNOPSIS

	use DataFlow::Node;
	use DataFlow::Chain;

	my $chain = DataFlow::Chain->new(
		DataFlow::Node->new(
			process_item => sub {
				... do something
			}
		),
		DataFlow::Node->new(
			process_item => sub {
				... do something else
			}
		),
	);

	my $output = $chain->process($input);

=head1 DESCRIPTION

This is a framework for data flow processing. It started as a spinoff project
from L<OpenData-BR|http://www.opendatabr.org/>.

As of now (Mar, 2011) it is still a 'work in progress', and there is a lot of
progress to make. It is highly recommended that you read the tests, and also
the documentation for L<DataFlow::Node> and L<DataFlow::Chain>, to start with.

An article has been recently written in Brazilian Portuguese about this
framework, per the São Paulo Perl Mongers "Equinócio" (Equinox) virtual event.
Although an English version of the article in in the plans, you can figure
a good deal out of the original one at

L<http://sao-paulo.pm.org/equinocio/2011/mar/5>

Any doubts, feel free to get in touch.

=head1 AUTHOR

Alexei Znamensky <russoz@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Alexei Znamensky.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=for :stopwords cpan testmatrix url annocpan anno bugtracker rt cpants kwalitee diff irc mailto metadata placeholders

=head1 SUPPORT

=head2 Perldoc

You can find documentation for this module with the perldoc command.

  perldoc DataFlow

=head2 Websites

The following websites have more information about this module, and may be of help to you. As always,
in addition to those websites please use your favorite search engine to discover more resources.

=over 4

=item *

Search CPAN

L<http://search.cpan.org/dist/DataFlow>

=item *

AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/DataFlow>

=item *

CPAN Ratings

L<http://cpanratings.perl.org/d/DataFlow>

=item *

CPAN Forum

L<http://cpanforum.com/dist/DataFlow>

=item *

CPANTS Kwalitee

L<http://cpants.perl.org/dist/overview/DataFlow>

=item *

CPAN Testers Results

L<http://cpantesters.org/distro/D/DataFlow.html>

=item *

CPAN Testers Matrix

L<http://matrix.cpantesters.org/?dist=DataFlow>

=back

=head2 Internet Relay Chat

You can get live help by using IRC ( Internet Relay Chat ). If you don't know what IRC is,
please read this excellent guide: L<http://en.wikipedia.org/wiki/Internet_Relay_Chat>. Please
be courteous and patient when talking to us, as we might be busy or sleeping! You can join
those networks/channels and get help:

=over 4

=item *

irc.perl.org

You can connect to the server at 'irc.perl.org' and join this channel: #opendata-br to get help.

=back

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
