use Test::More 'no_plan';

use List::Maker 'list';

is_deeply [list '1..10x1'],   [1,2,3,4,5,6,7,8,9,10]        => '<1..10x1>';
is_deeply [list '1..10 x1'],  [1,2,3,4,5,6,7,8,9,10]        => '<1..10 x1>';
is_deeply [list '1..10x 1'],  [1,2,3,4,5,6,7,8,9,10]        => '<1..10x 1>';
is_deeply [list '1..10 x 1'], [1,2,3,4,5,6,7,8,9,10]        => '<1..10 x 1>';

is_deeply [list '-1..10x1'],  [-1,0,1,2,3,4,5,6,7,8,9,10]   => '<-1..10>';
is_deeply [list '1..1x1'],    [1]                           => '<1..1>';
is_deeply [list '1..1x2'],    [1]                           => '<1..1>';
is_deeply [list '10..1x-1'],  [10,9,8,7,6,5,4,3,2,1]        => '<10..1>';

is_deeply [list '1.1..9.9x1'],  [map { $_+0.1 } 1..9]       => '<1.1..9.9x1>';
is_deeply [list '9.9..1.1x-1'], [map { 10-$_+0.9 } 1..9]    => '<9.9..1.1x-1>';

is_deeply [list '1..10x2'],   [1,3,5,7,9]                   => '<1..10x2>';
is_deeply [list '1..10x3'],   [1,4,7,10]                    => '<1..10x3>';
is_deeply [list '1..10x4'],   [1,5,9]                       => '<1..10x4>';
is_deeply [list '1..10x5'],   [1,6]                         => '<1..10x5>';
is_deeply [list '1..10x6'],   [1,7]                         => '<1..10x6>';
is_deeply [list '1..10x7'],   [1,8]                         => '<1..10x7>';
is_deeply [list '1..10x8'],   [1,9]                         => '<1..10x8>';
is_deeply [list '1..10x9'],   [1,10]                        => '<1..10x9>';
is_deeply [list '1..10x10'],  [1]                           => '<1..10x10>';

is_deeply [list '1.1..9.9x2.5'], [1.1, 3.6, 6.1, 8.6]       => '<1.1..9.9x2.5>';

# Verify that no magic is occurring...
my @data = <1..10>;
ok @data != 10, 'No magic';
