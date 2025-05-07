function [sol] = forward_subst(A,b)
% Solves a linear system by forward substitution
% A must be lower triangular

n = length(b); % Number of equations

% Check lower triangular
if tril(A) == A
    disp('A is lower triangular')
else
    error('The matrix is not lower')
end

% A is triangular
x = zeros(n,1); % Column with n zeros
for k=1:n % Start:Step:Fin
    x(k) = (b(k) - A(k,1:k-1) * x(1:k-1)) / A(k,k);
end

sol = x;
end
