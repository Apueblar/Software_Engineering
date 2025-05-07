%% Exercise 1:
clear
clc
close all

f = @(x, y) 2.*x.^2 - 4.*x.*y + y.^2;

% a) Design a program that approxiamtes the gradient
% f(x,y) = (partial x, partial y) by using a forward difference formula for
% partial x, and a centered difference formula for partial y. Use this
% program to evaluate the gradient at the point (1,pi/4) with the step h=10^-2.

x = 1;
y = pi/4;
h = 10^-2;

[dfx, dfy] = ForwXCentYGrad(f, x, y, h);
fprintf("Gradient of f(x,y) at (%.2f, %.2f) with step 10^2 is: (%.2f, %.2f)\n", x, y, dfx, dfy);

grad_norm = sqrt(dfx^2 + dfy^2);

% b) Compute also the exact gradient at (1,pi/4) and calculate the absolute
% error for the numerical approximation
syms xsym ysym
f_sym(xsym, ysym) = f(xsym, ysym);

dfx_sym = diff(f_sym, xsym);
dfy_sym = diff(f_sym, ysym);

dfx_exact = matlabFunction(dfx_sym);
dfy_exact = matlabFunction(dfy_sym);

xsol = dfx_exact(1, pi/4);
ysol = dfy_exact(1, pi/4);
sol_norm = sqrt(xsol^2 + ysol^2);

error_x = abs(dfx - xsol);
error_y = abs(dfy - ysol);
error_norm = abs(grad_norm - sol_norm);

fprintf("The absolute error for dfx is: %.d\n", error_x); 
fprintf("The absolute error for dfy is: %.d\n", error_y);  
fprintf("The absolute error for the norm of the gradient is: %.d\n", error_norm);

% c) Design a program to approximate the Laplacian of f(x,y), by using
% a central diference formula for both derivatives defined as:
% f(x,y) = (second partial x + secoond partial y)

% I did the function Laplacian.m
%
%   d2fx ≈ (f(x+h, y) - 2*f(x, y) + f(x-h, y))/(h^2)
%   d2fy ≈ (f(x, y+h) - 2*f(x, y) + f(x, y-h))/(h^2)
%
% And the Laplacian is d2fx + d2fy.

% d) Use this program to compute the approximated Laplacian at (1,pi/4)
% with step size h = 10^-2, and compare it with the exact value. Provide
% the absolute error.

dfx2_sym = diff(dfx_sym, xsym);
dfy2_sym = diff(dfy_sym, ysym);

df2x_exact = matlabFunction(dfx2_sym);
df2y_exact = matlabFunction(dfy2_sym);

xsol_sec = df2x_exact(x, y);
ysol_sec = df2y_exact(x, y);

sol_exact = xsol_sec + ysol_sec;

sol_approx = Laplacian(f, x, y, h);

E_abs = abs(sol_approx - sol_exact);

fprintf("Laplacian of f(x,y) at (%.2f, %.2f) with step 10^-2 is: %.4f\n", x, y, sol_approx);
fprintf("The absolute error for the Laplacian is: %.4e\n", E_abs);

%% Exercise 2:
clear
clc
close all

A = [-4 1 1; 1 -5 2; 1 2 -6];
b = [1, 2, 3]';

% a) Implements a MATLAB script that verifies whether matrix A satisfies
% the conditions required to apply:
%       Orthogonal spectral decomposition method
%       Cholesky factorization
[m,n] = size(A);
if m ~= n
    error('A is not square')
end

ilog = 1; % flag for positive definiteness

% Checking for symmetry using MATLAB's function
if ~issymmetric(A)
    disp("A is not symmetric");
else
    % Checking for positive definiteness using leading principal minors
    for i = 1:n
        minorDet = det(A(1:i, 1:i));
        if minorDet <= 0
            ilog = 0;
            break;  % Once found, exit the loop
        end
    end
    if ~ilog
        disp("A is symmetric but not positive definite");
    else
        disp("A is OK (symmetric and positive definite)");
    end
end

% b) If the conditions are met, use these methods to solve Ax=b.
% Otherwise, explain why the method is not applicable

% Since A is symmetric but not positive definite, these methods are not applicable.
disp("The conditions for spectral decomposition and Cholesky factorization are not met.");


% c) Give also the solution provided by Gauss-Seidle, considering the
% initial guess x0=(0,0,0), tol = 10^-6, and Nmax = 100
% Compare these solutions with the one provided by Gauss-Jordan,
% computing the norm of the residual in each case.
tol = 10^-6;
Nmax = 100;
% [sol, k] = Gauss_Seidel_matrix(A,b,tol,Nmax) % Can be also computed with
% this one (you need to copy, tthe function and the decomposition one)
[solGS, k] = Gauss_Seidel_iter(A, b, tol, Nmax);
disp("Solution provided by Gauss-Seidel is:");
disp(solGS);

[solGJ, Ab] = Gauss_Jordan(A, b);
disp("Solution provided by Gauss-Jordan is:");
disp(solGJ);

% Compute residual norm for Gauss-Seidel solution:
residual_gs = norm(A * solGS - b);
fprintf("Gauss-Seidel: Number of iterations = %d, Residual norm = %.4e\n", k, residual_gs);

% Compute residual norm for Gauss-Jordan solution:
residual_gj = norm(A * solGJ - b);
fprintf("Gauss-Jordan: Residual norm = %.4e\n", residual_gj);

%% Exercise 3:
clear
clc
close all

f = @(x) sqrt(x+0.1);
a = 0;
b = 1;

% a) Consider the interval points (1/5 1/2 4/5).
% Implement an open quadrature rule that approximates the integral between 0 and 1 of f(x)dx using the
% interpolating polynomial through these points.
x = [1/5, 1/2, 4/5];

% Compute the Lagrange basis polynomials and integrate to get wk
syms t
L1 = ((t - x(2))*(t - x(3))) / ((x(1) - x(2))*(x(1) - x(3)));
L2 = ((t - x(1))*(t - x(3))) / ((x(2) - x(1))*(x(2) - x(3)));
L3 = ((t - x(1))*(t - x(2))) / ((x(3) - x(1))*(x(3) - x(2)));

c1 = double(int(L1, a, b));
c2 = double(int(L2, a, b));
c3 = double(int(L3, a, b));

c = [c1, c2, c3];

% Approximate the integral
I_approx = c1*f(x(1)) + c2*f(x(2)) + c3*f(x(3));

fprintf('Weights: c1 = %.6f, c2 = %.6f, c3 = %.6f\n', c1, c2, c3);
fprintf('Approximated integral = %.6f\n', I_approx);

% b) Compute also the exact value of the integral, and calculate the
% absolute error of your approximation.
I_exact = integral(f, a, b);
E_abs = abs(I_approx - I_exact);

fprintf('Exact integral (numerically) = %.6f\n', I_exact);
fprintf('Absolute error = %.6e\n', E_abs);

% c) Compare your rule with the open Simpson rule, through their relative
% errors.
h = (b - a) / 4;
x_open_simpson = [a + h, a + 2*h, a + 3*h];  % [1/4, 1/2, 3/4]
I_simpson = (4*h/3) * (f(x_open_simpson(1)) + f(x_open_simpson(2)) + f(x_open_simpson(3)));

% Relative errors
rel_error_custom = abs(I_approx - I_exact) / abs(I_exact);
rel_error_simpson = abs(I_simpson - I_exact) / abs(I_exact);

fprintf('Open Simpson approximation: %.10f\n', I_simpson);
fprintf('Relative error (custom rule): %.2e\n', rel_error_custom);
fprintf('Relative error (open Simpson): %.2e\n', rel_error_simpson);