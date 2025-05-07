function possible = contract_cond(g, a, b)
% Checks if it is posible to apply the Fixed point method of a function g,
% in a closed interval [a,b]
%   INPUT:  g = function with f.p. -> g(x) = x
%           a = Start of the interval
%           b = Finish of the interval
%   OUTPUT: possible = Returns 1 if contractive, 0 otherwise

% Calculate derivative
syms x;
g_sym = g(x);
dg_sym = diff(g_sym);
dg = matlabFunction(dg_sym);

dg_values = abs(dg(linspace(a, b, 1000)));

figure
fplot(dg, [a,b], 'b');
hold on
yline(-1,'-r')
yline(1,'-r')

if max(dg_values) < 1
    possible = 1;
    disp('The function satisfies the contractivity condition.');
else
    possible = 0;
    disp('The function does NOT satisfy the contractivity condition.');
end
end