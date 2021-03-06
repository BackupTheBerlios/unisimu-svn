#: binary_tree_set2.t
#: Test the script binary_tree_set2.pl
#: Copyright (c) 2006 Agent Zhang
#: 2006-02-28 2006-03-03

use Test::Cmd::Base;

plan tests => 1 * blocks;

my $script = $ARGV[0] || "binary_tree_set2.pl";
#warn $script;

if ($script =~ /\.pl$/i) {
    run_cmd_tests("$^X $script");
} else {
    run_cmd_tests($script);
}

__END__

=== TEST 1
--- options
1
--- stdout
1



=== TEST 2
--- options
2
--- stdout
1 3



=== TEST 3
--- options
3
--- stdout
1 3 4



=== TEST 4
--- options
6
--- stdout
1 3 4 7 9 10



=== TEST 5
--- options
15
--- stdout
1 3 4 7 9 10 13 15 19 21 22 27 28 31 39



=== TEST 6
--- options
16
--- stdout
1 3 4 7 9 10 13 15 19 21 22 27 28 31 39 40



=== TEST 7
--- options
0
--- stdout eval: "\n"
