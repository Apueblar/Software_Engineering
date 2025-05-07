function [I_cs,Ebound] = composite_simpson(f,a,b,n)
% Function r=composite_trapezoid(f,a,b,n) which apply the composite
% trapezoidal rule to approximate the integral of f on the interval [a,b]
%   INPUT:  f = The numerical function
%           a,b = extremities of the integration interval
%           n = number of subintervals
%   OUTPUT: I_mid = The approximation of the integral

% Divide in n subintervals
x=linspace(a,b,n+1); % Vector of extremities -> n subintervals
h=(b-a)/n; % Step
y=x+h/2;
y(n+1)=[];
I_cs=(2*sum(f(x))-f(a)-f(b)+4*sum(f(y)))*h/6;
% Error bound
syms x
f_sym = f(x);
d4f(x) = diff(f_sym,4);
xq = linspace(a,b,100); % 100 points in [a,b]
M = max(abs(double(d4f(xq)))); % Error bound
Ebound = (b-a)^5 * M /(2880*n^4);
end