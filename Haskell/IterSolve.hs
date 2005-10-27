-- IterSolve.hs
-- Evaluate the root of an equation using
--   Simple Iteration Method
-- Copyright (c) 2005 Agent Zhang
-- 2005-09-18 2005-09-19

module IterSolve where

repeat' x next = x : repeat' (next x) next

isolve x0 next cond = cond $ repeat' x0 next

within eps (a:a':as)
    | abs(a-a') <= eps = a'
    | otherwise        = within eps (a':as)

within' eps (a:a':as)
    | abs(a-a') <= eps = 1
    | otherwise        = 1 + within' eps (a':as)

relative eps (a:a':as)
    | abs(a-a') <= eps * abs a' = a'
    | otherwise                 = relative eps (a':as)

relative' eps (a:a':as)
    | abs(a-a') <= eps * abs a' = 1
    | otherwise                 = 1 + relative' eps (a':as)

fi x = sqrt (2*x + 3)

test1 = isolve 4 fi (within 0.01)
test1' = isolve 4 fi (within' 0.01)

fi' x = 1/2 * (x^2 - 3)

test2 = isolve 4 fi' (within 0.01)
test2' = isolve 4 fi' (within' 0.01)

g x = 1 + 1/x^2

test3 = isolve 1.5 g (relative 0.00005)
test3' = isolve 1.5 g (relative' 0.00005)

test4 = isolve 1.5 g (within 0.0005)
test4' = isolve 1.5 g (within' 0.0005)
test4'' = take 13 (repeat' 1.5 g)

g' x = (1 + x^2)**(1/3)

test5 = isolve 1.5 g' (within 0.0005)
test5' = isolve 1.5 g' (within' 0.0005)
test5'' = take 7 (repeat' 1.5 g')

h x = sqrt (x^3-1)

test6 = isolve 1.5 h (within 0.0005)
test6' = isolve 1.5 h (within' 0.0005)

h' x = 1 / sqrt (x-1)

test7 = isolve 1.5 h' (within 0.0005)
test7' = isolve 1.5 h' (within' 0.0005)

{-

�󷽳� x^3 - x^2 - 1 = 0 �� x0 = 1.5 �����ĸ��������дΪ���� 4 �ֲ�ͬ�ĵȼ���ʽ��������Ӧ�ĵ�
����ʽ���Է������ǵ������ԡ�ѡһ�������ٶ����ĵ�����ʽ�󷽳̵ĸ�����ȷ�� 4 λ��Ч���֡�

������������һ�θ��� Haskell ʵ�֡���ʵ�ϣ�����������ȶ��ַ���Ϊ�򵥡���Ȼ�����ڲ��� x ���Ƹ�����
�ĵ��ƹ�ʽ����������ʽ�������û�ͨ�����������ṩ�ġ��������ֻ�Ǽ򵥵���ǰһ�� x ���� ��һ�� x��
repeat' ��ʵ�ֱ�ֻ��һ�У�

    repeat' x0 next = x0 : repeat' (next x0) next

������������������û��ӿ� isolve �����Ķ������Ȼ��Ȼ�س����ˣ�

    isolve x0 next cond = cond $ repeat' x0 next

������� x0 �� x �ĳ�ʼֵ��next ���û��ṩ�ľ���ĵ�����ʽ��cond ���û��Զ���ġ�����Ҫ�󡱣���
ͨ�������ϵĵ�����ֹ����������ʵ�ϣ�������ȫ���Խ����ַ���� BinSolve.hs �е� cond �ĵ���ʵ��
within �� relative ��ʵ��ֱ���հ������

    within eps (a:a':as)
        | abs(a-a') <= eps = a'
        | otherwise        = within eps (a':as)

    relative eps (a:a':as)
        | abs(a-a') <= eps * abs a' = a'
        | otherwise                 = relative eps (a':as)

�������ǾͿ���������Щ Haskell ���룬ͨ�������еĵ���ʽ��1�������㷽�̵ĸ��ˣ�

    g x = 1 + 1/x^2
    test3 = isolve 1.5 g (relative 0.00005)

�� Hugs �е��� test3 ���������£�

    IterSolve> test3
    1.46559498495446

��������ǵõ����̵ĸ�Ϊ 1.466

������ Maple 9 �жԴ˽��������֤��

    > evalf(solve(x^3-x^2-1=0,x));
      1.465571232, -0.2327856159 + 0.7925519930 I, -0.2327856159 - 0.7925519930 I

1.466 ��Ȼ�ڽ⼯�С�

��һ������ĸ�ֱ�ӵķ����ǰ���õĽ��Ƹ����뵽����ʽ�У�

    IterSolve> g 1.466 - 1.466
    -0.000701064045606659

���ǿ��������Ľ���Ѿ��൱�ӽ� 0 �ˡ�

�������������õ��ղŽ��еĵ����Ĵ�����������Ҫ���� relative ��������һ��ʵ�֣�������
Functional Programming �в���ʹ�á������á�����һЩ��������飩��

    relative' eps (a:a':as)
        | abs(a-a') <= eps * abs a' = 1
        | otherwise                 = 1 + relative' eps (a':as)

��ʱ���ǿ����������������Ϊ isolve �� cond �������е��ã�

    test3' = isolve 1.5 g (relative' 0.00005)

�õ��Ľ��Ϊ

    IterSolve> test3'
    16

����Ҫ���� 16 �β��ܵõ�ǰ��ļ����� 1.46559498495446. ������һ����Ȥ�ĵط��ǣ�����
ͨ���ı䴫�� isolve ������ cond �������ı� isolve �����������Ϊ��relative' ʹ��
isolve ���ٷ��������õĽ��Ƹ������Ƿ��������Ĵ����������ڴ˿����� OO �Ķ�̬���Ե�һЩ
Ӱ�ӡ�

ǰ������ʹ�� 0.00005 ���� 0.5/10^4����Ϊ�������������ޣ���������ֹ�����������������
�Ա�֤����� 4 λ��Ч���ֵľ��ȡ��������������������Щ���ڱ����ˣ��������ܻᵼ�¹���ĵ�
���������������֪���˸�����������С�����ǾͿ��Ը����Ƚ�׼ȷ�ľ���������������������㡣

������֪������Ҫ��ĸ����� 1.5 �������ʸ���������Ϊ 1���� 10^0���������ǿ��Խ����������
 eps �趨Ϊ 0.5 * 10^-3���� 0.0005��

    test4 = isolve 1.5 g (within 0.0005)

Hugs �ļ�����Ϊ��

    IterSolve> test4
    1.46571701802245

������ֵ��Ϊ 1.466. ��ǰ��õ��Ľ����ȫһ�¡�

����ǰ�涨�� relative' �ķ������� within'���Ա�õ�ʵ�ʵ����Ĵ�����

    within' eps (a:a':as)
        | abs(a-a') <= eps = 1
        | otherwise        = 1 + within' eps (a':as)

��ʱ����

    test4' = isolve 1.5 g (within' 0.0005)

�Ľ��Ϊ

    IterSolve> test4'
    12

���ǿ���������������ʹ�� 0.00005 ��Ϊ������������������ 4 �Ρ�����������̵õ���
x ����ֵ�����п��������������õ���

    test4'' = take 13 (repeat' 1.5 g)

Hugs �����Ϊ�����������Ű棩��

    [1.5,1.44444444444444,1.4792899408284,1.456976,1.47108058332003,1.46209053547124,
    1.46779057601959,1.46416438046218,1.46646635571707,1.46500304056686,1.46593243908183,
    1.46534182571779,1.46571701802245]

�������������� isolve ���������Ա���ĵ���ʽ��2����

    g' x = (1 + x^2)**(1/3)
    test5 = isolve 1.5 g' (within 0.0005)

�õ��Ľ��Ϊ

    IterSolve> test5
    1.46587682016881

��������������һ������ĵ���������

    test5' = isolve 1.5 g' (within' 0.0005)

�õ�

    IterSolve> test5'
    6

�ۣ�ֻ������ 6 ��Ү����ʹ�õ���ʽ��1������������һ��ĵ�������

������������ȡ x ����ֵ�����У�

    test5'' = take 7 (repeat' 1.5 g')

��������£�

    IterSolve> test5''
    [1.5,1.48124803420369,1.47270572963939,1.4688173136645,1.4670479732006,
    1.46624301011475,1.46587682016881]

ͨ�����ۼ�������֪��������ʽ��3���루4���Ƿ�ɢ�ģ����ǲ��������� isolve ��ǿ�С�����
����ʲô������������ð��� Ctrl-C ��׼������

    h x = sqrt (x^3-1)
    test6 = isolve 1.5 h (within 0.0005)

�����˳Ծ�������ĵ��ò�û�е���Ԥ���еġ�����ѭ������

    IterSolve> test6
    1.#INF

���ڰ��»س�����͵õ��˽������������������ȷʵ����֡���ʵ�ϣ�����ʾ�����������������
IEEE �ܱ�ʾ�����ķ�Χ���������޶ȵģ��������ܿ�����������еġ���Դ����

������������Ե���ʽ��4����

    h' x = 1 / sqrt (x-1)
    test7 = isolve 1.5 h' (within 0.0005)

��һ������ʲô�����û�еõ���Hugs ������������ʾ�ĳ�����Ϣ��

    IterSolve> test7

    Program error: argument out of range

ͨ����� x ���У���ע�⵽�ڵ��������ɴ�֮��x ��ֵ�ͳ����˵�����ʽ��4���Ķ����򣬼���
������ x-1 ��ɸ����ˣ����Ǳ㵼���˳������

    IterSolve> take 10 (repeat' 1.5 h')
    [1.5,1.41421356237309,1.55377397403004,1.34379719253106,1.70548866384199,
    1.19057012381854,2.29072308199971,0.880204251020792,
    Program error: argument out of range

ʹ�� Haskell ���Խ�����ֵ�����γ̵��㷨ʵ�����о����ʮ����⡣��������� C/C++ ������
Щ������������ʲô���ӣ��Ҵ�ǰ��δ�뵽��ֵ������ѧϰ����ʵ����Ȼ���������Ȥ��

-}