package DataFlow;

use strict;
use warnings;

# ABSTRACT: A component for dataflow processing

our $VERSION = '1.111130'; # VERSION

use Moose;
use Moose::Util::TypeConstraints 1.01;

use namespace::autoclean;
use Queue::Base 2.1;
use DataFlow::Proc;
use Data::Dumper;

# subtypes
subtype 'ProcessorChain' => as 'ArrayRef[DataFlow::Proc]' =>
  where { scalar @{$_} > 0 } =>
  message { 'DataFlow must have at least one processor' };
coerce 'ProcessorChain' => from 'ArrayRef[Ref]' => via {
    my @list = @{$_};
    return [ map { DataFlow::Proc->new( p => $_ ) } @list ];
};
coerce 'ProcessorChain' => from 'CodeRef' =>
  via { [ DataFlow::Proc->new( p => $_ ) ] };
coerce 'ProcessorChain' => from 'DataFlow'       => via { $_->procs };
coerce 'ProcessorChain' => from 'DataFlow::Proc' => via { [$_] };

with 'MooseX::OneArgNew' =>
  { 'type' => 'ArrayRef[Ref]', 'init_arg' => 'procs', };
with 'MooseX::OneArgNew' => { 'type' => 'CodeRef',  'init_arg' => 'procs', };
with 'MooseX::OneArgNew' => { 'type' => 'DataFlow', 'init_arg' => 'procs', };
with 'MooseX::OneArgNew' =>
  { 'type' => 'DataFlow::Proc', 'init_arg' => 'procs', };

# attributes
has 'name' => (
    'is'  => 'ro',
    'isa' => 'Str',
);

has 'auto_process' => (
    'is'      => 'ro',
    'isa'     => 'Bool',
    'lazy'    => 1,
    'default' => 1,
);

has 'procs' => (
    'is'       => 'ro',
    'isa'      => 'ProcessorChain',
    'required' => 1,
    'coerce'   => 1,
);

has '_queues' => (
    'is'      => 'ro',
    'isa'     => 'ArrayRef[Queue::Base]',
    'lazy'    => 1,
    'default' => sub { return _make_queues( shift->procs ); },
    'handles' => {
        '_firstq'         => sub { return shift->_queues->[0] },
        'has_queued_data' => sub {
            return _count_queued_items( shift->_queues );
        },
    },
);

has '_lastq' => (
    'is'      => 'ro',
    'isa'     => 'Queue::Base',
    'lazy'    => 1,
    'default' => sub { return Queue::Base->new },
);

# functions
sub _count_queued_items {
    my $q     = shift;
    my $count = 0;

    map { $count = $count + $_->size } @{$q};

    return $count;
}

sub _process_queues {
    my ( $proc, $inputq, $outputq ) = @_;

    my $item = $inputq->remove;
    my @res  = $proc->process_one($item);
    $outputq->add(@res);
    return;
}

sub _make_queues {
    my $procs = shift;
    my @queues = map { Queue::Base->new() } @{$procs};
    return [@queues];
}

sub _reduce {
    my ( $p, @q ) = @_;
    map { _process_queues( $p->[$_], $q[$_], $q[ $_ + 1 ] ) } ( 0 .. $#q - 1 );
    return;
}

# methods
sub clone {
    my $self = shift;
    return DataFlow->new( procs => $self->procs );
}

sub input {
    my ( $self, @args ) = @_;
    $self->_firstq->add(@args);
    return;
}

sub process_input {
    my $self = shift;
    my @q = ( @{ $self->_queues }, $self->_lastq );
    _reduce( $self->procs, @q );
    return;
}

sub output {
    my $self = shift;

    $self->process_input if ( $self->_lastq->empty && $self->auto_process );
    return wantarray ? $self->_lastq->remove_all : $self->_lastq->remove;
}

sub flush {
    my $self = shift;
    while ( $self->has_queued_data ) {
        $self->process_input;
    }
    return $self->output;
}

sub process {
    my ( $self, @args ) = @_;

    my $flow = $self->clone();
    $flow->input(@args);
    return $flow->flush;
}

__PACKAGE__->meta->make_immutable;

1;



__END__
=pod

=encoding utf-8

=head1 NAME

DataFlow - A component for dataflow processing

=head1 VERSION

version 1.111130

=head1 SYNOPSIS

use DataFlow;

	my $flow = DataFlow->new(
		procs => [
			DataFlow::Proc->new( p => sub { do this thing } ),
			sub { ... do something },
			sub { ... do something else },
		]
	);

	$flow->input( <some input> );
	my $output = $flow->output();

	my $output = $flow->output( <some other input> );

=head1 DESCRIPTION

A C<DataFlow> object is able to accept data, feed it into an array of
processors (L<DataFlow::Proc> objects), and return the result(s) back to the
caller.

=head1 ATTRIBUTES

=head2 name

[Str] A descriptive name for the dataflow. (OPTIONAL)

=head2 auto_process

[Bool] If there is data available in the output queue, and one calls the
C<output()> method, this attribute will flag whether the dataflow should
attempt to automatically process queued data. (DEFAULT: true)

=head2 procs

[ArrayRef[DataFlow::Proc]] The list of processors that make this DataFlow.
Optionally, you may pass CodeRefs that will be automatically converted to
L<DataFlow::Proc> objects. (REQUIRED)

=head1 METHODS

=head2 has_queued_data

Returns true if the dataflow contains any queued data within.

=head2 clone

Returns another instance of a C<DataFlow> using the same array of processors.

=head2 input

Accepts input data for the data flow. It will gladly accept anything passed as
parameters. However, it must be noticed that it will not be able to make a
distinction between arrays and hashes. Both forms below will render the exact
same results:

	$flow->input( qw/all the simple things/ );
	$flow->input( all => 'the', simple => 'things' );

If you do want to handle arrays and hashes differently, we strongly suggest
that you use references:

	$flow->input( [ qw/all the simple things/ ] );
	$flow->input( { all => the, simple => 'things' } );

Processors with C<process_into> enabled (true by default) will process the
items inside an array reference, and the values (not the keys) inside a hash
reference.

=head2 process_input

Processes items in the array of queues and place at least one item in the
output (last) queue. One will typically call this to flush out some unwanted
data and/or if C<auto_process> has been disabled.

=head2 output

Fetches data from the data flow. If called in scalar context it will return
one processed item from the flow. If called in list context it will return all
the elements in the last queue.

=head2 flush

Flushes all the data through the dataflow, and returns the complete result set.

=head2 process

Immediately processes a bunch of data, without touching the object queues. It
will process all the provided data and return the complete result set for it.

=head1 HISTORY

This is a framework for data flow processing. It started as a spinoff project
from the L<OpenData-BR|http://www.opendatabr.org/> initiative.

As of now (Mar, 2011) it is still a 'work in progress', and there is a lot of
progress to make. It is highly recommended that you read the tests, and the
documentation of L<DataFlow::Proc>, to start with.

An article has been recently written in Brazilian Portuguese about this
framework, per the São Paulo Perl Mongers "Equinócio" (Equinox) virtual event.
Although an English version of the article in in the plans, you can figure
a good deal out of the original one at

L<http://sao-paulo.pm.org/equinocio/2011/mar/5>

B<UPDATE:> L<DataFlow> is a fast-evolving project, and this article, as
it was published there, refers to versions 0.91.x of the framework. There has
been a big refactor since then and, although the concept remains the same,
since version 0.950000 the programming interface has been changed violently.

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

The default CPAN search engine, useful to view POD in HTML format.

L<http://search.cpan.org/dist/DataFlow>

=item *

AnnoCPAN

The AnnoCPAN is a website that allows community annonations of Perl module documentation.

L<http://annocpan.org/dist/DataFlow>

=item *

CPAN Ratings

The CPAN Ratings is a website that allows community ratings and reviews of Perl modules.

L<http://cpanratings.perl.org/d/DataFlow>

=item *

CPAN Forum

The CPAN Forum is a web forum for discussing Perl modules.

L<http://cpanforum.com/dist/DataFlow>

=item *

CPANTS

The CPANTS is a website that analyzes the Kwalitee ( code metrics ) of a distribution.

L<http://cpants.perl.org/dist/overview/DataFlow>

=item *

CPAN Testers

The CPAN Testers is a network of smokers who run automated tests on uploaded CPAN distributions.

L<http://www.cpantesters.org/distro/D/DataFlow>

=item *

CPAN Testers Matrix

The CPAN Testers Matrix is a website that provides a visual way to determine what Perls/platforms PASSed for a distribution.

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
