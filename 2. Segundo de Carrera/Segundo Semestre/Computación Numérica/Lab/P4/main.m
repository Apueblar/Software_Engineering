%% Practice 4
%% Runge Function in [-1,1]
clear
close all
clc

f = @(x) 1./(1+25.*x.^2);
fplot(f, [-1,1],'-b')
hold on

n = 9; % Interpolation polyn of degree 8
x = linspace(-1,1,n);
y = f(x);
plot(x,y,'.m','markersize',20)

L = lagrange(x);
p = y*L; % Vector of coefficients
p = @(x) polyval(p,x); % Handle function
fplot(p, [-1,1],'-r')

% Increase number of points
n = 13; % Interpolation polyn of degree 8
x = linspace(-1,1,n);
y = f(x);
plot(x,y,'.m','markersize',20)

L = lagrange(x);
p = y*L; % Vector of coefficients
p = @(x) polyval(p,x); % Handle function
fplot(p, [-1,1],'-g')

%% Chebyshev Nodes on Runge Function
clear
close all
clc

% Instead of equally spacd points we will use:
% xk = cos((2*k-1)*pi/(2*n))
f = @(x) 1./(1+25.*x.^2);
fplot(f, [-1,1],'-b')
hold on
n = 9;
k = 1:n;
x = cos((2*k-1)*pi/(2*n)) % Chebyshev Points /Nodes
y = f(x);
plot(x,y,'.m','markersize',20)

L = lagrange(x);
p = y*L; % Vector of coefficients
p = @(x) polyval(p,x); % Handle function
fplot(p, [-1,1],'-g')

%% Divided Differences -> Newton Interpolation
clear
close all
clc

% Generate data
f = @(x) log(x+1);
fplot(f,[1,exp(1)],'-b')
hold on
n = 6; % degree of the poly + 1
x = linspace(1,exp(1),n);
y = f(x);
plot(x,y,'.m','markersize',15)

% Newton polynomial
[table, coeff] = div_diff(x,y)
newton_poly_sym = newton_pol(coeff,x); % Symbolic pol
P1 = matlabFunction(newton_poly_sym);
fplot(P1,[1,exp(1)],'-.r')

% Basis function {1, x, x^2, ...} -> Ax=b
x = x(:);
y = y(:); % Column vectors

% n = 6;
A = [ones(n,1) x(:) x(:).^2 x(:).^3 x(:).^4 x(:).^5];
b = y;
sol = A^-1 * b; % coeff of the polynomial interpolation
p = @(T) sol(1) + sol(2)*T + sol(3)*T.^2 + sol(4)*T.^3 + sol(5)*T.^4 + sol(6)*T.^5;
fplot(p,[1,exp(1)],'-.g')

% Lagrange interpolation
x = x';
y = y';
L = lagrange(x)
p = y*L; % Interpolation pol (vector of coeff.)
plot(x,y,'.m','markerSize',20)
hold on
fplot(@(x) polyval(p,x),[x(1), x(end)],'-.m')

%% Piecewise Interpolation
clear
close all
clc
% Linear Spline
x = [0 1 2];
y = [1 3 2];
xx = linspace(0,2,150);
yy = interp1(x,y,xx);

plot(x,y,'.m','markerSize',20)
hold on
plot(xx,yy,'-r')

figure
% Cubic Spline
f=@(x) x+cos(3*x);
x=linspace(0,4,10);
y=f(x);
xx = linspace(0,4,100);
yy = interp1(x,y,xx);
ss=spline(x,y,xx);

fplot(f,[0,4],'-b')
hold on
plot(x,y,'.m','markerSize',20)
plot(xx,yy,'-r')
plot(xx,ss,'-g')

%% Homework
%% 1 - Interpolation Polynomial
clear
close all
clc

x = [-1 0 1 2 3 4]';
y = [64.536	85.655	85.338	49.404	78.088	27.465]';
plot(x,y,'.m','markersize',15) % Plot the numbers
hold on

n = 6;
A = [ones(n,1) x(:) x(:).^2 x(:).^3 x(:).^4 x(:).^5]; % {1 x x^2 x^3 x^4 x^5}
b = y;
sol = A \ b; % coeff of the polynomial interpolation
p = @(T) sol(1) + sol(2)*T + sol(3)*T.^2 + sol(4)*T.^3 + sol(5)*T.^4 + sol(6)*T.^5;
fplot(p,[-1,4],'-.b')

p(3.85)

%% 2 - Interpolating function
clear
close all
clc
format long

f = @(T) exp(0.1 * T) + cos(0.89 * T);
fplot(f,[-2,2],'-.b')
hold on

% Newton polynomial interpolation
n = 3;
x = linspace(-2,2,n);
y = f(x);
plot(x,y,'.m','markersize',15)

[table, coeff] = div_diff(x,y);
P1_sym = newton_pol(coeff,x); % Symbolic pol
P1 = matlabFunction(P1_sym);
fplot(P1,[-2,2],'-.r')

x_eval = [-0.2, 0.44, 1.12, 1.4];
% Compute values
f_values = f(x_eval);
int_values = P1(x_eval);

absolute_errors = abs(f_values - int_values);
sum_absolute_errors = sum(absolute_errors)


% Chebyshev Interpolation
figure
fplot(f, [-2,2],'-b')
hold on

% Generate Chebyshev nodes
a = -2; b = 2;
k = 1:n;
x = cos((2*k - 1) * pi / (2*n)) * (b-a)/2 + (a+b)/2;

y = f(x);
plot(x,y,'.m','markersize',20)

L = lagrange(x);
p = y*L; % Vector of coefficients
p = @(x) polyval(p,x); % Handle function
fplot(p, [-2,2],'-g')

x_eval = [-0.2, 0.44, 1.12, 1.4];
% Compute values
f_values = f(x_eval);
int_values = p(x_eval);

absolute_errors = abs(f_values - int_values)
sum_absolute_errors = sum(absolute_errors)

%% 3 - Piecewise Interpolation Linear
clear
close all
clc

f= @(T) exp(0.82 * T) - cos(6.3 * T);
fplot(f,[-3,5],'-.b')
hold on

n = 11;
x = linspace(-3,5,n);
y = f(x);

xx = linspace(-3,5,250);
yy = interp1(x,y,xx);

plot(x,y,'.m','markerSize',20)
hold on
plot(xx,yy,'-r')

x_eval = [-2.76 -0.76 1.24 1.32 2.28];

% Compute values
f_values = f(x_eval);
int_values = interp1(x, y, x_eval, 'linear');

errors = abs(f_values - int_values)

%% 4 - Piecewise Interpolation Cubic
clear
close all
clc

f= @(T) exp(6.4 * T) - cos(0.95 * T);
fplot(f,[-13,-3],'-.b')
hold on

n = 10;
x = linspace(-13,-3,n);
y = f(x);

xx = linspace(-13,-3,250);
yy = spline(x,y,xx);

plot(x,y,'.m','markerSize',20)
hold on
plot(xx,yy,'-r')

x_eval = [-11.4,-10.7,-7.1,-6.3,-5.3];

% Compute values
f_values = f(x_eval);
int_values = spline(x, y, x_eval);

errors = abs(f_values - int_values)