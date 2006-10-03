#: paint.pl
#: �������ۡ���47ҳ��ϰ��һ����21��
#: ��ϼ�����
#: Agent2002. All rights reserved.
#: 2005-03-09 2005-03-10

use strict;
use warnings;
use Math::Combinatorics;

my @colors;
my $i = 0;
foreach (1..10) { $colors[$i++] = 'White'; }
foreach (1..4)  { $colors[$i++] = 'Black'; }
foreach (1..3)  { $colors[$i++] = 'Red';   }

my $combinat = Math::Combinatorics->new(
    count => 4 + 3 + 2,
    data  => [0..@colors-1],
);

my $freq  = 0;
my $total = 0;
while (my @comb = $combinat->next_combination) {
    ++$total;
    map { $_ = $colors[$_] } @comb;

    my ($wcount, $bcount, $rcount) = (0, 0, 0);
    map {
        ++$wcount if $_ eq 'White';
        ++$bcount if $_ eq 'Black';
        ++$rcount if $_ eq 'Red';
    } @comb;

    if ($wcount == 4 and $bcount == 3 and $rcount == 2) {
        ++$freq;
    }
}

print "The probability is $freq/$total = ",
    trim($freq/$total),
    " (", C(10,4) * C(4,3) * C(3,2), "/",
    C(17, 4+3+2), " expected).\n";

sub C { # Compute the combination number
    my ($n, $m) = @_;
    return fac($n) / (fac($m) * fac($n - $m));
}

sub fac { # Compute the factorial of n, say, n!
    my $n = shift;
    return 1 if $n == 0;
    my $res = 1;
    foreach my $i (2..$n) {
        $res *= $i;
    }
    return $res;
}

sub trim {
    return sprintf("%.4f", $_[0]);
}

__END__

21. ĳ���ṫ˾���� 17 Ͱ�����а��� 10 Ͱ������ 4 Ͱ������ 3 Ͱ�� �ڰ�
�������б�ǩ���䣬���������⽫��Щ���ᷢ���˿ͣ���һ���� 4 Ͱ���ᣬ
3 Ͱ����� 2 Ͱ����Ĺ˿ͣ��ܰ�������ɫ�����õ������ĸ����Ƕ��٣�
