use Test::More 'no_plan';

use List::Maker;

# INCLUSIVE...

is_deeply [<1..1>],   [1]                         => '<1..1>';
is_deeply [<1..10>],  [1,2,3,4,5,6,7,8,9,10]      => '<1..10>';
is_deeply [<-1..10>], [-1,0,1,2,3,4,5,6,7,8,9,10] => '<-1..10>';
is_deeply [<1..1>],   [1]                         => '<1..1>';
is_deeply [<10..1>],  [10,9,8,7,6,5,4,3,2,1]      => '<10..1>';

is_deeply [<1.1..9.9>], [map { $_+0.1 } 1..9]     => '<1.1..9.9>';
is_deeply [<9.9..1.1>], [map { 10-$_+0.9 } 1..9]  => '<9.9..1.1>';


# PRE EXCLUSIVE...

is_deeply [<1^..10>],  [2,3,4,5,6,7,8,9,10]                => '<1^..10>';
is_deeply [<-1^..10>], [0,1,2,3,4,5,6,7,8,9,10]            => '<-1^..10>';
is_deeply [<1^..1>],   []                                  => '<1^..1>';
is_deeply [<10^..1>],  [9,8,7,6,5,4,3,2,1]                 => '<10^..1>';

is_deeply [1.1, <1.1^..9.9>], [map { $_+0.1 } 1..9]        => '<1.1^..9.9>';
is_deeply [9.9, <9.9^..1.1>], [map { 10-$_+0.9 } 1..9]     => '<9.9^..1.1>';


# POST EXCLUSIVE...

is_deeply [<1..^10>],  [1,2,3,4,5,6,7,8,9]                 => '<1..^10>';
is_deeply [<-1..^10>], [-1,0,1,2,3,4,5,6,7,8,9]            => '<-1..^10>';
is_deeply [<1..^1>],   []                                  => '<1..^1>';
is_deeply [<10..^1>],  [10,9,8,7,6,5,4,3,2]                => '<10..^1>';

is_deeply [<1.1..^9.9>], [map { $_+0.1 } 1..9]             => '<1.1..^9.9>';
is_deeply [<9.9..^1.1>], [map { 10-$_+0.9 } 1..9]          => '<9.9..^1.1>';

is_deeply [<1.1..^9.1>], [map { $_+0.1 } 1..8]         => '<1.1..^9.1>';
is_deeply [<9.9..^1.9>], [map { 10-$_+0.9 } 1..8]      => '<9.9..^1.9>';


# PRE/POST EXCLUSIVE...

is_deeply [<1^..^10>],  [2,3,4,5,6,7,8,9]                 => '<1^..^10>';
is_deeply [<-1^..^10>], [0,1,2,3,4,5,6,7,8,9]            => '<-1^..^10>';
is_deeply [<1^..^1>],   []                                  => '<1^..^1>';
is_deeply [<10^..^1>],  [9,8,7,6,5,4,3,2]                => '<10^..^1>';

is_deeply [<1.1^..^9.9>], [map { $_+0.1 } 2..9]             => '<1.1^..^9.9>';
is_deeply [<9.9^..^1.1>], [map { 10-$_+0.9 } 2..9]          => '<9.9^..^1.1>';

is_deeply [<1.1^..^9.1>,9.1], [map { $_+0.1 } 2..9]         => '<1.1^..^9.9>';
is_deeply [<9.9^..^1.9>,1.9], [map { 10-$_+0.9 } 2..9]      => '<9.9^..^1.1>';

