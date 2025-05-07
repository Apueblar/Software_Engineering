%% Practice 5
%% Discrete Approximation
clear
close all
clc
%
y=[1.5874	2.8276	1.6348	2.9133	1.9471	3.5573	3.7463	3.2093	2.8296	3.6377	4.469	4.555	3.5406];
m = length(y);
t=linspace(0,1.2,m);
plot(t,y,'.m','markersize',20)
hold on
t = t(:); y = y(:);
% Model p = a0 + a1*t + a2*t.^2 + a3*t.^3 + a4*t.^4

%Define the linear problem Ax=b
A = [ones(m,1) t t.^2 t.^3 t.^4];
b = y;
xLS = (A' * A)^-1 * A' * b;
y_pred = A*xLS; % Predicted data with 4th degree polynomial
plot(t,y_pred,'ob')

a0 = xLS(1);
a1 = xLS(2);
a2 = xLS(3);
a3 = xLS(4);
a4 = xLS(5);
p = @(x) a0 + a1*x + a2*x.^2 + a3*x.^3 + a4*x.^4;

fplot(p,[0,1.2],'-g')

%% AMAZON Stocks
clear
close all
clc

[num,txt] = xlsread('AmazonStocks.xlsx');
y = num(:); % data - prises
m = length(y);
t = [1:m];
plot(t,y,'.m','markersize',20)
hold on
t = t(:);
% Model p = a0 + a1*t + a2*t.^2 + a3*t.^3
A = [ones(m,1) t t.^2 t.^3];
b = y;
sol1 = (A' * A)^-1 * A' * b;
y_pred1 = A*sol1
plot(t,y_pred1,'ob')
a0 = sol1(1);
a1 = sol1(2);
a2 = sol1(3);
a3 = sol1(4);
p1 = @(x) a0 + a1*x + a2*x.^2 + a3*x.^3;

fplot(p1,[t(1),t(end)],'-g')

% Exponential model: y = a0*e^a1*t --> log(y) = log(a0) + a1*t
% Define Ax=b
A = [ones(m,1) t]; % Degree 1
b = log(y);
sol2 = (A' * A)^-1 * A' * b;
a0 = exp(sol2(1));
a1 = sol2(2);
y_pred2 = a0 * exp(a1 * t);
plot(t,y_pred2,'*b')

p2 = @(x) a0 * exp(a1*x);

fplot(p2,[t(1),t(end)],'-r')

err1 = norm(y-y_pred1)/norm(y);
erms1 = norm(y-y_pred1)/sqrt(m);
err2 = norm(y-y_pred2)/norm(y);
erms2 = norm(y-y_pred2)/sqrt(m);

%% Continuous Approximation
clear
close all
clc
% Approx function by pol in [a,b]
syms x
f(x) = sin(pi*x);
basis = [1 x x^2 x^3].'; % Basis of R3[x]

G_sym = basis * basis.';
G = int(G_sym,-1,1)
b_sym = f(x)*basis;
b = int(b_sym,-1,1)

sol = double(G \ b);
a0 = sol(1);
a1 = sol(2);
a2 = sol(3);
a3 = sol(4);

p = @(x) a0 + a1*x + a2*x.^2 + a3*x.^3;
f = matlabFunction(f);

fplot(p,[-1,1],'-m')
hold on
fplot(f,[-1,1],'-b')

%% Test
%% Approximation of f(x) = e^(x/2) with a 3rd-degree polynomial
clear
close all
clc
a = 0.5;
c = 1;
syms x
f(x) = exp(x/2);
basis = [1 x x^2 x^3].'; % Basis of R3[x]

G_sym = basis * basis.';
G = double(int(G_sym,a,c))
b_sym = f(x)*basis;
b = int(b_sym,a,c);

sol = double(G \ b);
a0 = sol(1)
a1 = sol(2)
a2 = sol(3)
a3 = sol(4)

p = @(x) a0 + a1*x + a2*x.^2 + a3*x.^3;
f = matlabFunction(f);

fplot(p,[a,c],'-m')
hold on
fplot(f,[a,c],'-b')

%% Approximate temperature
clear
close all
clc
%
y=[2.7641	2.7924	3.0889	3.0966	2.1475	1.7541	2.6552	3.2191	3.1865	3.9457	4.1724	3.236	4.2773];
m = length(y);
t=linspace(0,1.2,m);
plot(t,y,'.m','markersize',20)
hold on
t = t(:); y = y(:);
% Model p = a0 + a1*t + a2*t.^2 + a3*t.^3 + a4*t.^4

%Define the linear problem Ax=b
A = [ones(m,1) t t.^2 t.^3 t.^4];
b = y;
xLS = (A' * A) \ (A' * b)
y_pred = A*xLS; % Predicted data with 4th degree polynomial
plot(t,y_pred,'ob')

a0 = xLS(1);
a1 = xLS(2);
a2 = xLS(3);
a3 = xLS(4);
a4 = xLS(5);
p = @(x) a0 + a1*x + a2*x.^2 + a3*x.^3 + a4*x.^4;

fplot(p,[0,1.2],'-g')

p(1.2)
relative_error = norm(y - y_pred) / norm(y)
rms_error = norm(y - y_pred) / sqrt(m)

%% More data
clear
close all
clc
%
y=[3.1129	3.1444	3.3552	4.056	4.1261	4.5686	5.3174	5.6201	6.1027	7.0363	7.5821	8.558	9.5475];
m = length(y);
t=linspace(0,1.2,m);
plot(t,y,'.m','markersize',20)
hold on

t = t(:); y = y(:);
A = [ones(m,1) t]; % Degree 1
b = log(y);
sol2 = (A' * A)^-1 * A' * b;
a0 = exp(sol2(1))
a1 = sol2(2)
y_pred2 = a0 * exp(a1 * t)
plot(t,y_pred2,'*b')

p2 = @(x) a0 * exp(a1*x);

fplot(p2,[t(1),t(end)],'-r')

% Linear model y = c0 + c1*t
A = [ones(m,1) t];
b = y;
sol1 = (A' * A) \ (A' * b);
c0 = sol1(1)
c1 = sol1(2)
y_pred1 = c0 + c1 * t;
plot(t, y_pred1, 'og')

p1 = @(x) c0 + c1*x;
fplot(p1, [t(1), t(end)], '-g')

% Error calculations
err1 = norm(y-y_pred1)/norm(y)
erms1 = norm(y-y_pred1)/sqrt(m)
err2 = norm(y-y_pred2)/norm(y)
erms2 = norm(y-y_pred2)/sqrt(m)


%% Test bis
%% Approximate temperature
clear
close all
clc
%
y=[2.691	1.7414	2.2999	1.3957	1.913	3.1725	2.3801	2.1154	3.58	3.6959	3.9728	4.7173	3.6304];
m = length(y);
t=linspace(0,1.2,m);
plot(t,y,'.m','markersize',20)
hold on
t = t(:); y = y(:);
% Model p = a0 + a1*t + a2*t.^2 + a3*t.^3 + a4*t.^4

%Define the linear problem Ax=b
A = [ones(m,1) t t.^2 t.^3 t.^4];
b = y;
xLS = (A' * A) \ (A' * b)
y_pred = A*xLS; % Predicted data with 4th degree polynomial
plot(t,y_pred,'ob')

a0 = xLS(1);
a1 = xLS(2);
a2 = xLS(3);
a3 = xLS(4);
a4 = xLS(5);
p = @(x) a0 + a1*x + a2*x.^2 + a3*x.^3 + a4*x.^4;

fplot(p,[0,1.2],'-g')

p(1.2)
relative_error = norm(y - y_pred) / norm(y)
rms_error = norm(y - y_pred) / sqrt(m)

%% More data
clear
close all
clc
format long
%
y=[2.9202	3.4948	3.4228	4.0169	4.2644	4.5844	4.9699	5.8995	6.2159	7.0823	7.7025	8.3235	9.4578];
m = length(y);
t=linspace(1,2.2,m);
plot(t,y,'.m','markersize',20)
hold on

t = t(:); y = y(:);
A = [ones(m,1) t]; % Degree 1
b = log(y);
sol2 = (A' * A)^-1 * A' * b;
a0 = exp(sol2(1))
a1 = sol2(2)
y_pred2 = a0 * exp(a1 * t);
plot(t,y_pred2,'*b')

p2 = @(x) a0 * exp(a1*x);
p2t13 = p2(2.2)

fplot(p2,[t(1),t(end)],'-r')

% Linear model y = c0 + c1*t
A = [ones(m,1) t];
b = y;
sol1 = (A' * A) \ (A' * b);
c0 = sol1(1)
c1 = sol1(2)
y_pred1 = c0 + c1 * t;
plot(t, y_pred1, 'og')

p1 = @(x) c0 + c1*x;
fplot(p1, [t(1), t(end)], '-g')

% Error calculations
err1 = norm(y-y_pred1)/norm(y)
erms1 = norm(y-y_pred1)/sqrt(m)
err2 = norm(y-y_pred2)/norm(y)
erms2 = norm(y-y_pred2)/sqrt(m)

%% Approximation of f(x) = sin(3x) with a 3rd-degree polynomial
clear
close all
clc
format short
a = 0.5;
c = 1;
syms x
f(x) = sin(3*x);
basis = [1 x x^2 x^3].'; % Basis of R3[x]

G_sym = basis * basis.';
G = double(int(G_sym,a,c))
b_sym = f(x)*basis;
b = int(b_sym,a,c);

sol = double(G \ b);
a0 = sol(1)
a1 = sol(2)
a2 = sol(3)
a3 = sol(4)

p = @(x) a0 + a1*x + a2*x.^2 + a3*x.^3;
f = matlabFunction(f);

fplot(p,[a,c],'-m')
hold on
fplot(f,[a,c],'-b')

%% Model Fitting Problem y = (a*x)/(2 + b*x)
clear
close all
clc

x = [1/5, 1/4, 1/3, 1/2, 1]; % x values
y = [1/24, 1/20, 1/16, 1/12, 1/8]; % y values
m = length(x);

x_prime = 1 ./ x; % x' = 1/x
y_prime = 1 ./ y; % y' = 1/y

plot(x_prime, y_prime, 'om', 'markersize', 10)
hold on
xlabel('x'' = 1/x')
ylabel('y'' = 1/y')

% Define the linear problem Ax = b for y' = (2/a) * x' + (b/a)
A = [x_prime', ones(m,1)];
b = y_prime';

sol = (A' * A) \ (A' * b);
m_slope = sol(1); % m = 2 / a
c_intercept = sol(2); % c = b / a

y_prime_pred = @(t) (sol(1) + sol(2)* t);
fplot(y_prime_pred, [min(x_prime), max(x_prime)], 'b')

a = 2 / m_slope
b = c_intercept * a

figure
y_pred = @(t) (a * t) ./ (2 + b * t);
fplot(y_pred, [min(x), max(x)], 'b')
hold on
plot(x, y, 'om', 'markersize', 10)
xlabel('x')
ylabel('y')

y_pred_values = y_pred(x); % Evaluate y_pred at given x points
relative_error = norm(y - y_pred_values) / norm(y);
rms_error = norm(y - y_pred_values) / sqrt(m);

x_test = 1/2;
y_test = y_pred(x_test)