function [sol, k] = Gauss_Seidel_iter(A,b,tol,Nmax)
% Gauss Seidel Method

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

while err > tol && k < Nmax
    k = k+1;
    for i = 1:n
        x(i) = (b(i) - A(i,1:i-1) * x(1:i-1) - A(i,i+1:n) * x0(i+1:n)) / A(i,i);
    end
    err = norm(x-x0); % Absolute error
    x0 = x;
end
sol = x;
end

