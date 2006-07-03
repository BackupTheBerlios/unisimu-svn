#basic.t - a script for testing function :
#GraphViz::Flowchart::Asm->graphviz();

#2006-07-02 2006-7-2

use GraphViz::Flowchart::Asm;
use File::Compare;
use Test::Base;
plan tests => 1 * blocks;

run {
	my $obj = GraphViz::Flowchart::Asm->new();

	my $block = shift;
	
	open F, ">tmp1";		
	print F $block->input;	
	close F;
	$obj->compile('tmp1');

	my $outfile = $block->outfile;
	my $tempfile;
	($tempfile = $outfile) =~ s/~//;
	open OF, ">$tempfile";
	my $gv = $obj->graphviz();
	print OF $gv->as_debug();
	close OF;
	is compare($tempfile, $outfile), 0, "debug file $outfile;";
	$gv->as_png("$outfile.png");
	

}


__DATA__

=== test 1
--- input
    encoding gb2312
    font     simsun.ttc

    start ��ʼ
    do    ����ʮ��·��
    test  �̵��Ƿ����ţ�
    jyes  L1
    do    ���̵�����
L1:
    do    ����ʮ��·��
    end   ����
--- outfile chomp
~tmp1

=== test 2
--- input
    encoding gb2312
    font     simsun.ttc

    test �е�������
    jyes L1
    do   ��ȴ����� 
L1:
    do   �� FIFO ��ȡ��һ��
    test �����������
    jno  L2
    do   ȡ�������
L2:
    test ��������У�
    jno  L3
    jyes L5
L5:
    do   ִ��֮
L3:
    test �����������
    jno  L4
    do   ���������
L4:
    do   ���ѵ�����

--- outfile chomp
~tmp2

=== test 3
--- input
    encoding gb2312
    font     simsun.ttc

    start ��ʼ
    do    ����ʮ��·��
    test  �̵��Ƿ����ţ�
    jyes  L1
    do    ���̵�����
L1:
    do    ����ʮ��·��
    end   ����
--- outfile chomp
~tmp3

=== test 4 : invalid string - top syntax error
--- input
    encoding gb2312
    font     simsun.ttc
    width    2
    height   6

    start ��ʼ����
L1:
    io    ����
    do    ���
    test  ������
    jno   L1
    end   �˳�
--- outfile chomp
~tmp4
