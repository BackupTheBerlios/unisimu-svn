#: 01test.t

use strict;
use warnings;

use Test::More tests => 168;
use Test::Deep;
#use Time::HiRes 'sleep';
BEGIN { use_ok('Interp::Newton::DiffQuots'); }

my $newton = Interp::Newton::DiffQuots->new(
    30 => '1/2',
    45 => 'sqrt(2)/2',
    60 => 'sqrt(3)/2',
);
ok $newton;
isa_ok $newton, 'Interp::Newton::DiffQuots';

my @Xs = (30,45,60);
my @Ys = qw!1/2 sqrt(2)/2 sqrt(3)/2!;
cmp_deeply [$newton->Xs], [@Xs];
cmp_deeply [$newton->Ys], [@Ys];
cmp_deeply [$newton->diff_quot],
  [
    [$newton->Ys],
    [qw!1/30*2^(1/2)-1/30 1/30*3^(1/2)-1/30*2^(1/2)!],
    [qw!1/900*3^(1/2)-1/450*2^(1/2)+1/900!],
  ];

$newton = Interp::Newton::DiffQuots->new(
    Xs => [30, 45, 60],
    Ys => ['1/2', 'sqrt(2)/2', 'sqrt(3)/2'],
);
ok $newton;
isa_ok $newton, 'Interp::Newton::DiffQuots';

cmp_deeply [$newton->Xs], [30,45,60];
cmp_deeply [$newton->Ys], [qw!1/2 sqrt(2)/2 sqrt(3)/2!];
cmp_deeply [$newton->diff_quot],
  [
    [$newton->Ys],
    [qw!1/30*2^(1/2)-1/30 1/30*3^(1/2)-1/30*2^(1/2)!],
    [qw!1/900*3^(1/2)-1/450*2^(1/2)+1/900!],
  ];

my $maple = $newton->maple();
ok $maple;
my $poly = $newton->polynomial or die $newton->error;
ok $poly;
foreach (0..@Xs-1) {
    is $maple->eval("testeq(eval($poly, x=$Xs[$_]), $Ys[$_])"), 'true';
}

ok $newton->test_polynomial($poly);
(my $poly2 = $poly) =~ s/2/3/;
ok !$newton->test_polynomial($poly2);
my $s = $maple->eval("$poly");
die $newton->error() unless defined $s;
print "\n*$s*\n";

for (1..50) {
    #sleep(0.1);
    my $count = int rand(20) + 2;
    my (@xs, @ys);
    my %xs;
    for (1..$count) {
        my $x = int rand(204);
        while (exists $xs{$x}) {
            $x = int rand(204);
        }
        $xs{$x} = 1;
        push @xs, $x;
        push @ys, int rand(204);
    }
    #warn "Xs = @xs\n";
    #warn "Ys = @ys\n";
    my $newton = Interp::Newton::DiffQuots->new(
        Xs => [@xs],
        Ys => [@ys],
    );
    ok $newton;
    $poly = $newton->polynomial;
    #warn $poly, "\n";
    ok $poly;
    my $res = $newton->test_polynomial($poly);
    ok $res, "@xs - @ys";
    #warn "  $poly\n";
}
