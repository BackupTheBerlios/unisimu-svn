#: mail.pl
#: Send email via SMTP server automatically
#: Copyright (c) 2005 Agent Zhang
#: 2005-11-25 2005-11-25

use strict;
use warnings;
use Net::SMTP;
use Authen::SASL qw(Perl);

my ($user, $password) = ('agent2002', '840424');

my $sasl = Authen::SASL->new(
    mechanism => 'LOGIN',
    callback  => {
      user => $user,
      pass => $password,
    },
);

my $smtp = Net::SMTP->new(
    'smtp.126.com',
    Timeout => 60,
    Debug => 1,
);
$smtp->auth($sasl);
$smtp->mail('agent2002@126.com');
#$smtp->to('zhongxiang721@163.com');
$smtp->to('real_agent2002@163.com');
#$smtp->to('agent2002@126.com');
$smtp->data();
$smtp->datasend("From: ���ഺ [agent2002\@126.com]\n");
my $time = localtime;
$smtp->datasend("Sent: $time\n");
$smtp->datasend("To: ��ΰ��\n");
$smtp->datasend("Subject:  ͨ�� Perl �ű��Զ����͵ĵ����ʼ�\n");
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

    my ($user, $password) = ('agent2002', '123456');

    my $smtp = Net::SMTP_auth->new(
        'smtp.126.com',
        Timeout => 60,
        Debug => 1,
    );
    $smtp->auth('LOGIN', $user, $password);
    $smtp->mail('agent2002@126.com');
    $smtp->to('zhongxiang721@163.com');
    $smtp->data();
    $smtp->datasend("From: ���ഺ [agent2002\@126.com]\n");
    my $time = localtime;
    $smtp->datasend("Sent: $time\n");
    $smtp->datasend("To: ��ΰ��\n");
    $smtp->datasend("Subject:  ͨ�� Perl �ű��Զ����͵ĵ����ʼ�\n");
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
    >>> RCPT TO:<zhongxiang721@163.com>
    <<< 250 Mail OK
    >>> DATA
    <<< 354 End data with <CR><LF>.<CR><LF>
    >>> From: ���ഺ [agent2002@126.com]
    >>> Sent: Fri Nov 25 16:06:02 2005
    >>> To: ��ΰ��
    >>> Subject:  ͨ�� Perl �ű��Զ����͵ĵ����ʼ�
    >>> ����~~
    >>> �����ڳɹ��ˣ��������ʼ�����ͨ�� CPAN ģ�� Net::SMTP_auth
    ...
    >>> ���ˡ�
    >>> �úøɣ�
    >>>     ���ഺ
    >>> .
    <<< 250 Mail OK queued as smtp4,agBJE9W4hkO4_MkB.2

    >>> QUIT
    <<< 221 Bye

�Ǻǣ�126 �� SMTP ��������󻹸���˵ Bye �أ����ǹ����Ի��ġ�:=)

��һ��ǳ���Ҫ�������������ǿ�����Ǿ��� 163 ����ķ���������ǿ��Ҫ��
�����ʼ���From �ֶ��а��������˵ĵ��������ַ������ 163 ���Զ����š�
�����������ʹ�õ���

    From: ���ഺ

������

    From: ���ഺ [agent2002@126.com]

163 ������Զ����š������Ҫע�⡣�����ԣ�126 ����û�����֡�����Ҫ�󡱡�

���������ڲ���������ͨ����ģ�鷢�ͺ��и����ĵ����ʼ��Լ��Ƿ���Է���
HTML ���롣��Щ���⻹�ǽ�����ȥ���ɡ�����û�и����ʱ�����о��ˡ�

�úøɰɣ�

    ���ഺ
_EOC_

open my $in, '<', \$text;
while (<$in>) {
    $smtp->datasend($_);
}
close $in;

$smtp->dataend();
$smtp->quit;
