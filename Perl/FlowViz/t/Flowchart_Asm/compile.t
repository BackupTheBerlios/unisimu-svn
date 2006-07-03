#compile.t - a script for testing function compile of 
#GraphViz::Flowchart::Asm->compile
#2006-07-02 2006-07-02

use GraphViz::Flowchart::Asm;
use Test::Base;
plan tests => 2 * blocks();

sub filter {
	my $old = shift;
	$old =~ s/\n.*$//;
	return $old
}

run {
	my $block = shift;

	open F, ">tmp";		
	print F $block->input;	
	close F;
	
	my $stdout;
	
	tie_output(*STDERR, $stdout);
	$stdout ||= '';
	my $asm = GraphViz::Flowchart::Asm->new();
	
	is $asm->compile('tmp'), $block->expected;
	is filter($stdout), $block->tip, "error tip!";
};


__DATA__

=== test 1 : valid string 
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
--- expected chomp
1
--- tip

=== test 2 : valid string
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
--- expected chomp
1
--- tip

=== test 3 : invalid string - body syntax error
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
    ����

--- expected chomp
0
--- tip
syntax error: tmp: line 11: unknown instruction "����"

=== test 4 : invalid string - top syntax error
--- input
    encoding
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
--- expected chomp
0
--- tip
syntax error: tmp: line 1: unknown instruction "encoding"

=== test 5 : invalid string - top syntax error
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
    end
--- expected chomp
1
--- tip
