
package DataFlow::Node::Debug;

BEGIN {
    $DataFlow::Node::Debug::VERSION = '0.91.03';
}

use Moose;
extends 'DataFlow::Node';

use Data::Dumper;

has '+process_item' => (
    default => sub {
        return sub {
            my ( $self, $data ) = @_;
            print STDERR Dumper($data);
            return $data;
          }
    }
);

__PACKAGE__->meta->make_immutable;

1;
