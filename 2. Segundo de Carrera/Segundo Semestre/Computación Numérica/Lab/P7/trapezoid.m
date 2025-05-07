function [I_tr,Ebound] = trapezoid(f, a,b)
% Approximates the integral of f at [a,b]
%   INPUT:  f = The numerical function
%           a,b = extremities of the integration interval
%   OUTPUT: I_mid = The approximation of the integral
I_tr = (b-a) * (f(a)+f(b)) / 2;
% Error bound
syms x
f_sym = f(x);
d2f(x) = diff(f_sym,2);
xq = linspace(a,b,100); % 100 points in [a,b]
M = max(abs(double(d2f(xq)))); % Error bound
Ebound = (b-a)^3 * M /12;
end