package DataFlow::Node::LiteralData;

#ABSTRACT: A node provides its initialization data for flow processing

use strict;
use warnings;

our $VERSION = '0.91.05';    # VERSION

use Moose;
with(
    'MooseX::OneArgNew' => {
        type     => 'Any',
        init_arg => 'data',
    }
);

extends 'DataFlow::Node::Null';

has data => (
    is        => 'ro',
    isa       => 'Any',
    clearer   => 'clear_data',
    predicate => 'has_data',
    required  => 1,
    trigger   => sub {
        my $self = shift;
        if ( $self->has_data ) {
            $self->_add_input(@_);
            $self->clear_data;
        }
    },
);

__PACKAGE__->meta->make_immutable;

1;

__END__

=pod

=head1 NAME

DataFlow::Node::LiteralData - A node provides its initialization data for flow processing

=head1 VERSION

version 0.91.05

=head1 AUTHOR

Alexei Znamensky <russoz@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Alexei Znamensky.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
