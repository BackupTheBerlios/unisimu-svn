#: if.t

use t::Kid_Maple;

plan tests => 1 * blocks();

filters {
    maple => 'unindent',
};

run_tests;

__DATA__

=== TEST 1
--- kid
if (x > 5) { x:=x+1 }
--- maple
if x>5 then
    x:=x+1;
end if;



=== TEST 2
--- kid
if (x + 3*(y - 6.7)<= 4*x/(52.1 - 3) ) {
    y := x-5 + y;
    x := x - y;
}
--- maple
if x+3*(y-6.7)<=4*x/(52.1-3) then
    y:=x-5+y;
    x:=x-y;
end if;



=== TEST 3
--- kid
if (5 <> x) { x:= 3; } else {
    y:=x-1; x:=x+1 }
--- maple
if 5<>x then
    x:=3;
else
    y:=x-1;
    x:=x+1;
end if;




=== TEST 4
--- kid
if (x > 0) {
    x := x + 2;
    if (x < y) {
        y := x;
    }
} else {
    if (y + 3 < x * 5) {
        y := x / 2
    } else {
        y := y + 1
    }
}
--- maple
if x>0 then
    x:=x+2;
        if x<y then
            y:=x;
        end if;
    else
        if y+3<x*5 then
            y:=x/2;
        else
            y:=y+1;
        end if;
end if;



=== TEST 5
--- kid
if (6.3<= 0.232) {
    x:=2;
}
if (5 = x_) { yylex:=1 }
--- maple
if 6.3<=0.232 then
    x:=2;
end if;
if 5=x_ then
    yylex:=1;
end if;



=== TEST 6
--- kid
if (x>0) x:=5
--- maple
if x>0 then
    x:=5;
end if;



=== TEST 7
--- kid
if (x>0) { x:=5 } else y:=1
--- maple
if x>0 then
    x:=5;
else
    y:=1;
end if;



=== TEST 8
--- kid
if (x>0)
    if (y>0)
        a:=1
    else if (y<0)
        a:=2
else
    a:=3
--- maple
if x>0 then
    if y>0 then
        a:=1;
    else
        if y<0 then
            a:=2;
        else
            a:=3;
        end if;
    end if;
end if;



=== TEST 9
--- kid
if (x>0) {
    if (y>0)
        a:=1
    else if (y<0)
        a:=2
} else
    a:=3
--- maple
if x>0 then
    if y>0 then
        a:=1;
    else
        if y<0 then
            a:=2;
        end if;
    end if;
else
    a:=3;
end if;
