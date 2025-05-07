function [steps] = newton2(f, df, x0, T, Nmax)
% Computes the aproximation ofzeros of a function in [a,b] with the
% newton method using for
%   INPUT:  f = function
%           df = derivate of f
%           x0 = value in the x axis (seed)
%           T = tolerance error
%           Nmax = maximum number of steps
%   OUTPUT: sol = approximation of the zero
%           N = number of done steps
figure
a = 1;
fplot(f, [x0-a, x0+a], 'b', 'LineWidth', 1.5);
hold on
yline(0,'-k')
plot([x0 x0], [0 f(x0)], 'ob')

steps = [];

if f(x0) == 0
    dips('Exact solution');
else % apply newton
    for N = 1:Nmax
        % Compute the next approximation
        fx = f(x0);
        dfx = df(x0);
        if dfx == 0
            disp('Derivative is zero. Newton method fails.');
            return;
        end
        x1 = x0 - fx / dfx; % Newton-Raphson formula

        plot([x0 x0], [0 f(x0)], 'or'); % vertical line x0
        plot([x0 x1], [f(x0) 0], '--r'); % tangent
        
        steps = [steps, x1];
        
        if abs(x1 - x0) <= T * abs(x0)
            disp('Solution found with tolerance');
            break;
        end

        % Update the solution
        x0 = x1;
    end

    if N == Nmax
        disp('Maximum number of iterations reached');
    end
end
end
