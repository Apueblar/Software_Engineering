%% Ex 1:
syms x
p = x^3+3*x^2-4;

solve(p,x) %Te encuentra las raices de p

factor(p) %Factoriza el polinomio

s1 = subs(p,x,sqrt(2));
double(s1)
vpa(s1,10)

% syms x y z Creates the symbolic variables x, y, z.
% solve(Expr) Calculates the zeros of Expr.
% solve(Expr,z) Calculates the values of z that make Expr equal to zero.
% subs(S,x,a) Substitutes in S the variable a for x.
% pretty(S) Presents the expression S in elegant form.
% double(S) Calculates the numerical value of a symbolic expression.
% expand(S) Expands the expression S as the product of its factors.
% factor(S) Factorizes, if possible, the expression S.
% simplify(S) Simplifies a symbolic expression.

%% Second part
clear
syms x

p = @(x) x^3+3*x^2-4; %Es necesaria esta notación para fzero()

solve(p,x)

factor(p,x)

s1 = p(sqrt(2)) %Cambia X por sqrt(2)

fzero(p,[0 2]) %Busca los cortes con el eje X (y=0) siempre que los extremos tengan diferente símbolo