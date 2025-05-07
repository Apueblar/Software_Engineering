function [sol, k] = Jacobi_iteration(A,b,tol,Nmax)
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

x0 = zeros(n,1); % Initial guess
err = 1; % Initialize the error
k = 0; % Counter of iterations
x = x0;

while err > tol && k < Nmax
    k = k+1;
    
    for i=1:n % Counting the rows (equations)
        x(i) = (b(i) - A(i,[1:i-1,i+1:n]) * x0([1:i-1,i+1:n])) / A(i,i); % Row i --> eq i
    end
    
    err = norm(x-x0); % Absolute error
    x0 = x;
end
sol = x;

end

