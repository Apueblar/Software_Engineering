function [sol] = backward_subst(A,b)
% Solves a linear system by backward substitution
% A must be upper triangular

n = length(b); % Number of equations

% Check upper triangular
% for i=2:n
%     if any((A(i,1:i-1) ~= 0))
%         error('The matrix is not upper')
%     end
% end

% OR 
if triu(A) == A
    disp('A is upper triangular')
else
    error('The matrix is not upper')
end

% A is triangular
x = zeros(n,1); % Column with n zeros
for k=n:-1:1 % Start:Step:Fin
    x(k) = (b(k) - A(k,k+1:n) * x(k+1:n)) / A(k,k);
end

sol = x;
end

