function [L] = lagrange(x)
% Function lagrange(x) which constructs the lagrange basis polynomials
% defined by the components of the vector x
% INPUT:    x = Vector with the points which define the polynomials
% OUTPUT:   L = Matrix whose rows are the Lagrange basis polynomials

n = length(x); % number of points
L = zeros(n); % empty matrix
for k = 1:n
    r = x([1:k-1 k+1:n]);
    lk = poly(r);
    L(k,:) = lk / prod(x(k)-r);
end

