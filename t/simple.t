use strict;
use warnings;

use Test::More tests => 18;

use_ok( 'PPIx::LineToSub' );

my $document = PPI::Document->new( 't/hello.pl' );

$document->index_line_to_sub();

is_deeply( [ $document->line_to_sub(1) ],  [ 'main',   'main' ] );
is_deeply( [ $document->line_to_sub(2) ],  [ 'main',   'main' ] );
is_deeply( [ $document->line_to_sub(3) ],  [ 'main',   'main' ] );
is_deeply( [ $document->line_to_sub(4) ],  [ 'main',   'main' ] );
is_deeply( [ $document->line_to_sub(5) ],  [ 'main',   'main' ] );
is_deeply( [ $document->line_to_sub(6) ],  [ 'main',   'apple' ] );
is_deeply( [ $document->line_to_sub(10) ], [ 'main',   'banana' ] );
is_deeply( [ $document->line_to_sub(14) ], [ 'London', 'main' ] );
is_deeply( [ $document->line_to_sub(16) ], [ 'London', 'alice' ] );
is_deeply( [ $document->line_to_sub(20) ], [ 'London', 'bob' ] );
is_deeply( [ $document->line_to_sub(24) ], [ 'Tokyo',  'main' ] );
is_deeply( [ $document->line_to_sub(26) ], [ 'Tokyo',  'foo' ] );
is_deeply( [ $document->line_to_sub(29) ], [ 'Tokyo',  'main' ],
    'rt107261' );
is_deeply( [ $document->line_to_sub(30) ], [ 'Tokyo',  'bar' ] );
is_deeply( [ $document->line_to_sub(34) ], [ 'Tokyo', 'Nairobi::bazzle' ] );

$document->index_line_to_sub( fqn => 1, main => undef );

is_deeply( [ $document->line_to_sub(1) ],  [ 'main',   undef ] );
is_deeply( [ $document->line_to_sub(34) ], [ 'Nairobi', 'bazzle' ] );
