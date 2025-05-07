function [zeros_P, dP] = zeros_legendre(n)
% Computes the roots of the Legendre polyn of degree n
%   OUTPUT: zeros_P = roots of P
%           dP = First Derivative of Pn (Legendre Poly) (Handle Function)

syms x % Define the symbolic variable
P = legendreP(n,x); % Matlab integrated Function (Calculates the Legendre Pol) (symbolic pol)

coeff_P = sym2poly(P); % Vector of coeffs

zeros_P = roots(coeff_P); % Zeros of P

dP_sym = diff(P);
dP = matlabFunction(dP_sym);

% Graphics
fplot(P,[-1,1],'m'),hold on
fplot(0,[-1,1],'-g')
plot(zeros_P,0,'ro','MarkerFaceColor','r')
end