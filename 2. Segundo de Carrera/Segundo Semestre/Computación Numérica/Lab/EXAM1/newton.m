function [sol,N] = newton(f, df, x, T, Nmax)
% Computes the aproximation ofzeros of a function in [a,b] with the
% newton method using while
%   INPUT:  f = function
%           df = derivate of f
%           x = value in the x axis
%           T = tolerance error
%           Nmax = maximum number of steps
%   OUTPUT: sol = approximation of the zero
%           N = number of done steps
figure
fplot(f, [x-1, x+1], 'b', 'LineWidth', 1.5);
hold on
yline(0,'-k')

if f(x) == 0
    dips('Exact solution'), sol=x;
else % apply newton
        sol = x;
    for N = 1:Nmax
        % Compute the next approximation
        fx = f(sol);
        dfx = df(sol);
        x_new = sol - fx / dfx; % Newton-Raphson formula

        plot(sol, 0, 'go'); % Mark the current point
        plot([sol sol], [0, f(sol)], '--m'); % Plot the vertical projection to the curve

        if abs(x_new - sol) <= T * abs(sol)
            sol = x_new;
            break;
        end

        % Update the solution
        sol = x_new;
    end

    if N == Nmax
        disp('Maximum number of iterations reached');
    end
end

