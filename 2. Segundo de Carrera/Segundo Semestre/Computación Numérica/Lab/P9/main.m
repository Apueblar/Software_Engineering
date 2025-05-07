%% Practice 9
% m -> Equations
% n -> Unknowns
% Overdetermined -> m > n
% Underdetermined -> m < n
%% Gaus - Jordan : RREF
clear
clc

A = [2 1 -1; -3 -1 2; -2 1 2];
b = [8; -11; -3];

Ampl = [A b];
% E = rref(Ampl);
% sol= E(:,end);
[sol] = Gauss_Jordan_rref(A,b)

%% Gaus - Jordan: A not full rank
clear
clc

A = [1 2 3; 2 4 6; -3 -6 -9]; b = [1 1 1]';
% Ampl = [A b];
% E = rref(Ampl); % Imposible --> As A is not full rank
% sol= E(:,end); % It is not the solution
[sol] = Gauss_Jordan_rref(A,b)

%% Gaus - Jordan: Partial Pivoting (is rref but created in class)
clear
clc

A = [2 1 -1; -3 -1 2; -2 1 2];
b = [8; -11; -3];

[m,n] = size(A);
if m == n && rank(A) == n
    E = rref_Gauss([A b]);
    sol = E(:,end)
else
    error('A is NOT squared or regular (m=n) !!!')
end

%% Gauss elimination
clear
clc
%% 1) Upper Triangular --> Backward substitution
A = [1 2 3; 0 3 4; 0 0 1];
b = [1 1 1]';

[sol] = backward_subst(A,b)


%% 2) Lower Triangular --> Forward Substitution
A = [1 0 0; 2 3 0; 3 4 5];
b = [1 1 1]';

[sol] = forward_subst(A,b)

%% LU Factorization:
% PAx = Pb
clear
clc
% A = L*U -> Ax = b // LUx = b
% Ux = y -> LUx = b // Ly = b

A = [2 -1 -2; -4 6 3; -4 -2 8];
b = [-2; 9; -5];

[L, U, P] = lu(A);
b1 = P*b;
% Forward Ly = b1
[y] = forward_subst(L,b1);
% Backward Ux=y
[x] = backward_subst(U,y) % == inv(A) * b = sol

%% Symmetric Matrices
clear
clc

A = [1 1 1; 1 2 2; 1 2 6];
b = [0 -1 1]';

[sol] = spectral_decomposition(A, b)

%% Symmetric and Positive Definite: All lambda > 0 in D - Cholesky
clear
clc

A = [1 1 1; 1 2 2; 1 2 6];
b = [0 -1 1]';
L = chol(A);
















































