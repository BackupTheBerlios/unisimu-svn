#: binary_tree_set2.pl
#: Copyright (c) 2006 Agent Zhang
#: 2006-02-28 2006-02-28

use strict;
use warnings;

# find m minimal nodes:
my $m = shift;
exit(0) if $m <= 0;

# global counter which indicates the maximal
# depth we should reach:
my $c = 0;

# store the tree by levels (rooted at 1):
my @levels = [1];

# store all the visited nodes:
my %visited;

my $i = 1;
while ($c < $m) {
    gen_level($i);
    process_level($i);
    $i++;
}
my @nodes = sort { $a <=> $b } map { @$_ } @levels;

# print out the m minimal nodes in the tree:
print join(' ', @nodes[0..$m-1]), "\n";

# generate one level of tree nodes:
sub gen_level {
    my $i = shift;
    my @nodes;
    $levels[$i] = \@nodes;
    for (@{ $levels[$i-1] }) {
        push @nodes, filter( L($_), R($_) );
    }
}

# calculate the left child:
sub L { 2*$_[0]+1 }

# calculate the right child:
sub R { 3*$_[0]+1 }

# filter out unvisited nodes and mark them as visited:
sub filter {
    my @nodes;
    for (@_) {
        next if $visited{$_};
        push @nodes, $_;
        $visited{$_} = 1;
    }
    return @nodes;
}

# examin through the specified level, accumulating
# the `$c' counter when necessary:
sub process_level {
    my ($i) = @_;
    my @nodes = @{ $levels[$i] };
    my $next_level_min = L($nodes[0]);
    for (@nodes) {
        if ($_ <= $next_level_min) {
            return if ++$c >= $m;
        }
    }
}

__END__

 ��һ������ M����֪ 1 ���� M�����Ҵ� x = 1 ���������
 x ���� M���� 2*x+1 �� 3*x+1 Ҳͬʱ���� M����Ҫ���д
 һ���㷨�������ҳ����� M ����С�� m ��Ԫ�ء�
