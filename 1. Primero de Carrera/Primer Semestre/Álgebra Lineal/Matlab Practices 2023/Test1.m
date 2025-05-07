clear all
clc
%% Ex1:
z1=4-2i;
z2=4+2i;
a1 = angle(z1);
a2 = angle(z2);
L = isequal(a1,a2);
m1 = abs(z1);
m2 = abs(z2);
M = isequal(m1,m2);
L
M

%% Ex2:
% x^5+2x^4−2x^2+6x+4=0
p = [1 2 0 -2 6 4];
R = roots(p);
% Find real solutions:
ind_re = find(real(R)==R);
G = sum(R(ind_re))

% Sum of the solutions:
S = sum(R)% Suma

%% Ex3:
n = 6;
z = 5-4i;
% w^n=z
mod = abs(z); % módulo
a = angle(z); %angulo
sol = []
for k=1:n
    zk = nthroot(mod)*exp(i*(a+2*k*pi)/n);
    sol=[sol zk]; %Añadir soluciones
end
S_sol = sum(sol)




