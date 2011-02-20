
package DataFlow::Node::URLRetriever::Get::Curl;

BEGIN {
    $DataFlow::Node::URLRetriever::Get::Curl::VERSION = '0.91.03';
}

use Moose::Role;

use LWP::Curl;

sub _make_obj {
    return LWP::Curl->new;
}

1;
