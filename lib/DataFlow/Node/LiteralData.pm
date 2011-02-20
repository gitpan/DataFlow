
package DataFlow::Node::LiteralData;

BEGIN {
    $DataFlow::Node::LiteralData::VERSION = '0.91.03';
}

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
