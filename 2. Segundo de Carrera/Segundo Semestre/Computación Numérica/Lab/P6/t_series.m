%% Time Series
clear
close all
clc
% Generate temporal series
rng(42); % Number of points

n = 100; h = 0.1;
t = [0:h:n-1];
t = t(:); % Column vector
m = length(t); % Number of points

f = 0.1 * t.^2-2*t+10+3*sin(2*t);
% Add noise to f
noise = randn(m,1)*3;

f = f + noise; % Function with noise (time series)

plot(t,f,'-m')

% Fitting a ploynomial
p = polyfit(t,f,2); % Second degree pol
p_val = polyval(p,t);
hold on
plot(t,p_val,'b-')

% Numerical Derivatives
df = (f(3:end) - f(1:end-2)) / (2*h);
df_a = (f(2) - f(1)) / h;  % First derivative at the second point
df_b = (f(end) - f(end-1)) / h;  % First derivative at the last point

df = [df_a; df; df_b];

figure
plot(t,df,'r-') 
hold on
% Symbolic derivative
syms x
f_sym = 0.1 * x.^2 - 2*x + 10 + 3*sin(2*x); % Define symbolic function
df_sym = diff(f_sym, x); % Symbolic derivative

% Substitute t values into symbolic derivative
df_sym_values = double(subs(df_sym, x, t)); 

% Plot the symbolic derivative
plot(t, df_sym_values, '-k');


















