%% Project 1:
clear
clc
%% Task 1: Continuous Regression (Funcion approximation)
% Define the function f(x):
syms x
f = log(1 + x^2);

% Define g of the subspace:
g = 1 + x + x^2 + x^3;

% Calculate the orthogonal projection:
norm_f = double((int(f^2,x,0,exp(1) - 1))^(1/2));
norm_g = double((int(g^2,x,0,exp(1) - 1))^(1/2));
f_g = double(int(f*g,x,0,exp(1) - 1));
alpha = f_g / norm_g^2;
p = alpha * g;

% Plot the result for continuous regression:
figure;
fplot(f, [0, exp(1)-1], 'b', 'DisplayName', 'Original Function');
hold on;
fplot(p, [0, exp(1)-1], 'r', 'DisplayName', 'Projection');

title('Continuous Regression');
xlabel('x');
ylabel('f(x)');
legend('Location', 'Best');
grid on;
hold off;

%% Task 2: Discrete Regression
% Define the function f(x):
syms x
f = log(1 + x^2);

% Add points in the range [0, e-1] to solve the L.S.: Ax = b
Xs = linspace(0, exp(1)-1, 1000).'; % 1000 points between the borders
yy = double(subs(f, x, Xs)); % Add the x values to f and get the y values
figure;
plot(Xs, yy,'b', 'DisplayName', 'Original Function') % Plot the function:
hold on
grid on;

% Generate A: [1(:), x(:), x^2(:), x^3(:)]
m = length(Xs);
A = [ones(m,1) Xs Xs.^2 Xs.^3];
b = yy(:);

% Now we need to solve: Ac = b
coef = A \ b;
a0 = double(coef(1));
a1 = double(coef(2));
a2 = double(coef(3));
a3 = double(coef(4));

% Define the aproximation function:
aproximation = a0 + a1*x + a2*x^2 + a3*x^3
y_aproximation = a0 + a1 * Xs + a2 * Xs.^2 + a3 * Xs.^3;
plot(Xs, y_aproximation,'r', 'DisplayName', 'Approximation')
title('Discrete Regression');
legend('Location', 'Best');
xlabel("x")
ylabel("f(x)")