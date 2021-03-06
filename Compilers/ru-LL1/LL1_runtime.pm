#: LL1_runtime.pm
#: Common runtime for LL(1) parsers generated
#: Copyright (c) 2006 Agent Zhang
#: 2006-06-05 2006-06-17

package LL1::Runtime;

use strict;
use warnings;
use LL1;

our ($Error);

# test whether the given token can be matched
sub match_token ($) {
    my $token = $_[0];
    my $s = $X::str;
    pos($s) = $X::pos;
    if ($s =~ /\G\s+/ogc) {
        $X::pos += length($&);
    }
    local $_ = $token;
    if (/^\/(.*)\/$/o) {
        if ($s =~ /\G(?:$1)/gc) {
            $X::pos = pos($s);
            return $&;
        }
    }
    elsif (/^['"](.*)['"]$/o) {
        my $des = eval $_;
        if (substr($s, pos($s), length($des)) eq $des) {
            $X::pos += length($des);
            return $des;
        }
    }
    else {
        #warn caller(1);
        #warn @$_;
        die "match_token: invalid token pattern: $_";
    }
    undef;
}

# lexer used by LL(1) parsers
sub get_token () {
    if (defined match_token(LL1::eof)) {
        $X::raw = '';
        return LL1::eof();
    }
    my $saved_pos = $X::pos;
    my ($best_pos, $best_raw, $best_token);
    for my $token (@$X::tokens) {
        #warn "$token";
        my $raw = match_token($token);
        if (defined $raw) {
            if (!defined $best_pos or $X::pos > $best_pos) {
                $best_raw   = $raw;
                $best_pos   = $X::pos;
                $best_token = $token;
            }
            $X::pos = $saved_pos;
        }
    }
    if ($best_token) {
        $X::raw = $best_raw;
        $X::pos = $best_pos;
        return $best_token;
    }
    $X::raw = match_token(LL1::err());
    LL1::err();
}

#
# tracing facilities:
#

sub try ($$) {
    return if !$::LL1_TRACE;
    my ($expect, $pos) = @_;
    my $next = substr($X::str, $pos, 15);
    $next =~ s/\n/\\n/g;
    $next =~ s/\t/\\t/g;
    if (length(substr $X::str, $pos) > 15) {
        $next .= '...';
    }
    print "trying $expect...    [$next]\n";
}

sub success ($) {
    return if !$::LL1_TRACE;
    my $expect = $_[0];
    print "  >>MATCH<< $expect with '$X::raw'\n";
}

sub generate ($$) {
    return if !$::LL1_TRACE;
    my ($expect, $production) = @_;
    print "  generate { $expect -> @$production }\n";
}

#
# evaluate the LL(1) parsing table (i.e. do the parsing bit)
#

sub eval_table ($$) {
    my ($table, $start_rule) = @_;
    my $eof = LL1::eof();
    my $saved_pos = $X::pos;
    my $input = get_token();
    if ($::LL1_TRACE) { print "  read token $input\n"; }
    my @parse_stack = ($eof, $start_rule);
    while ($parse_stack[-1] ne $eof or $input ne $eof) {
        my $expect = $parse_stack[-1];
        try($expect, $saved_pos);
        if ($expect =~ /^['"\/]/o) {
            # expecting a terminal:
            if ($input eq $expect) {
                # matched the terminal
                success($expect);
                pop @parse_stack;
                $saved_pos = $X::pos;
                $input = get_token();
                if ($::LL1_TRACE) { print "  read token $input\n"; }
            } else {
                my $got = $input eq $eof ? 'EOF' : "'$X::raw'";
                $expect = 'EOF' if $expect eq $eof;
                $Error =
                    "Was expecting $expect, but found $got instead";
                $X::pos = $saved_pos;
                return undef;
            }
        } else { # expecting a nonterminal:
            my $production = $table->{$expect}->{$input};
            if ($production) {
                # generate
                generate($expect, $production);
                pop @parse_stack;
                push @parse_stack, reverse @$production;
            } else {
                my $got = $input eq $eof ? 'EOF' : "'$X::raw'";
                $expect = 'EOF' if $expect eq $eof;
                $Error = "Was expecting $expect, but found $got instead";
                $X::pos = $saved_pos;
                return undef;
            }
        }
    } # while
    if ($::LL1_TRACE) { print "  >>ACCEPT<<\n"; }
    return 1;
}

1;
