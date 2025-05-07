function [L,D,U] = descomp_LDU(A)
% Decomposes A = L + U + D

d = diag(A);
D = diag(d);
L = tril(A,-1); % Lower without diagonal
U = triu(A,+1); % Upper without the diagonal
end

