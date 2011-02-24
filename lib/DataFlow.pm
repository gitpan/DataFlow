package DataFlow;

#ABSTRACT: A framework for dataflow processing

use strict;
use warnings;

our $VERSION = '0.91.04';    # VERSION

1;

__END__

=pod

=head1 NAME

DataFlow - A framework for dataflow processing

=head1 VERSION

version 0.91.04

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

As of now (Feb, 2011) it is still a 'work in progress', and there is a lot of
progress to make. It is highly recommended that you read the tests, and also
the documentation for L<DataFlow::Node> and L<DataFlow::Chain>, to start with.

=head1 AUTHOR

Alexei Znamensky <russoz@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Alexei Znamensky.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
