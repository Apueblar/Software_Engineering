%% Verifying Runge's Phenomenon Equally Spaced
clear
close all
clc

f = @(x) exp(-20 * x.^2);
fplot(f, [-1,1],'-b')
hold on
n = 11;

% Equally spaced
x = linspace(-1,1,n);

y = f(x);
plot(x,y,'.m','markersize',20)

L = lagrange(x);
p = y*L; % Vector of coefficients
p = @(x) polyval(p,x); % Handle function
fplot(p, [-1,1],'-r')

%% Verifying Runge's Phenomenon Chebyshev nodes
clear
close all
clc

f = @(x) exp(-20 * x.^2);
fplot(f, [-1,1],'-b')
hold on
n = 11;

% Chebyshev
k = 1:n;
x = cos((2*k-1)*pi/(2*n));

y = f(x);
plot(x,y,'.m','markersize',20)
L = lagrange(x);
p = y*L; % Vector of coefficients
p = @(x) polyval(p,x); % Handle function
fplot(p, [-1,1],'-r')

% Plot with 51
figure
f = @(x) exp(-20 * x.^2);
fplot(f, [-1,1],'-b')
hold on
n = 31;

% Chebyshev
k = 1:n;
x = cos((2*k-1)*pi/(2*n));

y = f(x);
plot(x,y,'.m','markersize',20)
L = lagrange(x);
p = y*L; % Vector of coefficients
p = @(x) polyval(p,x); % Handle function
fplot(p, [-1,1],'-r')