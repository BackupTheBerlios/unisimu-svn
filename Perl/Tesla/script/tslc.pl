#: tslc.pl
#: Tesla Compiler which gerates Perl code
#:   that uses the Tesla simulation library
#: Tesla v0.05
#: Agent2002. All rights reserved.
#: 04-11-08 04-12-09

use strict;
use warnings;
use Getopt::Std;

my $VERSION = '0.05';

my %opts;
getopts( 'ho:', \%opts );

usage(0) if $opts{h};
unless (@ARGV) {
    warn "No input file specified.\n\n";
    usage(1);
}

my ($infile, $outfile);

$infile = shift @ARGV;
if ($opts{o}) {
    $outfile = $opts{o};
} else {
    $outfile = $infile;
    $outfile =~ s/\.tsl$/.pl/i or 
        $outfile =~ s/\.tm$/.pm/i or
        $outfile .= '.pl';
}

sub usage {
    my $ret = shift;
    $ret = 0 unless defined $ret;

    my $msg = <<"_EOC_";
Tesla Script Compiler v$VERSION
Agent2002. All rights reserved.

Usage: tslc [-h] [-o outfile] infile
Options:
    -h              Print this help to STDOUT.
    -o outfile      Specify outfile as output file, or
                    tslc would deduce the name from
                    infile.

Report bugs to Agent2002 <agent2002\@126.com>.
_EOC_

    if ($ret == 0) {
        print $msg;
    } else {
        warn $msg;
    }
    exit($ret);
}

my $counter = 0;
sub gennum {
    return ++$counter;
}

my $numpat = qr/(?:\.\d+|\d+(?:\.\d*)?)/;
my $idlistpat  = qr/(?:\w+(?:\s*,\s*\w+)*)/;
my $idlistpat2 = qr/(?:\w+(?:\s*[,;]\s*\w+)*)/;
my $eventpat = qr/(?:[01UXZ]\s*\@\s*$numpat)/;
my $eventlistpat = qr/(?:$eventpat(?:\s*,\s*$eventpat)*)/;

open( my $in, $infile ) or
    die "Fatal error: Can't open $infile for reading: $!\n";

my %Signals; # symbol table for global signal objects
my %signals; # symbol table for signal objects in components
my %Comps; # symbol table for components

my $in_comp = 0; # indicate whether in a component definition body
my $compname;

my $tarcode; # stores the target Perl code
my $time = localtime;
$tarcode = <<"_EOC_";
# This file was generated by tslc at $time

use strict;
use warnings;
use Tesla;

_EOC_

while (<$in>) {
    if (m/^\s* perl \s+ (.*)/x) {
        output( "$1\n" );
        next;
    }
   
    # remove VHDL-style comment:
    s/--.*//g;
    
    next if m/^\s*$/;
    
    if (m/^\s* debug \s*;\s*/x) {
        output( <<'_EOC_' );
$Signal::DEBUG = 1;
$Clock::DEBUG = 1;
$Gate::DEBUG = 1;
_EOC_
        next;
    }
    if (m/^\s* nodebug \s*;\s*/x) {
        output( <<'_EOC_' );
$Signal::DEBUG = 0;
$Clock::DEBUG = 0;
$Gate::DEBUG = 0;
_EOC_
        next;
    }

    if (m/^\s* library \s+ (\S+) \s*;\s*$/x) {
        output( "use $1;\n" );
        next;
    }
    if (m/^\s* run \s+ ($numpat) \s*;\s*$/x) {
        error( "This command is not allowed in component body." )
            if $in_comp;
        output( "Tesla->run($1);\n" );
        next;
    }
    if (m/^\s* print \s+ "(.*)" \s*;\s*$/x) {
        output( qq/print "$1\n";\n/ );
        next;
    }
    if (m/^\s* dump \s+ ($idlistpat) \s*;\s*$/x) {
        my @sigs = split( /\s*,\s*/, $1 );
        foreach my $sig (@sigs) {
            if (!$in_comp and !exists $Signals{$sig}) {
                error( "Undefined global signal $sig." );
            }
            if ($in_comp and !exists $signals{$sig}) {
                error( "Undefined local signal $sig." );
            }
            output( "\$${sig}->dump;\n" );
        }
        next;
    }
    if (m/^\s* history \s+ ($idlistpat) \s*;\s*$/x) {
        error( "This command is not allowed in component body." )
            if $in_comp;

        my @sigs = split( /\s*,\s*/, $1 );
        foreach my $sig (@sigs) {
            if (!exists $Signals{$sig}) {
                error( "Undefined signal $sig." );
            }
            output( 
                qq/print \$${sig}->name, " : ", \$${sig}->histp, "\\n";\n/
            );
        }
        output( qq/print "\n";\n/ );
        next;
    }
    if (m/^\s* reset \s*;\s*$/x) {
        error( "This command is not allowed in component body." )
            if $in_comp;
        output( "Tesla->reset;\n" );
        next;
    }
    if (m/^\s* force \s+ (\w+) \s+ (\w+) \s*;\s*$/x) {
        my ($sig, $val) = ($1, $2);
        if (!$in_comp and !exists $Signals{$sig}) {
            error( "Global signal $sig undefined." );
        }
        if ($in_comp and !exists $signals{$sig}) {
            error( "Local signal $sig undefined." );
        }
        output( "\$${sig}->force('$val');\n" );
        next;
    }
    if (m/^\s* clear \s*;\s*$/x) {
        error( "This command is not allowed in component body." )
            if $in_comp;
        output( "Tesla->clear;\n" );
        next;
    }
    if (m/^\s* component \s* (\w+) \s*;\s*/x) {
        $Comps{$1} = $. unless $Comps{$1};
        next;
    }
    if (m/^\s* component \s* (\w+) \s*
            \( \s* ($idlistpat2) \s* \) \s*$/x) {
        error( "Components can't be nested." )
            if $in_comp;

        my $comp = $1;
        my @sigs = split( /\s*[,;]\s*/, $2 );
        my $nargs = @sigs;

        if (exists $Comps{$comp}) {
            error( "Component $comp redefined.\n\t".
                   "Refer to the earlier definition ".
                   "on line ".$Comps{$comp}."."
            );
        }
        $Comps{$comp} = $.;

        map { $signals{$_} = $. } @sigs;
        
        my @vars = map {"\$$_"} @sigs;
        local $" = ',';
        output( <<"_EOC_" );
sub $comp {
    if (\@_ != $nargs) {
        my (\$package, \$filename, \$line) = caller;
        die "\$filename(\$line): error: ".
            "Component $comp expects $nargs arguments.\\n";
    }
    my (@vars) = \@_;
_EOC_
        $in_comp = 1;
        $compname = $comp;
        next;
    }
    if (m/^\s* end \s+ component \s*;\s*$/x) {
        error( "Suspended 'end component' command." )
            unless $in_comp;
        output( "}\n" );
        $in_comp = 0;
        undef $compname;
        undef %signals;
        next;
    }
    if (m/^\s* signal \s+ ($idlistpat) \s*;\s*$/x) {
        my @idlist = split( /\s*,\s*/, $1 );
        foreach my $id (@idlist) {
            if ( !$in_comp and exists $Signals{$id}) {
                warning( "Signal $id redefined.\n\t".
                       "Refer to the earlier definition on line ".
                       $Signals{$id}."." );
                next;
            }
            $Signals{$id} = $. if !$in_comp;

            if ( $in_comp and exists $signals{$id}) {
                warning( "Signal $id redefined.\n\t".
                       "Refer to the earlier definition on line ".
                       $Signals{$id}."." );
                next;
            }
            $signals{$id} = $. if $in_comp;
            my $signame;
            if ($in_comp) { $signame = "${compname}::$id"; }
            else { $signame = $id; }
            
            output( qq/my \$$id = Signal->new("$signame");\n/ );
        }
        next;
    }
    if (m/^\s* (\w+) \s* : \s* ($numpat) \s*;\s*$/x) {
        output( qq/\$${1}::delay = $2;\n/ );
        next;
    }
    if (m/^\s* (\w+) \s* <= \s*
            (\w+) \s* \( \s* ($idlistpat) \s* \) \s*
            (?: after \s+ ($numpat) \s* )?;?\s*$/x) {
        my $output = $1;
        my $gateclass = $2;
        my @inputs = split( /\s*,\s*/, $3 );
        my $delay = defined($4)? $4 : '';

        if (!$in_comp and !exists $Signals{$output}) {
            error( "Output signal $output undefined." );
        }
        if ($in_comp and !exists $signals{$output}) {
            error( "Output signal $output undefined." );
        }

        if ( $delay and $delay < 0) {
            error( "Gate delay can't be negative." );
        }

        my @vars = map { "\$$_" } @inputs;
        my $gateid = 'gate'.gennum();
        local $" = ',';
        output( <<"_EOC_" );
my \$$gateid = ${gateclass}->new($delay);
\$${gateid}->output(\$$output);
\$${gateid}->inputs(@vars);
_EOC_
        foreach my $input (@inputs) {
            if (!$in_comp and !exists $Signals{$input}) {
                error( "Input signal $input undefined." );
            }
            if ($in_comp and !exists $signals{$input}) {
                error( "Input signal $input undefined." );
            }
            output( qq/\$${input}->add_dest(\$$gateid);\n/ );
        }
        next;
    }
    if (m/^\s* (\w+) \s* <= \s*
            \[ \s* ($eventlistpat) \s* \] \s*;\s*$/x) {
        my $rsyms;
        if ($in_comp) { $rsyms = \%signals; }
        else { $rsyms = \%Signals; }
        my $sig = $1;
        my @events = split( /\s*,\s*/, $2 );

        gen_sig_events( $rsyms, $sig, @events );
        next;
    }
    if (m/^\s* (\w+) \s* <= \s*
            \[ \s* ($eventpat) \s*,\s* ($eventpat) \s* \] \s*
            -repeat \s+ (\d+) \s* (?:\s+ -step \s+ ($numpat) \s*)?;\s*$/x) {
        my $sig = $1;
        my ($event1, $event2) = ($2, $3);
        my $count = $4;
        my $period = $5;
        
        my $rsyms;
        if ($in_comp) { $rsyms = \%signals; }
        else { $rsyms = \%Signals; }

  
        my ($val1,$tm1) = split( /\s*\@\s*/, $event1 );
        my ($val2,$tm2) = split( /\s*\@\s*/, $event2 );
        $period = ($tm2 - $tm1) * 2 unless defined $period;

        my @events;
        foreach (1..$count) {
            push @events, "${val1}\@${tm1}", "${val2}\@${tm2}";
            $tm1 += $period;
            $tm2 += $period;
        }
        
        gen_sig_events( $rsyms, $sig, @events );
        next;
    }
    if (m/^\s* (\w+) \s* \( \s* ($idlistpat2) \s* \) \s*;\s*$/x) {
        my $comp = $1;
        my @sigs = split( /\s*[,;]\s*/, $2 );
        if (!exists $Comps{$comp}) {
            warning( "Component $comp used without declaration." );
        }
        foreach my $sig (@sigs) {
            if (!$in_comp and !exists $Signals{$sig}) {
                error( "Global signal $sig undefined." );
            }
            if ($in_comp and !exists $signals{$sig}) {
                error( "Local signal $sig undefined." );
            }
        }
        my @vars = map { "\$$_" } @sigs;
        local $" = ',';
        output( "$comp(@vars);\n" );
        next;
    }

    error( "Syntax error.\n" );
}

sub error {
    die "$infile($.): error: $_[0]\n";
}

sub warning {
    warn "$infile($.): warning: $_[0]\n";
}

sub output {
    $tarcode .= <<"_EOC_";
#line $. "$infile"
$_[0]
_EOC_
}

sub gen_sig_events {
    my $rsyms = shift;
    my $sig   = shift;
    my @events = @_;
    
    if (!defined $rsyms->{$sig}) {
       error( "Signal $sig undefined" );
    }
    my (@vals, @times);
    foreach my $event (@events) {
        my ($val, $time) = split( /\s*\@\s*/, $event );
        push @vals, "'$val'";
        push @times, $time;
    }
    local $" = ',';
    output(
        qq/Tesla->schedule( [@times] => \$$sig => [@vals] );\n/
    );
}

if ($outfile =~ m/\.pm$/) {
    $tarcode .= "1;\n";
} else {
    $tarcode .= "0;\n";
}

open my $out, ">$outfile" or
    die "Fatal error: Can't open '$outfile' for writing: $!";
print $out $tarcode;
close $out;
print "$outfile generated.\n";

0;
