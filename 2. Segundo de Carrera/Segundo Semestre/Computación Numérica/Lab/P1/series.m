function [s,n] = series(a,T,Nmax)
%Computes the sum of a series
%   INPUT:  a = general tem, handle function of n
%           T = tolerance error
%           Nmax = maximum number of steps
%   OUTPUT: s = the sum of the series
%           n = number of done steps

n = 0; % Counter of steps
s1 = 0; % Sum = 0
stopping_cond=0;

% rel_error = abs(Sn+1 - Sn) / abs(Sn) <= T

while stopping_cond==0 && n<Nmax
    n=n+1;
    s=s1+a(n);
    stopping_cond=abs(s-s1) / abs(s1) <= T;
    s1=s;
end

if stopping_cond==0
    disp(['It doesn''t converges with the requested accuracy.'])
    disp('The result is not the solution but the latter amount calculated.')
end
end

