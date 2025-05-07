function newton_poly = newton_pol(coeff,x)
% Computes the Newton interpolation pollynomial
%   INPUT:  x = data points
%           coeff = Divided deference coefficients
%   OUTPUT: newton_poly = newton Polynomial

n = length(x);
syms T
newton_poly = coeff(1);
term = 1;
for k = 2:n % Degree of the polynomial is n-1
    term = term*(T-x(k-1));
    newton_poly = newton_poly + coeff(k) * term;
end
end

