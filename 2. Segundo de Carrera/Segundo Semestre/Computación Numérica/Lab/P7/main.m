%% Practice 7
%% Comparison MidPoint, Trapezoidal and Simpson
clear
close all
clc
%Problem
% f = @(x) sin(x/4); % at [0,pi]
% a = 0; b=pi; % Extremities of the interval
f=@(x) x.^3+x.^2+2*x-1;
a = 0; b=2;

fplot(f,[a,b],'r')
n=1; % n = number of subintervals

I_mid = midpoint_rule(f,a,b,n); % MidPoint
[I_tr,Ebound_tr] = trapezoid(f, a,b); % Trapezoid
[I_s,Ebound_s] = simpson(f,a,b); % Simpsons Formula

% vs the exact integral:
syms x
f_sym(x) = f(x);
intf_sym = int(f_sym,a,b);

absError_mid = double(abs(intf_sym-I_mid));
absError_tr = double(abs(intf_sym-I_tr));
absError_s = double(abs(intf_sym-I_s));

format long
EA = [absError_mid absError_tr absError_s]

%% Composite rules:
clear
close all
clc

f = @(x) exp(-x.^2); % at [0,1]
a = 0; b = 1; % Extremities
fplot(f,[a,b],'r')
n=10; % #subintervals

[I_ct,Ebound_ct] = composite_trapezoid(f,a,b,n)
[I_cs,Ebound_cs] = composite_simpson(f,a,b,n)

syms x
f_sym(x) = f(x);
intf_sym = int(f_sym,a,b);

absError_ct = double(abs(intf_sym-I_ct))
absError_cs = double(abs(intf_sym-I_cs))

% QUAD vs our
I_Q = quad(f,a,b);
absError_IQ = double(abs(intf_sym-I_cs))

























