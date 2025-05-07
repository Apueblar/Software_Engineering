function [I_s,Ebound] = simpson(f,a,b)
% approximates the integral f, at [a,b] using the Simpson rule
I_s=(b-a)*(f(a)+4*f((a+b)/2)+f(b))/6;
% Error bound
syms x
f_sym = f(x);
d4f(x) = diff(f_sym,4);
xq = linspace(a,b,100); % 100 points in [a,b]
M = max(abs(double(d4f(xq)))); % Error bound
Ebound = (b-a)^5 * M /2880;
end
