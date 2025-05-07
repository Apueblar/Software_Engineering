function [sol,N] = bisection_while(f, a, b, T, Nmax)
% Computes the aproximation ofzeros of a function in [a,b] with the
% bisection method using while
%   INPUT:  f = function
%           a = extreme a of the interval
%           b = extreme b of the interval
%           T = tolerance error
%           Nmax = maximum number of steps
%   OUTPUT: sol = approximation of the zero
%           N = number of done steps
figure
fplot(f, [a,b], 'b', 'LineWidth', 1.5);
hold on
yline(0,'-k')

% Check that we can start:
if f(a) * f(b) > 0
    error('Bisection cannot be applyed. Give another interval')
    sol=[];N=[];
elseif f(a) == 0
    dips('Exact solution'), sol=a;
elseif f(b) == 0
    dips('Exact solution'), sol=b;
else % apply bisection
    N = 0;
    while f(a)*f(b) < 0 && N < Nmax
        N = N + 1;
        M = (a+b)/2;
        sol = M;
        if f(M) == 0
            disp('Exact solution'), sol = M; break;
        %elseif (b - a) / 2 < T
        %    disp('Approximated solution'), sol = M; break;
        elseif f(a)*f(M) < 0 % zero in (a,M)
            b = M;
        else % zero in (M,b)
            a = M;
        end
        plot(a,0,'go', b,0,'mo');
        plot([M M], [0, f(M)], '--m');
    end

    if N == Nmax
        disp('Maximum number of iterations reached');
    end
end

