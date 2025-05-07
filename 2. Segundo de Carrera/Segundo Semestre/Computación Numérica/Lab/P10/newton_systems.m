function [sol,k] = newton_systems(f,J,x0,tol,Nmax)
% Non Linear Systems
% f, J must be vector funtions (not sym)
k = 0;
err = 1;
while err > tol && k < Nmax
    k = k+1;
    % Solve the linear system J*delta = -f(xk)
    delta = -J(x0)\f(x0);
    x = x0 + delta;
    err  = norm(x-x0);
    x0 = x;
end
sol = x;

if err < tol
    disp(['The method Converged in ', num2str(k), ' iterations'])
else
    disp('The method doesn''t converge')
end
end

