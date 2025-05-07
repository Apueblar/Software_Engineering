function [sol] = Gauss_Jordan_rref(A,b)
% Solves a linear system with rref
%   INPUT:  A = MUST BE FULL-RANK -> Invertible
%   OUTPUT: sol = The solution
[m,n] = size(A);
if m == n && rank(A) == n
    E = rref([A b]);
    sol = E(:,end);
else
    error('A is NOT squared or regular (m=n) !!!')
end
end
