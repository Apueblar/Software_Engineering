function [xsol, Ab] = Gauss_Jordan(A,b)
% Gauss_Jordan Solves the system Ax = b using the Gauss-Jordan elimination method.
%   [xsol, Ab] = Gauss_Jordan(A, b) returns the solution vector xsol and the
%   augmented matrix Ab after performing Gauss-Jordan elimination.
%
%   Inputs:
%       A - Coefficient matrix.
%       b - Right-hand side vector.
%
%   Outputs:
%       xsol - The solution of the system Ax = b.
%       Ab   - The final augmented matrix [A | b] after elimination.
Ab = [A b(:)];
n = size(Ab, 1);
for i = 1:n
    % Pivoting
    [~, k] = max(abs(Ab(i:n, i)));
    k = k + i - 1;
    Ab([i k], :) = Ab([k i], :);
    
    % Normalize pivot row
    Ab(i, :) = Ab(i, :) / Ab(i, i);
    
    % Eliminate all other rows
    for j = 1:n
        if j ~= i
            Ab(j, :) = Ab(j, :) - Ab(j, i) * Ab(i, :);
        end
    end
end
% Extract solution vector
xsol = Ab(:, end);
end

