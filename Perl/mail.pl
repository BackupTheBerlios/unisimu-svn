# mail.pl

use strict;
use warnings;
use Net::SMTP_auth;

my $smtp = Net::SMTP_auth->new(
    #Hello => 'agent2002:840424',
    'smtp.126.com',
    Timeout => 60,
    Debug => 1,
);
$smtp->auth('LOGIN', 'agent2002', '840424');
$smtp->mail('agent2002@126.com');
$smtp->to('agentz@tom.com');
#$smtp->to('zhongxiang721@163.com');
$smtp->data();
$smtp->datasend("Subject:  ͨ�� Perl �ű��Զ����͵ĵ����ʼ�\n");
$smtp->datasend("From: ���ഺ\n");
$smtp->datasend("To: ��ΰ��\n");
$smtp->datasend("\n");
my $text = <<'_EOC_';
����~~

�����ڳɹ��ˣ��������ʼ�����ͨ�� CPAN ģ�� Net::SMTP_auth ��
�����͵ġ�

ԭ�������Գ��� Net::STMP ��֧�����ǹ��� SMTP �� LOGIN��PLAIN
�� NTLM ��֤��ʽ���������ڲ��Ե�ʱ�򣬺���һ���������յ���������
������ʾ��

    535 Error: authentication failed

�������� CPAN �н���������һ���ӱ��ҵ��˿ɰ��� Net::STMP_auth
ģ�顣���̳��� Net::STMP�������ṩ����Ч�� authentication ����
����������ȡ���˳ɹ���

�ҵĳ����Դ����������ʾ��

    use Net::SMTP_auth;

    my $smtp = Net::SMTP_auth->new(
        #Hello => 'agent2002:840424',
        'smtp.126.com',
        Timeout => 60,
        Debug => 1,
    );
    $smtp->auth('LOGIN', 'agent2002', '840424');
    $smtp->mail('agent2002@126.com');
    $smtp->to('agentz@tom.com');
    #$smtp->to('zhongxiang721@163.com');
    $smtp->data();
    $smtp->datasend("Subject:  ͨ�� Perl �ű��Զ����͵ĵ����ʼ�\n");
    $smtp->datasend("From: ���ഺ\n");
    $smtp->datasend("To: ��ΰ��\n");
    $smtp->datasend("\n");
    my $text = <<'_EOC_';
        ����~~

        �����ڳɹ��ˣ��������ʼ�����ͨ�� CPAN ģ�� Net::SMTP_auth ��
        �����͵ġ�

        ...

            ���ഺ
    _EOC_

    open my $in, '<', \$text;
    while (<$in>) {
        $smtp->datasend($_);
    }
    close $in;

    $smtp->dataend();
    $smtp->quit;

�ܼ򵥣�����ô�������ǳ�������ʱ�����ĵ��������

    <<< 220 126.com Coremail SMTP(Anti Spam) System
    >>> EHLO localhost.localdomain
    <<< 250-mail
    <<< 250-PIPELINING
    <<< 250-AUTH LOGIN PLAIN NTLM
    <<< 250-AUTH=LOGIN PLAIN NTLM
    <<< 250 8BITMIME
    >>> AUTH LOGIN
    <<< 334 dXNlcm5hbWU6
    >>> YWdlbnQyMDAy
    <<< 334 UGFzc3dvcmQ6
    >>> ODQwNDI0
    <<< 235 Authentication successful
    >>> MAIL FROM:<agent2002@126.com>
    <<< 250 Mail OK
    >>> RCPT TO:<agentz@tom.com>
    <<< 250 Mail OK
    >>> DATA
    <<< 354 End data with <CR><LF>.<CR><LF>
    >>> Subject:  ͨ�� Perl �ű��Զ����͵ĵ����ʼ�
    >>> From: ���ഺ
    >>> To: ��ΰ��
    >>> ����~~
    >>> �����ڳɹ��ˣ��������ʼ�����ͨ�� CPAN ģ�� Net::SMTP_auth ��
    ...
    >>> ���ˡ�
    >>> �úøɣ�
    >>>     ���ഺ
    >>> .
    <<< 250 Mail OK queued as smtp4,agBJE9W4hkO4_MkB.2

    >>> QUIT
    <<< 221 Bye

�Ǻǣ�126 �� SMTP ��������󻹸���˵ Bye �أ����ǹ����Ի��ġ�:=)

���������ڲ���������ͨ����ģ�鷢�ͺ��и����ĵ����ʼ��Լ�
�Ƿ���Է��� HTML ���롣��Щ���⻹�ǽ�����ȥ���ɡ�����û�и����ʱ������
���ˡ�

�úøɣ�

    ���ഺ

_EOC_

open my $in, '<', \$text;
while (<$in>) {
    $smtp->datasend($_);
}
close $in;

$smtp->dataend();
$smtp->quit;
