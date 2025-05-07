function [I_ct,Ebound] = composite_trapezoid(f,a,b,n)
% Function r=composite_trapezoid(f,a,b,n) which apply the composite
% trapezoidal rule to approximate the integral of f on the interval [a,b]
%   INPUT:  f = The numerical function
%           a,b = extremities of the integration interval
%           n = number of subintervals
%   OUTPUT: I_mid = The approximation of the integral

% Divide in n subintervals
x=linspace(a,b,n+1); % Vector of extremities -> n subintervals
h=(b-a)/n; % Step
I_ct=(2*sum(f(x))-f(a)-f(b))*h/2;
% Error bound
syms x
f_sym = f(x);
d2f(x) = diff(f_sym,2);
xq = linspace(a,b,100); % 100 points in [a,b]
M = max(abs(double(d2f(xq)))); % Error bound
Ebound = (b-a)^3 * M /(12*n^2);
end