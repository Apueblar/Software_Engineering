function intervals = incrementalSearch(f, a, b, n)
% incrementalSearch identifies subintervals where f(x) changes sign
%   INPUTS:
%       f - Anonymous function representing f(x)
%       a - Start of the interval
%       b - End of the interval
%       n - Number of subintervals
%   OUTPUT:
%       intervals - A matrix where each row represents a subinterval [xi, xi+1]
%                   satisfying Bolzano's theorem. If none, returns an empty matrix.
figure
fplot(f, [a,b], 'b', 'LineWidth', 1.5);
hold on
yline(0,'-k')
intervals = [];

% Divide the interval [a, b] into n subintervals
x = linspace(a, b, n + 1); % n+1 points to create n subintervals

% Loop through each subinterval
for i = 1:n
    xi = x(i);       % Start of subinterval
    xi1 = x(i + 1);  % End of subinterval
    
    % Check if Bolzano's conditions are satisfied
    if f(xi) * f(xi1) < 0
        % Append the subinterval to the output matrix
        intervals = [intervals; xi, xi1];
    end
end
end