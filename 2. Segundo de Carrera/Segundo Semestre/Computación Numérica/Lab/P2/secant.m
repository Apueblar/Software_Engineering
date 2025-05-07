function sol = secant(f, x0, x1, T, Nmax)
% Computes the aproximation ofzeros of a function given x0 and x1 with the
% secant method using for
%   INPUT:  f = function
%           x0 = value 1 in the x axis
%           x1 = value 2 in the x axis x0 < x1
%           T = tolerance error
%           Nmax = maximum number of steps
%   OUTPUT: sol = approximation of the zero
%           N = number of done steps
figure
a = 2;
fplot(f, [x0-a, x1+a], 'b', 'LineWidth', 1.5);
hold on
yline(0,'-k') %Ox
plot([x0 x0], [0 f(x0)], '--b')
plot([x1 x1], [0 f(x1)], '--b')
fprintf('+---+------+-------+\n')
fprintf('| n |   x  |  Err  |\n')
fprintf('+---+------+-------+\n')
fprintf('|%3i|%6.4f|%7.1e|\n', 0, x0, 0)
fprintf('|%3i|%6.4f|%7.1e|\n', 0, x1, 0)
if f(x0) == 0
    dips('Exact solution'), sol = x0;
elseif f(x1) == 0
    dips('Exact solution'), sol = x1;
else % apply secant
    for N = 1:Nmax
        % Compute the next approximation
        x2 = x1 - f(x1) * (x1 - x0) / (f(x1) - f(x0));
        
        plot([x2 x2], [0 f(x2)], '--r')
        plot([x0 x1 x2], [f(x0) f(x1) 0], '-r', x2,0,'or')
        
        fprintf('|%3i|%6.4f|%7.1e|\n', N, x2, abs(x2 - x1)/abs(x1))
        
        sol = x2;
        if abs(x2 - x1) <= T * abs(x1)
            disp('Solution found with tolerance');
            break;
        end
        
        x0 = x1; x1 = x2;
    end
end
end

