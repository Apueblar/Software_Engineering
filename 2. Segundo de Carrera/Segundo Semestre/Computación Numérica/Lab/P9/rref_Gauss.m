function [E] = rref_Gauss(A)
% Computes the rref of a matrix A, for applying to a system
m = size(A,1) % # of equations
for k=1:m
    A(k,:) = A(k,:) / A(k,k); % pivot 1 in position k,k
    % Make zeros in the pivots column
    for i=1:m
        if i ~= k % Different from
            A (i,:) = A (i,:) - A(i,k)*A(k,:);
        end 
    end
end
E = A;
end

