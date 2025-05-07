function f = fact(N)
%Computes the factorial of a number
%   INPUT:  N = number
%   OUTPUT: f = factorial of N

if N >= 0 && round(N) == N
    f = 1;
    for k=1:N
        f=f*k;
    end
else
    % error('The number is not negative or is not an integer')
    disp('The number is not negative or is not an integer');
    f = [];
end
end

