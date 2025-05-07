%% Exercise 1: f(x) = sin(x) - x^2
clear
clc 
close all
format long

% a) Prove graphically
f = @(x) sin(x) - x.^2;
a = 0;
b = 1;
fplot(0, [a,b], 'b')
hold on
fplot(f, [a,b], 'r')

% b) Bracket with incremental search
intervals = incrementalSearch(f, a, b, 10); % Interval 0.6 - 0.7

a = intervals(1);
b = intervals(2);
% c) Approximate the root using the bisection
T = 10.^-6;
Nmax = 1000;
[x_sol, N] = bisection_while(f, a, b, T, Nmax);
fprintf('The approximation of the bisection is: %i, \n', x_sol);
fprintf('The number of iteration of the bisection is: %i, \n', N);
fplot(f,[0,1],'r')
hold on

% d) Approximate the root using Newton
syms x
f_sym(x) = f(x);
df_sym = diff(f_sym);
df = matlabFunction(df_sym);

tol = 10.^-6;
n_max = 200;
[x_New, N_New] = newton(f, df, a, tol, n_max);
fprintf('The approximation of Newton is: %i, \n', x_New);
fprintf('The number of iteration of Newton is: %i, \n', N_New);

% Explanation
% Both reach to the same solution 0.87...
% The newton method is faster as it only needs 4 iterations while the
% bisection needs 17 of them

%% Exercise 2 Population of a city
clear
clc
close all

y = [120.5 135.8 150.3 168.2];
x = [1995 2000 2005 2010];
% A) Use lagrange interpol and cubic splines

% Lagrange
L = lagrange(x);
p = y*L; % Interpolation pol (vector of coeff.)
lagrange_pol = @(x) polyval(p,x);

% Cubic Spline
xq = linspace(x(1),x(end),100);
ss=spline(x,y,xq);

% B) Plot Results
plot(x,y,'.m','markerSize',20, 'DisplayName', 'Data')
hold on
fplot(lagrange_pol, [x(1), x(end)], '-g', 'LineWidth', 1.5, 'DisplayName', 'Lagrange Interpolation');
plot(xq, ss, '--r', 'LineWidth', 1.5, 'DisplayName', 'Cubic Spline');
legend;

%% Exercise 3 calculate the wind speed (m/s)
clear
clc
close all

y = [3.2 4.5 6.1 7.8 9.3 10.5 12.2 11.8 10.1 8.7 6.5 5.0 3.8];
m = length(y);
x = 1:m;

% A) Fourier-based model pt(x) = a0 + sum(k=2 to 6)(ak*sin(kx)+bk*cos(kx))
k_values = 2:6;
n_k = length(k_values);

% Define l.s. fitting matrix
A = ones(m, 2*n_k + 1); % 2n_k as we have ak and bk
for i = 1:n_k
    k = k_values(i);
    A(:, 2*i) = sin(k*x);
    A(:, 2*i+1) = cos(k*x);
end

coeffs = A \ y';
y_fourier = A * coeffs;

y = y(:);
% D) Error Analysis
err_fourier = norm(y - y_fourier) / norm(y);
erms_fourier = norm(y - y_fourier) / sqrt(m);
[max_error_fourier, max_idx_fourier] = max(abs(y - y_fourier));

y = y(:)';
% C) Polynomial model p(x) of degree 3
p_coeffs = polyfit(x, y, 3);
y_poly = polyval(p_coeffs, x);

% D) Error Analysis
err_poly = norm(y - y_poly) / norm(y);
erms_poly = norm(y - y_poly) / sqrt(m);
[max_error_poly, max_idx_poly] = max(abs(y - y_poly));

% B) Plot Results
figure;
plot(x, y, '.m', 'MarkerSize', 20, 'DisplayName', 'Data');
hold on;
plot(x, y_fourier, '-r', 'LineWidth', 1.5, 'DisplayName', 'Fourier Model');
plot(x, y_poly, '--b', 'LineWidth', 1.5, 'DisplayName', 'Cubic Polynomial');
legend;
xlabel('Time step');
ylabel('Wind Speed (m/s)');
title('Wind Speed Approximation using Fourier and Polynomial Models');
grid on;

% D) Display Errors
fprintf('Fourier Model:\n');
fprintf('  Relative Error: %.6f\n', err_fourier);
fprintf('  RMS Error: %.6f\n', erms_fourier);
fprintf('  Maximum Error: %.6f at time step %d\n\n', max_error_fourier, max_idx_fourier);

fprintf('Polynomial Model:\n');
fprintf('  Relative Error: %.6f\n', err_poly);
fprintf('  RMS Error: %.6f\n', erms_poly);
fprintf('  Maximum Error: %.6f at time step %d\n', max_error_poly, max_idx_poly);