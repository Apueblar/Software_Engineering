function [sol] = spectral_decomposition(A, b)
% Solves the linear system bt spectral decomposition

if A == A'
    [P,D] = eig(A);
    sol = P*inv(D)*P'*b;
else
    error('A is not Symmetric')
end


end

