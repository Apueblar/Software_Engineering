%% Practice 8
%% Open Formulas Numerical Integration
%% Simple/Composite Open Trapezoidal / Simpson
clear
close all
clc

% Define the problem
f = @(x) 1./sqrt(x);
a = 0;
b = 1;
fplot(f,[a,b],'m')
hold on
% Select the nodes: 1st degree interpol. poly. -> 2 nodes
h = (b-a)/3; % or l=b-a;
x0 = a+h; % or x0 = a+l/3;
x1 = a +2*h; % or x1 = b-h; % or x1 = a+2/3 == b-l/3
I = (b-a)/2 * (f(x0)+f(x1));
plot([x0 x1],f([x0 x1]),'bo','MarkerFaceColor','b')
fprintf('Simple Trapezoidal Open: %f \n', I)

% Composite Open Trapezoidal
figure
fplot(f,[a,b],'m')
hold on
n = 10;
ln = (b-a)/n; % Length of each subinterval
hn = ln/3; % Distance between inner nodes
x = linspace(a,b,n+1); % Vector of extremities of subintervals
plot(x,f(x),'bo','MarkerFaceColor','g')

I = 0; % Initialize
for k = 1:n % Counting the subintervals
    % [xk,xk+1]
    x0 = x(k)+hn;
    x1 = x(k+1)-hn; % x1 = x(k)+2*hn;
    I = I + ln/2 * (f(x0)+f(x1));
    plot([x0 x1],f([x0 x1]),'bo','MarkerFaceColor','b') % Plot inner nodes
end
fprintf('Composite Trapezoidal Open: %f \n', I)

% Simple/Composite Simpson's Formula
figure
fplot(f,[a,b],'b')
hold on
% Select the nodes: 2nd degree poly. -> 3 nodes
h = (b-a)/4;
x0 = a+h;
x1 = a+2*h;
x2 = a+3*h;
plot([x0 x1 x2],f([x0 x1 x2]),'ro','MarkerFaceColor','r')
I = (b-a) * (2/3 * f(x0) - 1/3 * f(x1) + 2/3 * f(x2));
fprintf('Simple Simpson Open: %f \n', I)

% Composite Open Simpson
figure
fplot(f,[a,b],'b')
hold on
% n = 10;
ln = (b-a)/n;
hn = ln/4;
x = linspace(a,b,n+1);
plot(x,f(x),'ro','MarkerFaceColor','g')
I = 0; % Initialize
for k = 1:n % Counting the subintervals
    % [xk,xk+1]
    x0 = x(k)+hn;
    x1 = x(k)+2*hn;
    x2 = x(k)+3*hn;
    I = I + ln * (2/3 * f(x0) - 1/3 * f(x1) + 2/3 * f(x2));
    plot([x0 x1 x2],f([x0 x1 x2]),'ro','MarkerFaceColor','r') % Plot inner nodes
end
fprintf('Composite Simpson Open: %f \n', I)

%% eXAMPLE:
clear
close all
clc

f = @(x) log(x); % ln(x)
a = 0; b = 1;
n = 10;

fplot(f,[a,b],'m')
hold on
% Select the nodes: 1st degree interpol. poly. -> 2 nodes
h = (b-a)/3; % or l=b-a;
x0 = a+h; % or x0 = a+l/3;
x1 = a +2*h; % or x1 = b-h; % or x1 = a+2/3 == b-l/3
I = (b-a)/2 * (f(x0)+f(x1));
plot([x0 x1],f([x0 x1]),'bo','MarkerFaceColor','b')
fprintf('Simple Trapezoidal Open: %f \n', I)

% Composite Open Trapezoidal
figure
fplot(f,[a,b],'m')
hold on
n = 10;
ln = (b-a)/n; % Length of each subinterval
hn = ln/3; % Distance between inner nodes
x = linspace(a,b,n+1); % Vector of extremities of subintervals
plot(x,f(x),'bo','MarkerFaceColor','g')

I = 0; % Initialize
for k = 1:n % Counting the subintervals
    % [xk,xk+1]
    x0 = x(k)+hn;
    x1 = x(k+1)-hn; % x1 = x(k)+2*hn;
    I = I + ln/2 * (f(x0)+f(x1));
    plot([x0 x1],f([x0 x1]),'bo','MarkerFaceColor','b') % Plot inner nodes
end
fprintf('Composite Trapezoidal Open: %f \n', I)

% Simple/Composite Simpson's Formula
figure
fplot(f,[a,b],'b')
hold on
% Select the nodes: 2nd degree poly. -> 3 nodes
h = (b-a)/4;
x0 = a+h;
x1 = a+2*h;
x2 = a+3*h;
plot([x0 x1 x2],f([x0 x1 x2]),'ro','MarkerFaceColor','r')
I = (b-a) * (2/3 * f(x0) - 1/3 * f(x1) + 2/3 * f(x2));
fprintf('Simple Simpson Open: %f \n', I)

% Composite Open Simpson
figure
fplot(f,[a,b],'b')
hold on
% n = 10;
ln = (b-a)/n;
hn = ln/4;
x = linspace(a,b,n+1);
plot(x,f(x),'ro','MarkerFaceColor','g')
I = 0; % Initialize
for k = 1:n % Counting the subintervals
    % [xk,xk+1]
    x0 = x(k)+hn;
    x1 = x(k)+2*hn;
    x2 = x(k)+3*hn;
    I = I + ln * (2/3 * f(x0) - 1/3 * f(x1) + 2/3 * f(x2));
    plot([x0 x1 x2],f([x0 x1 x2]),'ro','MarkerFaceColor','r') % Plot inner nodes
end
fprintf('Composite Simpson Open: %f \n', I)

%% Gaus-Legendre Quadrature
clear
close all
clc

% Define the problem
f = @(x) exp(-x.^2);
a = 0;
b = 2;
fplot(f,[a,b],'b')
figure
n = 6; % Degree of the Legendre Polyn

% Zeros of Pn, dPn
[zeros_P, dP] = zeros_legendre(n);
x = zeros_P;
% Weigths
w = 2./((1-x.^2).*dP(x).^2);
% Change of Variable: [-1,1] -> [a,b]
xf = (b-a)/2 * x + (a+b)/2;
wf = (b-a)/2 * w;

% Integral
I = dot(wf,f(xf))
% Exact value
syms x
f_sym = f(x);
I_exact = double(int(f_sym,a,b))




























