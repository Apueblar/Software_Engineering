function [sol, k] = Gauss_Seidel_matrix(A,b,tol,Nmax)
% Gauss Seidel Matrix Form

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

x0 = zeros(n,1); % Initial guess
err = 1; % Initialize the error
k = 0; % Counter of iterations
x = x0;

[L,D,U] = descomp_LDU(A);

while err > tol && k < Nmax
    k = k+1;
    x = (D + L)^-1 * (b - U * x0)
    err = norm(x-x0); % Absolute error
    x0 = x;
end
sol = x;
end