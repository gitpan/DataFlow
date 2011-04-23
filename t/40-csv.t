use Test::More tests => 14;

use_ok('DataFlow::Proc::CSV');
new_ok( 'DataFlow::Proc::CSV' => [ direction => 'FROM_CSV' ] );
new_ok( 'DataFlow::Proc::CSV' => [ direction => 'TO_CSV' ] );

my $to_csv = DataFlow::Proc::CSV->new( direction => 'TO_CSV', );
is( ( $to_csv->p->( [qw/a b c 1 2 3/] ) )[0],
    'a,b,c,1,2,3', 'produces a CSV output' );
my @res = $to_csv->process_one( [qw/a b c 1 2 3/] );
is( $res[0], 'a,b,c,1,2,3', 'produces a CSV output' );

is(
    ( $to_csv->process_one( [ 'a 1', 'b 2', 'c', 3 ] ) )[0],
    q{"a 1","b 2",c,3},
    'handles quotes properly'
);

$to_csv = DataFlow::Proc::CSV->new(
    direction => 'TO_CSV',
    header    => [qw/h1 h2 h3 h4 h5 h6/],
);
@res = $to_csv->process_one( [qw/a b c 1 2 3/] );
is( $res[0], 'h1,h2,h3,h4,h5,h6', 'uses headers in output' );
is( $res[1], 'a,b,c,1,2,3',       'produces a CSV output' );

@res = $to_csv->process_one( [ 'a 1', 'b 2', 'c', 3 ] );
is(
    $res[0],
    q{"a 1","b 2",c,3},
    'handles quotes properly, and do not use headers a second time'
);

my $from_csv = DataFlow::Proc::CSV->new( direction => 'FROM_CSV', );
my @res_from = $from_csv->process_one('a,b,c,1,2,3');

is_deeply( $res_from[0], [qw/a b c 1 2 3/], 'Consumes a CSV input properly', );
@res_from = $from_csv->process_one(q{"a 1","b 2",c,3});
is_deeply(
    $res_from[0],
    [ 'a 1', 'b 2', 'c', 3 ],
    'Consumes a CSV input properly',
);

$from_csv =
  DataFlow::Proc::CSV->new( direction => 'FROM_CSV', header_wanted => 1 );
my @input = ( 'h1,h2,h3,h4,h5,h6', 'a,b,c,1,2,3', q{"a 1","b 2",c,3}, );
@res_from = map { $from_csv->process_one($_) } @input;
is_deeply( $from_csv->header, [qw/h1 h2 h3 h4 h5 h6/],
    'parses headers properly' );
is_deeply( $res_from[0], [qw/a b c 1 2 3/], 'and parses the following lines' );
is_deeply( $res_from[1], [ 'a 1', 'b 2', 'c', 3 ], 'even with quotes' );
