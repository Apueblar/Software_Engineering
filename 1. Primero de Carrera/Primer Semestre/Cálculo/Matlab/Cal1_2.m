%% Ex 3:
syms x
p = 2*(x-1) - 2*(x-1)^2 + (x-1)^3
pretty(p)
p = expand(p)
factor(p)
solve(p)