#: partn.pl
#: 2005-10-23 2005-11-13

use warnings;
use strict;
use HTTP::Server::Simple;

$MyServer::count = 0;
my $server = MyServer->new();
$server->run();

package MyServer;
use warnings;
use strict;
use Config;
use URI::Escape;
use GD::Stack;
use Dynamic::Partition;

use base qw(HTTP::Server::Simple::CGI);
our $stack;

my $old_uri = '';
our $count;

no strict 'refs';

our %process = ();
our ($pkg, $req_tb, $free_tb);
BEGIN {
    $pkg = 'Dynamic::Partition';
    $req_tb  = "${pkg}::ReqTable";
    $free_tb = "${pkg}::FreeTable";
}

sub assign {
    my ($pid, $addr, $sz) = @_;
    warn "assign @_...\n";
    restart() if !defined $stack;
    $process{$pid}->{addr} = $addr;
    $stack->draw_used_block(@_);
}

sub restart {
    @$req_tb  = ();
    @$free_tb = ({ addr => 0, size => 100 });
    %process = ();
    $stack = GD::Stack->new(100,180,450);
}

sub new_process {
    my ($pid, $size) = @_;
    no strict 'refs';

    return undef if $process{$pid};
    $process{$pid} = { size => $size };
    push @$req_tb, { pid => $pid, size => $size };
    dispatch();
    map { $stack->recycle($_->{addr}, $_->{size}); } @$free_tb;
	return 1;
}

sub delete_process {
    my $pid = shift;
    my ($addr, $size) =
        ($process{$pid}->{addr}, $process{$pid}->{size});
    if ($process{$pid}) {
        warn "Release process $pid...\n";
        $pkg->recycle($pid, $addr, $size);
        delete $process{$pid} ;
        map { $stack->recycle($_->{addr}, $_->{size}); } @$free_tb;
        dispatch();
    }
}

our $code = 'restart';

sub handle_request {
    my ($self, $cgi) = @_;     #... do something, print output to default
    my $base = $cgi->url;
    $base = quotemeta($base);
    #warn "base = $base\n";
    my $url = $cgi->self_url;
    $url =~ s,^$base/,,;
    $url = uri_unescape($url);
    $url = '' if !$url;
    if ($url =~ m/\.png$/i) {
        send_png($cgi);
        return;
    }
    restart() if !$stack;
    if ($url !~ m/request/) {
        warn "No request\n";
        #$code = 'restart';
    } elsif (!$cgi->param('refresh')) {
        warn "Get request!\n";
        #my @names = $cgi->param;
        #warn "Fields: @names\n";
        $code = '';
        if ($cgi->param('restart')) {
            $code = 'restart';
            restart();
        } elsif ($cgi->param('submit')) {
            my $pid = $cgi->param('new');
            my $size = $cgi->param('size');
            if ($pid and $size) {
                if (new_process($pid, $size)) {
	                $code = "new($pid, $size)";
				} else {
					$code = "process $pid already exists";
				}
            }
            $pid = $cgi->param('del');
            if ($pid) {
                delete_process($pid);
                $code .= ' and ' if $code;
                $code .= "del($pid)";
            }
        }
    }
    warn "Refresh PNG output...\n";
    $stack->as_png('tmp.png');

    print "HTTP/1.0 200 OK\n";
    print $cgi->header(-type=>'text/html');
    my $time = time();
    my @reqs = map { $_->{pid} } @$req_tb;
    my $reqs = join(' ', @reqs);
    print <<_EOC_;
<html>
<head>
  <title>
    Dynamic Partition Demonstration
  </title>
</head>
<body>
    <table>
	<tr>
	<td align="center"> RAM </td>
	</tr>
	<tr>
    <td>
    <img src="tmp$time.png">
    </td>
	<td width="50"/>
    <td align="right">
    <B>This is a CGI demonstration for Memory Dynamic Partition.</B>
    <form id=form1 name=form1 action="request" method=post>
    <table>
        <tr> <td> Request Table: </td> <td> $reqs </td> </tr>
        <tr> <td> Last Operation: </td><td> <B>$code</B> </td> </tr>
        <tr>
        <td> Create Process </td>
        <td><INPUT class=InputBox name="new" style="WIDTH: 50px"></td>
        <td> of Size </td>
        <td><input class=InputBox name="size" style="WIDTH: 50px"></td>
        <td> (for total 100 MB) </td>
        </tr>
        <tr>
        <td> Release Process </td>
        <td><INPUT class=InputBox name="del" style="WIDTH: 50px"></td>
        </tr>
        <tr>
        <td align=left>
          <input class=Button1 name="submit" type=submit value="submit"> 
        </td>
        <td>
          <input class=Button1 name="refresh" type=submit value="refresh"> 
		</td>
		<td>
          <input class=Button1 name="restart" type=submit value="restart"> 
        </td>
        </tr>
    </table>
    </form>
    </td>
    </tr>
</table>
<p>
<p>
<p>
	<table align="left">
	<tr>
	<td>
		<font color="#010166"><I>Powered by Perl HTTP::Server::Simple::CGI</I></font>
	</td>
	</tr>
</table>
</body>
</html>
_EOC_
}

sub send_png {
    my $cgi = shift;
    binmode \*STDOUT;
    open my $in, 'tmp.png' or
        return undef;
    binmode $in;
    local $/;
    my $data = <$in>;
    print "HTTP/1.0 200 OK\n";
    print $cgi->header(
        -type=>'image/png',
        -expires=>'0');
    print $data;
}

sub dispatch {
    $pkg->first_fit(sub { assign(@_) });
}
