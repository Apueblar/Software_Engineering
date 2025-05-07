function [table, coeff] = div_diff(x,y)
% Computes the divided differences
%   INPUT:  x, y = data points
%   OUTPUT: table = matrix of divided differences
%           coeff = coefficients of the Newton polynomial (first row of the table)
n = length(x);
table = zeros(n, n);
table(:,1) = y; % First column is y values

for j = 2:n % Columns
    for i = 1:(n-j+1) % Rows
        table(i,j) = (table(i+1,j-1) - table(i,j-1)) / (x(i+j-1) - x(i));
    end
end

coeff = table(1,:); % First row contains the coefficients

end


