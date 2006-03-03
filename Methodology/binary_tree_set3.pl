#: binary_tree_set3.pl
#: algorithm proposed by our instructor Mao Qirong
#: Copyright (c) 2006 Agent Zhang
#: 2006-03-03 2006-03-03

use strict;
use warnings;

my $n = shift;
#warn "n = $n";
if (! defined $n or $n < 0) {
    die "No n specified or n is invalid.\n";
}

# (partially) store the set M and also the n minimals:
my @M = (1);

my ($p2, $p3) = (0, 0);
for my $i (1..$n-1) {
    my ($L, $R) = (L($p2), R($p3));
    if ($L < $R) {
        $M[$i] = $L;
        $p2++;
    } elsif ($R < $L) {
        $M[$i] = $R;
        $p3++;
    } else { # $R == $L
        $M[$i] = $L;
        $p2++; $p3++;
    }
}
print "@M" if $n > 0;
print "\n";

sub L {
    my $x = $M[shift];
    2*$x+1;
}

sub R {
    my $x = $M[shift];
    3*$x+1;
}

__END__

дһ���򣬰��ݾ��������ɼ��� M ����С n ����������
���Ǵ�ӡ������M �������£�

(1) 1 ���� M
(2) ������� x ���� M������ 2*x+1 ���� M �� 3*x+1
    ���� M.
(3) ���ޱ�������� M
