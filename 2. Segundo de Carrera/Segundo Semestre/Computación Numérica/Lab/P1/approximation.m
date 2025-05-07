function [sol,N] = approximation(f,n,T)
%Calculates the approximation of a series given a tolerance
%   INPUT:  f = The function
%           n = The initial value to start the series
%           T = Tolerance
%   OUTPUT: sol = The approximation
%           N = The number of terms
sol = 0;
relative_error = inf;

while relative_error > T
    current = f(n);
    relative_error =  abs(current / sol);
    sol = sol + current;
    
    n = n + 1;
end
N = n - 1;

end