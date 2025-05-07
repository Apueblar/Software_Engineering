clear
close all
clc
format short

x = [-1 0 2 3 5];
y = [1 3 4 3 1];

% Lagrange's method.
plot(x,y,'.m','markersize',15)
hold on
L = lagrange(x)
p = y*L; % Interpolation pol (vector of coeff.)
plot(x,y,'.m','markerSize',20)
hold on
fplot(@(x) polyval(p,x),[x(1), x(end)],'-.b')

figure
% Newton's method.
plot(x,y,'.m','markersize',15)
hold on
[table, coeff] = div_diff(x,y)
newton_poly_sym = newton_pol(coeff,x); % Symbolic pol
P1 = matlabFunction(newton_poly_sym);
fplot(P1,[x(1),x(end)],'-.r')

% Comparison
figure
fplot(@(x) polyval(p,x),[x(1), x(end)],'-g') 
hold on
fplot(P1,[x(1),x(end)],'-.r')
% They are the same