%% Ex 5:
% Solution 1:
syms x
f=x*exp(x^2-1);
a=subs(f,x,2)
b=subs(f,x,-5)
a*b
% Solution 2:
x=2;
a=x*exp(x^2-1)
x=-5;
b=x*exp(x^2-1)
a*b

% Both solutions are the same