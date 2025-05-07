%% Practice 1
%% Handle Functions:
f = @(x) x.^4;
f(-2)
v = [1 2 3 4];
f(v)

% clc % clears
% clear % removes all variables
%% Transformations of functions:
% Anonymous to Symbolic
syms x
f_sym(x) = f(x);

% Calculate derivative
df_sym = diff(f_sym);

% Symbolic to Anonymous
df = matlabFunction(df_sym);

%% Floor, Ceil, Round
floor(3.9); % Always down
ceil(3.1); % Always up
round(3.5); % Rounds

%% if, else, for
N = 5;
f = fact(N);

%% while
a=@(n) 1/n^2;
T = 10^-6;
Nmax = 10^4;
% format long % High quantity of decimals
% format short % Low quantity of decimals
[s,n] = series(a,T, Nmax)

%% Zeros example
%% Graphical Method:
f = @(x) x.^5 - 3.*x.^2 + 1.6;
a = -2; b = 2;
figure
fplot(f, [a,b], 'b', 'LineWidth', 1.5);
hold on
yline(0,'-k')

%% Bisection Method:
f=@(x) exp(x-2)-log(x+2)-2*x;
a = -1;b = 0;
T = 10^-9;
Nmax = 100;
format long
[sol,N] = bisection_while(f,a,b,T,Nmax)

[sol,N] = bisection_for(f,a,b,T,Nmax)

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

%% Sum_cos
vector = [683/1000,947/1000,99/1000,511/1000,11/100,109/200];
sol = sum_cos(vector)


%% Aprroximation of a series
f=@(x) sin(x)/(5 * x^2 + 4);
n = 1;
T = 10^-6;
[sol, N] = approximation(f,n,T)

%% Find the zero with bisection ex
f=@(x) 2 * cos(x) - 4 * sin(x);
a = 0;
b = 1;
T = 10^-9;
Nmax = 1000;
figure
fplot(f, [a,b], 'b', 'LineWidth', 1.5);
hold on
yline(0,'-k')
[sol,N] = bisection_while(f,a,b,T,Nmax)

%% Incremental Search - Homework
f = @(x) x^3 - x - 1; % Example function
a = -2;               % Start of the interval
b = 2;                % End of the interval
n = 10;               % Number of subintervals

intervals = incrementalSearch(f, a, b, n);
disp(intervals);