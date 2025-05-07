%% Practice 6
%% Approximation of the 1st and 2nd derivatives
%% Example 1:
clear
close all
clc

% f(x) = sin(x) + x.^2;
f = @(x) sin(x) + x.^2; % Matlab Function (Numerical)

x0 = 1; % The point to compute the derivative
h = 0.1; % Step

% Exact derivatives:
syms x
f_s(x) = f(x); % Symbolic Function
df_s(x) = diff(f_s); % First derivative
df = matlabFunction(df_s);
d2f_s(x) = diff(f_s, 2); % Second derivative
d2f = matlabFunction(d2f_s);

% 1st derivative approx:
df_fw = (f(x0+h) - f(x0)) / h; % Forward Difference in x0
df_c = (f(x0+h) - f(x0-h)) / (2*h); % Central Difference in x0
df_bw = (f(x0) - f(x0-h)) / h; % Backward Difference in x0

% Absolute errors
err_fw = abs(df_fw - df(x0));
err_c = abs(df_c - df(x0));
err_bw = abs(df_bw - df(x0));

% Relative errors
err_fw = abs(df_fw - df(x0)) / df(x0) * 100; %
err_c = abs(df_c - df(x0)) / df(x0) * 100; %
err_bw = abs(df_bw - df(x0)) / df(x0) * 100; %

E = [err_fw, err_c, err_bw]

plot(E, '*m')

% 2nd derivative approx:
d2f_c = (f(x0+h) - 2*f(x0) + f(x0-h)) / (h^2); % Central Difference in x0
err_c = abs(d2f_c - d2f(x0));

%% Gradient
clear
close all
clc

% f (x,y) = x^2 + y^2
% Grid of nodes
a = -5; b = 5; hx = 0.1; % ox
c = -5; d = 5.5; hy = 0.1; % oy
interv_x = [a:hx:b];
interv_y = [c:hy:d];

[xq,yq] = meshgrid(interv_x, interv_y); % Creates the grid

f = xq.^2 + yq.^2 % Function

% Plot f
surf(xq, yq, f)

% Partial Derivatives
df_dx = (f(2:end,:) - f(1:end-1,:)) / hx;
df_dx_end = (f(end,:) - f(end - 1,:)) / hx; % Last Row
df_dx = [df_dx; df_dx_end];

df_dy = (f(:,2:end) - f(:,1:end-1)) / hy;
df_dy_end = (f(:,end) - f(:,end-1)) / hy; % Last Col
df_dy = [df_dy df_dy_end];

% Plot the directions
figure
quiver(xq, yq, df_dx, df_dy)



