package DataFlow::Node::CSV;

#ABSTRACT: A CSV converting node

use strict;
use warnings;

our $VERSION = '0.91.05';    # VERSION

use Moose;
extends 'DataFlow::Node';

use Carp;
use Text::CSV;

has 'header' => (
    is        => 'ro',
    isa       => 'ArrayRef[Str]',
    predicate => 'has_header',
);

has 'inject_header' => (
    is      => 'ro',
    isa     => 'Bool',
    default => 0,
);

has 'text_csv_opts' => (
    is        => 'ro',
    isa       => 'HashRef',
    predicate => 'has_text_csv_opts',
);

has 'csv' => (
    is      => 'ro',
    isa     => 'Text::CSV',
    lazy    => 1,
    default => sub {
        my $self = shift;

        my $make_csv = sub {
            return Text::CSV->new(
                $self->has_text_csv_opts ? $self->text_csv_opts : undef );
        };
        return $make_csv->() unless $self->inject_header;

        croak
'Thou hast requested to inject headers but, alas, no header has been provided'
          unless ( $self->has_header );

        $self->_add_output( $self->deref ? @{ $self->header } : $self->header );
        return $make_csv->();
    },
);

has '+process_item' => (
    default => sub {
        return sub {
            my ( $self, $data ) = @_;
            return $data unless ref($data) eq 'ARRAY';

            $self->csv->combine( @{$data} );
            return $self->csv->string;
          }
    }
);

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

DataFlow::Node::CSV - A CSV converting node

=head1 VERSION

version 0.91.05

=head1 AUTHOR

Alexei Znamensky <russoz@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Alexei Znamensky.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
