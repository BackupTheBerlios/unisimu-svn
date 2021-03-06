#: viewpod.pl
#: Pod Dynamic HTML Viewer
#: v0.03
#: Copyright (c) 2005 Agent Zhang
#: 2005-10-21 2005-12-02

use strict;
use warnings;
use Getopt::Std;
use Config;
use FindBin;

BEGIN {
    $ENV{CATALYST_ENGINE} ||= 'HTTP';
    $ENV{CATALYST_SCRIPT_GEN} = 19;
    #$ENV{COMPUTERNAME} = 'localhost';
    #$ENV{LOGONSERVER} = '\\localhost';
}

my %opts;
getopts('hfp:s:', \%opts);
my $fork = $opts{f} || 0;
my $port = $opts{p} || 3030;
my $cssfile = $opts{s} || "$Config{installhtmldir}/Active.css";

if ($opts{h}) {
    print <<"_EOC_";
Usage: $FindBin::Script [-f] [-d] [-s <css-file>] [-p <port-number>]

Options:
    -h         print this help
    -f         handle each request in a new process
               (defaults to false)
    -p <port>  specify port number (defaults to 3030) 
    -s <css>   specify css file

_EOC_
    exit(0);
}

########################################################

package ViewPod;

use strict;
use warnings;

use Pod::Html;
use Perl6::Slurp;
use Config;
use File::Spec;
#use Smart::Comments;
use Fcntl;
use POSIX qw(tmpnam);

use Catalyst qw/
    -Debug
    Static::Simple
    Session
    Session::Store::File
    Session::State::Cookie
    Textile
/;
our $VERSION = '0.03';

__PACKAGE__->config(
    name => 'ViewPod',
    home => '.',
    pod_dirs => [
        '.',
        'lib',
        "$Config{archlib}/Pod",
        $Config{installsitebin},
        $Config{archlib},
        $Config{installsitelib}
    ],
    pod_exts => [
        '.pod','','.pm','.pl','.bat'
    ],
);

__PACKAGE__->setup(qw/Static::Simple Textile/);

# forward to modlist by default
sub default : Private {
    my ( $self, $c ) = @_;
    $c->forward('/modlist');
}

# show error messages
sub err : Private {
    my ( $self, $c ) = @_;
    #my $html = $c->stash->{error};
    my $html = $c->textile->process($c->stash->{error});
    $c->res->output($html);
}

# show POD file with explicit path
sub showpath : Regex('^([A-Za-z]:[\\/].+\.(?:pod|bat|pm|pl))$') {
    my ( $self, $c ) = @_;
    my $file = $c->req->snippets->[0];
    my $dir = File::Spec->updir($file);
    $c->session->{dir} = '';
    $c->stash->{podfile} = $file;
    $c->forward('/podhtm');
}

# show the POD for a module
sub showmod : Regex('^(\w+(?:(?:::|-)\w+)*)$') {
    my ( $self, $c ) = @_;
    my $modname = $c->req->snippets->[0];
    $modname =~ s,-,::,g;
    $c->stash->{modname} = $modname;
    $c->forward('/findpod');
}

# show image files
sub showimg : Regex('(.*(\.png|\.jpg|\.gif|\.bmp))') {
    my ( $self, $c ) = @_;
    my $path = $c->session->{dir};
    my $img = $c->req->snippets->[0];
    my $type = $c->req->snippets->[1];
    $type =~ s/\.//;
    my $content = slurp '<:raw', "${path}${img}";
    warn "Content is empty!!!" if not $content;
    #warn "$path/$img : image/$img";
    $c->res->content_type("image/$type");
    $c->res->output($content);
}

# returns css file
sub cssfile : Regex('\.css') {
    my ( $self, $c ) = @_;
    $c->stash->{file} = $cssfile;
    $c->forward('/dumpfile');
}

# dump file out to the client side
sub dumpfile : Private {
    my ( $self, $c ) = @_;
    my $content = slurp( $c->stash->{file} );
    $c->res->output($content);
}

# locate POD file according to module name 
sub findpod : Private {
    my ( $self, $c ) = @_;
    my $modname = $c->stash->{modname};
    (my $file = $modname) =~ s,::,/,g;
    SEARCH:
    foreach my $dir (@{ $c->config->{pod_dirs} }) {
        foreach my $ext (@{ $c->config->{pod_exts} }) {
            my $temp = "$dir/$file".$ext;
            #warn "  Trying ext $ext...\n";
            if (-f $temp and has_pod($temp)) {
                $file = $temp;
                $c->session->{dir} = "$dir/";
                last SEARCH;
            }
        }
    }
    if (not -f $file) {
        $c->stash->{error} = "Module or POD $modname not found!";
        $c->forward('/err');
        return;
    }
    $c->stash->{podfile} = $file;
    $c->forward('/podhtm');
}

# check if a file contains POD directives
sub has_pod {
    my $file = shift;
    my $in;
    local $/ = "\n";
    return undef if not open $in, $file;
    while (<$in>) {
        if (/^=head1\s+/) {
            ### Woot! It actually contains POD!
            close $in;
            return 1;
        }
    }
    close $in;
    return undef;
}

# convert POD to HTML
sub podhtm : Private {
    my ( $self, $c ) = @_;
    my $infile = $c->stash->{podfile};
    my $outfile;
    my $fh;
    do { $outfile = tmpnam(); }
        until open $fh, ">$outfile";
    close $fh;
    pod2html($infile,
        "--backlink=Back to Top",
        "--htmlroot=QQQ",
        "--recurse",
        "--infile=$infile",
        "--outfile=$outfile",
        "--css=/Active.css",
        "--header",
        "--quiet",
    );
    unlink 'pod2htmd.tmp';
    unlink 'pod2htmi.tmp';
    my $html = slurp($outfile);
    $html =~ s, QQQ / ([\w/]+) \.html , adjust_url($1) ,gesx;
    unlink $outfile or warn "warning: Can't unlink $outfile";
    $c->res->output($html);
}

# adjust the URLs to other modules embedded in HTML doc
sub adjust_url {
    my $url = shift;
    $url =~ s,/,::,g;
    return "/$url";
}

# generate module list
sub modlist : Global {
    my ( $self, $c ) = @_;
    my $infile = "$Config{archlib}/perllocal.pod";
    my %modules;
    my $in;
    if (!open $in, $infile) {
        $c->stash->{error} = "Can't open $infile for reading: $!";
        $c->forward('/err');
        return;
    }
    my $name;
    while (<$in>) {
        if (/^=head2 (.+) C<Module> L<(.+)>/i) {
            $name = $2;
            $name =~ s/\|.*//;
            ### $name
            if (!$modules{$name}) {
                $modules{$name} = {
                    date => $1,
                    ver => 'I<unknown>',
                };
            }
        }
        elsif (/^C<VERSION:\s*(\S+)>/i) {
            next if !$name and !$modules{$name};
            $modules{$name}->{ver} = $1;
        }
    }
    close $in;
    $c->stash->{modlist} = \%modules;
    $c->forward('/show_modlist');
}

# display the module list by dumping HTML code
sub show_modlist : Private {
    my ( $self, $c ) = @_;
    my %modules = %{ $c->stash->{modlist} };
    my $html = <<'    _EOC_';
        <html>
        <head><title>Modules Installed</title>
        <link rel="stylesheet" href="/Active.css" type="text/css"/>
        </head>
        <body>
        <H1> Modules Installed on Your System </H1>
        <ul>
    _EOC_
    my $last_sp;
    my $count = 0;
    foreach my $name (sort keys %modules) {
        if (!$last_sp or namesp($name) ne $last_sp) {
            $html .= "<p>\n";
            $last_sp = namesp($name);
        }
        $html .= qq[    <li><a href="/$name"> $name&nbsp;&nbsp;&nbsp;&nbsp;
        $modules{$name}->{ver}</a></li>\n];
        $count++;
    }
    $html .= <<"    _EOC_";
        </ul>
        <p>
        <p>
        <hr><br><center>
        <font color=green><B>For Total $count Modules Installed.</B></font>
            </center>
        </body>
        </html>
    _EOC_
    $c->res->output($html);
}

# extract the outter namespace from module name
sub namesp {
    if ($_[0] =~ /\w+/) { return $&; }
    else                { return ''; }
}

############################################################

ViewPod->run( $port, 'localhost', {
     argv         => [],
    'fork'        => $fork,
} );
