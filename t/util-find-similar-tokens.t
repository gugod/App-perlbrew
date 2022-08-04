use strict;
use warnings;
use Test::More tests => 3;
use App::Perlbrew::Util qw( find_similar_tokens );

my @tokens = (
    "apple",
    "pie",
    "orange",
    "tree",
    "maple",
    "leaves",
);

subtest "exact result", sub {
    my $similar_tokens = find_similar_tokens( "orange", \@tokens );
    is 0+@$similar_tokens, 1;
    is $similar_tokens->[0], "orange";
};

subtest "one result", sub {
    my $similar_tokens = find_similar_tokens( "appli", \@tokens );
    is 0+@$similar_tokens, 1;
    is $similar_tokens->[0], "apple";
};

subtest "two results", sub {
    my $similar_tokens = find_similar_tokens( "aple", \@tokens );
    is 0+@$similar_tokens, 2;

    @$similar_tokens = sort @$similar_tokens;
    is $similar_tokens->[0], "apple";
    is $similar_tokens->[1], "maple";
};

done_testing;
