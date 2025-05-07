% Prectice 4: Orthogonality, Projections, Least Squares
clear
close all
clc
%% Approximate f(x) by polinomial.
% f(x) = sin(pi*x) by polinomials in R3[x].
syms x
f(x) = sin(pi*x);

v=[1 x x^2 x^3]; % the standard basis of R3[X] - Bc

G_sym = v.' * v % Matriz simbólica de Gramm
G = int(G_sym,x,-1,1); %Numerical Matrix of Gramm / int(f(x),x,a,b)-> Integral definida entre a y b.

b_sym = v.' * f(x) % Matriz simbólica segundo miembro
b = int(b_sym,x,-1 ,1); % Matriz numérica b

% G * α = b
ak = double(G\b) % Numerical solution - % G\b == G^-1 * b
p(x) = v * ak; % Polinomial approximation
% ak = [a0 a1 a2 a3]
%p(x) = a0 + a1*x + a2*x^2 + a3*x^3

% Compare f with the approximation
fplot(f,[-1,1])
hold on % plot in the same window
fplot(p,[-1 1])

tf3=taylor(f,x,0,'order',4)
fplot(tf3,[-1 1])
grid on
