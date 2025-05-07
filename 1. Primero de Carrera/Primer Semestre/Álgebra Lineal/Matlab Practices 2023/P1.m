% Practice 1: Complex Numbers
clear
clc
%% Variables
x = 0;
z1 = -1 + 1i;
z2 = 3-2i;
z2_c = conj(z2)
a1 = angle(z1); % z1 argument
m1 = abs(z1); % module of z1
w = [z1 2+5i 10 z2 x];
%% Complex Numbers Operations
r1 = real(z1); % Real part of w
im2 = imag(z2); % Imaginary part of w
w_r = real(w);
w_i = imag(w);
L1 = isequal(z1,z2); % Compares and answer is Logical 1/0
L2 = double(L1); % Transforms to double a variable
% Find
a = [0 -1 3 -34];
ind = find(a < 0); % Finds all the elements in a lower than 0
% Find the real elements in w
w = [w 57];
ind1 = find(real(w) == w); % Find the real numbers
w(ind1) % Shows them
%% Graphs
plot(z1,"*b")
figure % Permite crear otra ventana para otro gráfico
compass(z1,"b")
figure
a2 = angle(z2);
m2 = abs(z2);
polarplot(a2,m2,"*b")
%% Roots
% p = x^5 - 2x^4 +3x -10
p = [1 -2 0 0 3 -10];
sol = roots(p);
% Find real solutions:
ind_re = find(real(sol)==sol);
sol(ind_re)
% Sum of the solutions:
S = sum(sol);% Suma
P = prod(sol); % Producto
%Find the sol in the 1st quadrant
A = angle(sol);
ind_a = find(A > 0 & A < pi/2);
sol_1st = sol(ind_a)

% w^n=z
n=8;
z=1-4i;
mod = abs(z); % módulo
a = angle(z); %angulo
sol = []
for k=1:n
    zk = nthroot(mod,n)*exp(1i*(a + 2*k*pi)/n);
    sol = [sol zk];
end
S_sol = sum(sol)