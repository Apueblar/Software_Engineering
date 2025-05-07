function [sol, N] = bisection_while(f, a, b, T, Nmax)
%Computes an approx. of zeros of a function in [a, b]
% using the bisection ,method with whiles
%   INPUT: f function which zeros are wanted
%          a, b = the extremities of the interval
%          T = tolerance 
%          Nmax = maximum number of steps
%   OUTPUT: sol = approx. of the zeros
%           N number of steps done

fplot(f,[a,b], 'b', 'LineWidth', 1.5), hold on
yline(0, '-k')

% check that we can apply the method
if f(a)*f(b)>0
    error('Bisection cannot be applied. Give another interval')
    sol=[];
    N=[];
elseif f(a)==0
    display('Exact solution')
    sol=a;
elseif f(b)==0
    display('Exact solution')
    sol=b;
else % bisection can be done, f(a)*f(b) < 0
    N=1; % initialize the counter
    stopping_cond=0;
    while stopping_cond==0 && N<=Nmax
        x = (a+b)/2; %mid point
        if f(x)==0 
            display('Exact solution')
            break
        end
        
        if f(a)*f(x)<0 %zero in [a,x]
            b=x; % move the b
        else % zero is in [x, b]
            a=x; % move the a
        end
        N = N+1;
        stopping_cond = abs(b-a)/2 <=T;
        plot(a,0,'go',b,0,'mo')
        plot([x x], [0,f(x)], '--m')
    end
    sol=x;
end