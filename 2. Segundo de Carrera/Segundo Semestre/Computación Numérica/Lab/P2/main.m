%% Practice 2
%% Newton-Raphson’s Method:
f=@(x) x.^3-3.*x.^2-18.*x+17;
syms x; 
f_sym(x) = f(x);

df_sym = diff(f_sym);
df = matlabFunction(df_sym);

T = 10^-6;
Nmax = 200;
format short

x = -3;
[sol,N] = newton(f,df,x,T,Nmax)

x = 2;
[sol,N] = newton(f,df,x,T,Nmax)

x = 6;
[sol,N] = newton(f,df,x,T,Nmax)

%% Newton-Raphson’s Method 2:
f=@(x) x.^3-3.*x.^2-18.*x+17;
syms x; 
f_sym(x) = f(x);

df_sym = diff(f_sym);
df = matlabFunction(df_sym);

T = 10^-6;
Nmax = 200;
format short

x = -3;
steps = newton2(f,df,x,T,Nmax)

x = 2;
steps = newton2(f,df,x,T,Nmax)

x = 6;
steps = newton2(f,df,x,T,Nmax)

%% Secant Method:
f=@(x) x.^3-3.*x.^2-18.*x+17;
T = 10^-6;
Nmax = 200;
format short

sol = secant(f,-4,-2,T,Nmax)

sol = secant(f,0,2,T,Nmax)

sol = secant(f,4,6,T,Nmax)

%% Fix-Point: f(x) = 0
clear
close all
clc

f = @(x) x.^3 + x - 1; % f(x) = 0 -> g(x) = x
g = @(x) 1 - x.^3;

fplot(g,[-1 1], 'm');
hold on; 
fplot(@(x) x,[-1 1], 'r');
yline(0, '-k');


x0 = 0.6;
gd = @(x) -3*x.^2;
abs(gd(x0)) % = 1.8 > 1 -> must be < 1

% so Reorganize g
g = @(x) (1 - x).^(1/3);
fplot(g,[-1 1], 'm');

T = 10^-6;
Nmax = 200;
sol = fixpoint(g, 0.6, T, Nmax)

%% Ex 1: NEWTON
clear
close all
clc

f = @(x) x.^5 - 10.5444.*x.^4 + 10.9647.*x.^3 + 38.4992.*x.^2 + 6.5594.*x + 28.6988;

% roots in the interval [−2,9]
incrementalSearch(f,-2,9,11)

% Newton's method
syms x; 
f_sym(x) = f(x);
df_sym = diff(f_sym);
df = matlabFunction(df_sym);

x0 = 8.5;  % Midpoint of interval [8, 9]
T = 1e-9;  % Tolerance
Nmax = 200;
[x0,N] = newton(f, df, x0, T, Nmax)

%% Ex 2: SECANT
clear
close all
clc

f = @(x) x.^4 - 1.5860.*x.^3 - 8.0255.*x^2 - 4.7580.*x - 33.0766;
format long

x0 = 3.707;
x1 = 4.307;
T = 1e-3;
Nmax = 200;

x_sec = secant(f, x0, x1, T, Nmax)

x_fze = fzero(f, x0);

Er = abs((x_fze - x_sec) / x_fze);
error_value = 1e5 * Er

%% Ex 3:
clear
close all
clc

g = @(x) 0.3565.*cos(x) + 1/(x+1) + 2;

fplot(g,[1 6], 'm');
hold on;
fplot(@(x) x,[1 6], 'r');

x0 = 3.5;
T = 1e-9;
Nmax = 200;
format short
x_aprox = fixpoint(g, x0, T, Nmax)

%% Contractivity Condition Verification - Homework
clear
close all
clc
g1 = @(x) cos(x);
g2 = @(x) 2.*x - cos(x);
g3 = @(x) x - (x - cos(x)) ./ (1 + sin(x));

% Small interval near the root
a = 0.1;
b = 1.1;

% Check contractivity condition for each function
fprintf('\nChecking contractivity conditions:\n');
possible_g1 = contract_cond(g1, a, b);
possible_g2 = contract_cond(g2, a, b);
possible_g3 = contract_cond(g3, a, b);

fprintf('\n');
x0 = 0.55;
T = 1e-9;
Nmax = 200;

% If possible, aply fix-point
if possible_g1
    fprintf('Fix-Point Approximation for g1:\n');
    root_g1 = fixpoint(g1, x0, T, Nmax)  
end

if possible_g2
    fprintf('Fix-Point Approximation for g2:\n');
    root_g2 = fixpoint(g2, x0, T, Nmax)
end

if possible_g3
    fprintf('Fix-Point Approximation for g3:\n');
    root_g3 = fixpoint(g3, x0, T, Nmax)
end