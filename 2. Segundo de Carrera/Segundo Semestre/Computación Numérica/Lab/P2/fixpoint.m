function sol = fixpoint(g, x0, T, Nmax)
% Computes the aproximation ofzeros of a function given x0 and x1 with the
% secant method using for
%   INPUT:  g = function with f.p. -> g(x) = x
%           x0 = Starting point
%           T = tolerance error
%           Nmax = maximum number of steps
%   OUTPUT: sol = approximation of the zero
%           N = number of done steps
figure
a = 1;
fplot(g, [x0-a, x0+a], 'm', 'LineWidth', 1.5);
hold on
yline(0,'-k') %Ox
plot([x0 x0], [0 g(x0)], '--b')
fplot(@(x)x, [x0-a, x0+a], '-r')

fprintf('+---+------+-------+\n')
fprintf('| n |   x  |  Err  |\n')
fprintf('+---+------+-------+\n')
fprintf('|%3i|%6.4f|%7.1e|\n', 0, x0, 0)

for N = 1:Nmax
    % Compute the next approximation
    x1 = g(x0);
    
    plot([x0 x0], [x0 x1], '--b')
    plot([x0 x1], [x1 x1], '--b')

    fprintf('|%3i|%6.4f|%7.1e|\n', N, x1, abs(x1 - x0)/abs(x0))

    if abs(x1 - x0) <= T * abs(x0)
        disp('Solution found with tolerance');
        break;
    end

    x0 = x1;
end
sol = x0;
end
