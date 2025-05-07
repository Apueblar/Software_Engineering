function sol = Laplacian(f, x, y, h)
% Approximates the Laplacian of f(x, y) at a given point
% using second-order centered differences
if h <= 0
    error("Step size h must be positive.");
end

hx = h;
hy = h;

% Second partial with respect to x
d2fx = (f(x + hx, y) - 2*f(x, y) + f(x - hx, y)) / (hx^2);

% Second partial with respect to y
d2fy = (f(x, y + hy) - 2*f(x, y) + f(x, y - hy)) / (hy^2);

% Laplacian
sol = d2fx + d2fy;
end


