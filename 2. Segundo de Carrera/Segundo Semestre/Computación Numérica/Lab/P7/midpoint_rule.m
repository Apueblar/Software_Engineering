function I_mid = midpoint_rule(f, a,b ,n)
% Approximates the integral of f at [a,b]
%   INPUT:  f = The numerical function
%           a,b = extremities of the integration interval
%           n = number of subintervals
%   OUTPUT: I_mid = The approximation of the integral
h = (b-a)/n; % Step
x_mid = linspace(a+(h/2), b-(h/2), n); % Vector of midpoints
I_mid = sum(h.*f(x_mid)); % same as I_mid = h*sum(f(x_mid));
end

