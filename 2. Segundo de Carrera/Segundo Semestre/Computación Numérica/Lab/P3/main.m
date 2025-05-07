%% Practice 3
%% Interpolation (m=n)
% p=5*x.^2-3.*x+2;
p = [5 -3 2];
t = linspace(0,2,12)'; % Vertical vector
polyval(p,t); % Calculates the result of p(x) for the given points in t
pd = polyder(p); % 10x -3 = p'
sol = roots(p); % solutions of p(x) = 0

% polynomial example
r = [1 2 3 4];
syms x
q (x)= expand( (x-1)*(x-2)*(x-3)*(x-4) )
poly(r)

%% Polynomial Interpolation {1,x,x^2,...}
clear
close all
clc
f = @(x) log(1+x);
x = [0 1 exp(1)-1 3]'; % 4 points (column vector)
y = f(x);
fplot(f,[0,3],'b')
hold on
plot(x,y,'.r','markerSize',20)

n = length(x);
% {1,x,x^2,x^3}
A = [ones(n,1) x(:) x(:).^2 x(:).^3];
b = y;

%SCD
coef = A \ b;

a0 = coef(1);
a1 = coef(2);
a2 = coef(3);
a3 = coef(4);

% Interpolation Pol:
p = @(x) a0 + a1 * x + a2 * x.^2 + a3 * x.^3;

p_val = p(x);
plot(x,p_val,'go')
fplot(p, [x(1), x(end)],'-m')

%% Lagrange Interpolation
clear
close all
clc

y = [1.1 1.5 2.4 2 3 1];
n = length(y);
x = [0:n-1];
L = lagrange(x)
p = y*L; % Interpolation pol (vector of coeff.)
plot(x,y,'.m','markerSize',20)
hold on
fplot(@(x) polyval(p,x),[x(1), x(end)],'-b')

%% Lagrange Error
clear
close all
clc

f = @(x) x.*sin(x);
a = 0;
b = 3;
x = linspace(a,b,5);
y = f(x);
L = lagrange(x);
p = y*L;
plot(x,y,'.m', 'markerSize', 20)
hold on
fplot(f,[a b], '-b')
fplot(@(x) polyval(p,x),[a b],'-r')

% Error Bound

% K = max{|q(x)| : 0 ≤ x ≤ 3}
q = poly(x);
% figure
% fplot(@(x) polyval(q,x), [a,b], '-b')
% max q(X) --> q'(x) = 0
sol = roots(polyder(q));
K = max(abs(polyval(q,sol)));

% M = max{|f(v)(x)| : 0 ≤ x ≤ 3}
syms x
f_sym(x) = f(x);
fd5_sym = diff(f_sym,5);
fd5 = matlabFunction(fd5_sym);
% figure
% fplot(fd5, [a b])
% max q'''''(X) --> q''''''(x) = 0
fd6_sym = diff(fd5_sym);
zero = fzero(matlabFunction(fd6_sym), [a b]);
M = max(abs(fd5(zero)));

error_bound = K * M / factorial(5)





















