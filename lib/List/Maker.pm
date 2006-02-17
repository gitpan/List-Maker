package List::Maker;

use version; $VERSION = qv('0.0.2');

use warnings;
use strict;
use Carp;

# Regexes to parse the acceptable list syntaxes...
my $NUM    = qr{\s* [+-]? \d+ (?:\.\d*)? \s* }xms;
my $TO     = qr{\s* \.\. \s*}xms;
my $FILTER = qr{ (?: : (.*) )? }xms;

my $AB_TO_Z  = qr{\A ($NUM) (,) ($NUM) ,? $TO ($NUM) $FILTER \Z}xms;
my $AZ_X_N   = qr{\A ($NUM) $TO ($NUM) (?:x ($NUM))? $FILTER \Z}xms;

no warnings 'redefine';
*CORE::GLOBAL::glob = sub
{
    my ($listspec) = @_;

    # If it doesn't match a special form, it's a < word list >...
    return _qww($listspec) if $listspec !~ $AB_TO_Z && $listspec !~ $AZ_X_N;

    # Extract the range of values and any filter...
    my ($from, $to, $incr, $filter) =  $2 eq ',' ? ($1, $4, $3-$1, $5)
                                    :              ($1, $2, $3,    $4);
    $incr = $from > $to ? -1 : 1 if !defined $incr;

    # Check for nonsensical increments (zero or the wrong sign)...
    my $delta = $to - $from;
    croak sprintf "Sequence <%s, %s, %s...> will never reach %s",
        $from, $from+$incr, $from+2*$incr, $to
            if $incr == 0 && $from != $to || $delta * $incr < 0;

    # Generate list of values (and return it, if not filter)...
    my @vals = $incr ? map { $from + $incr * $_ } 0..($delta/$incr) : $from;
    return @vals if !defined $filter;

    # Apply the filter before returning the values...
    $filter =~ s/\b[A-Z]\b/\$_/g;
    my $caller = caller;
    return eval "grep {package $caller; $filter } \@vals";
};

sub _qww {
    my ($content) = @_;

    # Break into words (or "w o r d s" or 'w o r d s') and strip quoters...
    return map { s/\A(["'])(.*)\1\z/$2/xms; $_; }
                $content =~ m{ ( " [^\\"]* (?:\\. [^\\"]*)* "
                               | ' [^\\']* (?:\\. [^\\']*)* '
                               | \S+
                               )
                             }gxms;
}


1; # Magic true value required at end of module
__END__

=head1 NAME

List::Maker - Generate more sophisticated lists than just $a..$b


=head1 VERSION

This document describes List::Maker version 0.0.2


=head1 SYNOPSIS

    use List::Maker;

    @list = <1..10>;                      # (1,2,3,4,5,6,7,8,9,10)

    @list = <10..1>;                      # (10,9,8,7,6,5,4,3,2,1)

    @list = <1,3,..10>                    # (1,3,5,7,9)
    @list = <1..10 x 2>                   # (1,3,5,7,9)
  
    @list = <0..10 : prime N>;            # (2,3,5,7)
    @list = <1,3,..30  : /7/>             # (7,17,27)

    @words = < a list of words >;         # ('a', 'list', 'of', 'words')
    @words = < 'a list' "of words" >;     # ('a list', 'of words')

  
=head1 DESCRIPTION

The List::Maker module hijacks Perl's built-in file globbing syntax (C<< <
*.pl > >> and C<glob '*.pl'>) and retargets it at list creation.

The rationale is simple: most people rarely if ever glob a set of files,
but they have to create lists in almost every program they write. So the
list construction syntax should be easier than the filename expansion syntax.

=head1 INTERFACE 

Once the module has been loaded, angle brackets no longer expand a shell
pattern into a list of files. Instead, they expand a list specification
into a list of values.

=head2 Numeric lists

Numeric list specifications may take any of the following 4 forms:

    Type           Syntax                  For example     Produces
    ==========     ===================     ===========     ===========
    Count up       <MIN..MAX>              <1..5>          (1,2,3,4,5)
    Count down     <MAX..MIN>              <5..1>          (5,4,3,2,1)
    Count by       <START..END x STEP>     <1..10 x 3>     (1,4,7,10)
    Count via      <START, NEXT,..END>     <1, 3,..10>     (1,3,5,7,9)

The numbers don't have to be integers either:

    @scores = <0.5..4.5>;      # same as: (0.5, 1.5, 2.5, 3.5, 4.5)

    @steps = <1..0 x -0.2>;    # same as: (1, 0.8, 0.6, 0.4, 0.2, 0)
    

=head2 Filtered numeric lists

Any of the four styles of numeric list may also have a filter applied to it,
by appending a colon, followed by a boolean expression:

    @odds   = <1..100 : \$_ % 2 != 0 >;

    @primes = <3,5..99> : is_prime(\$_) >;

    @available = <1..$max : !allocated{\$_} >

    @ends_in_7 = <1..1000 : /7$/ >

The boolean expression is tested against each element of the list, and
only those for which it is true are retained. During these tests each
element is aliased to C<$_>. However, since angle brackets interpolate,
it's necessary to escape any explicit reference to C<$_> within the
filtering expression, as in the first three examples above.

That often proves to be annoying, so the module also allows the
candidate value to be referred to using any single uppercase letter
(which is replaced with C<\$_> when the filter is applied. So the
previous examples could also be written:

    @odds   = <1..100 : N % 2 != 0 >;

    @primes = <3,5..99> : is_prime(N) >;

    @available = <1..$max : !allocated{N} >

or (since the specific letter is irrelevant):

    @odds   = <1..100 : X % 2 != 0 >;

    @primes = <3,5..99> : is_prime(I) >;

    @available = <1..$max : !allocated{T} >


=head2 String lists

Any list specification that doesn't conform to one of the four pattern
described above is taken to be a list of whitespace-separated strings,
like a C<qw{...}> list:

    @words = <Eat at Joe's>;     # same as: ( 'Eat', 'at', 'Joe\'s' )

However, unlike a C<qw{...}>, these string lists interpolate (before
listification):

    $whose = q{Joe's};

    @words = <Eat at $whose>;    # same as: ( 'Eat', 'at', 'Joe\'s' )

More interestingly, the words in these lists can be quoted to change the
default whitespace separation. For example:

    @names = <Tom Dick "Harry Potter">;   
                        # same as: ( 'Tom', 'Dick', 'Harry Potter' )
    
Single quotes may be also used, but this may be misleading, since the
overall list still interpolates in that case:

    @names = <Tom Dick '$Harry{Potter}'>;   
                        # same as: ( 'Tom', 'Dick', "$Harry{Potter}" )


=head1 DIAGNOSTICS

=over

=item C<< Sequence <%s, %s, %s...> will never reach %s >>

The specified numeric list didn't make sense. Typically, because you
specified an increasing list with a negative step size (or vice versa).

=back


=head1 CONFIGURATION AND ENVIRONMENT

List::Maker requires no configuration files or environment variables.


=head1 DEPENDENCIES

None.


=head1 INCOMPATIBILITIES

Using this module prevents you from using C<< <...> >> or C<glob()> to expand
file lists. You would need to use the C<File::Glob> module directly:

    use File::Glob;

    my @files = bsd_glob("*.pl");


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-list-maker@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.


=head1 AUTHOR

Damian Conway  C<< <DCONWAY@CPAN.org> >>


=head1 LICENCE AND COPYRIGHT

Copyright (c) 2005, Damian Conway C<< <DCONWAY@CPAN.org> >>. All rights reserved.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.


=head1 DISCLAIMER OF WARRANTY

BECAUSE THIS SOFTWARE IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE SOFTWARE, TO THE EXTENT PERMITTED BY APPLICABLE LAW. EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE SOFTWARE "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER
EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. THE
ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SOFTWARE IS WITH
YOU. SHOULD THE SOFTWARE PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL
NECESSARY SERVICING, REPAIR, OR CORRECTION.

IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE SOFTWARE AS PERMITTED BY THE ABOVE LICENCE, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL,
OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE
THE SOFTWARE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING
RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A
FAILURE OF THE SOFTWARE TO OPERATE WITH ANY OTHER SOFTWARE), EVEN IF
SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF
SUCH DAMAGES.
