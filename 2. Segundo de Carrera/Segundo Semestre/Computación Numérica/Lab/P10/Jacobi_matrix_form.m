function [sol, k] = Jacobi_matrix_form(A,b,tol,Nmax)
% Solves a linear system by Jacobi Method
%   INPUT:  A = A squared matrix n*n
%           b = columnwise vector
%           tol = tolerance
%           Nmax = Max number of allowed iterations
%   OUTPUT: sol = solution
%           k = Iterations

% Check that A is square
[m,n] = size(A);
if m ~= n
    error('A is not square!!!')
end

% Convergence Condition
for i = 1:n
    if abs(A(i,i)) <= sum(A(i,:)) - A(i,i)
        error('Convergence Condition violated! :(')
    end
end
% A is strictly diagonal dominant

% Descompose A in L U and D
[L,D,U] = descomp_LDU(A);

x0 = zeros(n,1); % Initial guess
err = 1; % Initialize the error
k = 0; % Counter of iterations

while err > tol && k < Nmax
    k = k+1;
    x = -D^-1 * (L+U)*x0 + D^-1 * b;
    err = norm(x-x0); % Absolute error
    x0 = x;
end
sol = x;
end
