function [dfx, dfy] = ForwXCentYGrad(f, x, y, h)
% Approximates the function at (x,y) using forward for x and centered for y
if h <= 0
    error("Step size h must be positive.");
end

hx = h;
hy = h;

dfx = (f(x + hx, y) - f(x, y)) / h; % Forward difference for x
dfy = (f(x, y + hy) - f(x, y - hy))/(2*hy); % Centered difference for y
end

