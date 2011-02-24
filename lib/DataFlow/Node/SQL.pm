package DataFlow::Node::SQL;

#ABSTRACT: A node that generates SQL clauses

use strict;
use warnings;

our $VERSION = '0.91.04';    # VERSION

use Moose;
extends 'DataFlow::Node';

use SQL::Abstract;

my $sql = SQL::Abstract->new;

has 'table' => (
    is       => 'ro',
    isa      => 'Str',
    required => 1
);

has '+process_item' => (
    default => sub {
        return sub {
            my ( $self, $data ) = @_;
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

=head1 NAME

DataFlow::Node::SQL - A node that generates SQL clauses

=head1 VERSION

version 0.91.04

=head1 AUTHOR

Alexei Znamensky <russoz@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Alexei Znamensky.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
