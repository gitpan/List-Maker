use Test::More 'no_plan';

use List::Maker;

is_deeply [< a word list >],   ['a','word','list'] => '< a word list >';
is_deeply [< >],               []                  => '< >';

is_deeply [< "a word" list >], ['a word','list']   => '< "a word" list >';
is_deeply [< 'a word' list >], ['a word','list']   => '< \'a word\' list >';

is_deeply [< "o'word" list >], ['o\'word','list']   => '< "o\'word" list >';
is_deeply [< 'u"word' list >], ['u"word','list']   => '< \'u"word\' list >';
