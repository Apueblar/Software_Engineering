%% Ex 4:
syms x
f=x^2+1;
g=x^3+2*x-3;
f+g
f-g
f*g
f/g
finverse(f) % calculates the inverse function of f
compose(g,f) % calculates g composed with f = g(f(x))
compose(f,g) % calculates f composed with g = f(g(x))