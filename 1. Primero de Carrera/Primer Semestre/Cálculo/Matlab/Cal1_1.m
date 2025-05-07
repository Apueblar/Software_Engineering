%% Ex 2:
syms x a b c
E = a*x^2+b*x+c;
s=solve(E,x) % produces the two solutions
pretty(s) % shows the expression in a clearer way
s=solve(E,b) % Resuelve la ecuación para (b)
