%% Ex 1:
clear
clc

p = [1, 4, -2, 3, 0, 3];

sol = roots(p)

% Find real solutions:
ind_re = find(real(sol)==sol);
sum(sol(ind_re))

% Sum of the solutions:
S1 = sum(real(sol))
S2 = sum(imag(sol))

%% Ex 2:
z = 4 - 3i;

mod = abs(z);
angle = angle(z);

n = 5;

% Calculate nth roots
roots = zeros(1, n);
for k = 0:n-1
    roots(k+1) = nthroot(mod, n) * exp((angle + 2*k*pi)/n * 1i);
end

disp(roots);

% Plot
figure;
plot(real(roots), imag(roots), 'o', 'MarkerSize', 5);
title('5th Roots of 4 - 3i');
xlabel('Real Part');
ylabel('Imaginary Part');
grid on;

% Calculate and display the sum of roots in the first quadrant
roots_in_first_quadrant = roots(imag(roots) > 0 & real(roots) > 0);
sum_in_first_quadrant = sum(roots_in_first_quadrant)

%% Ex 3:
A = [0 -1 -1; 3 -3 -1; 2 1 2; 1 0 0];
rank_A = rank(A)

u = [-1; 1; 3; -1];
Aumu = [A u];

rAumu = rank(Aumu)

U2 = [-1; 12; 10; 3];

Aumw = [A U2];

rank_augmented_w = rank(Aumw)

coefficients_w = A\U2

%% Ex 4:
u1 = [2; 1; -2; 2];
u2 = [1; 1; 1; -1];
u3 = [0; 1; 2; 1];

v1 = [-2; -2; -1; -1];
v2 = [3; 2; -3; 6];

U1_matrix = [u1 u2 u3];
U2_matrix = [v1 v2];

% U+V
M = [u1 u2 u3 v1 v2]'
E = rref(M) %The standar basis of R4

%  U∩V 
 
int = [U1_matrix U2_matrix];
E1 = null(int)

%% Ex 5:
temperature = [0.43324 0.39569 0.53988 -0.40252 -0.55704 -1.1048 -1.5783 -1.0926 -1.3789 -0.67594];
time=[1:10];

xx = time - time(1) % Para empezar en 0
xx = xx(:) % o xx'

yy = temperature;

plot(xx,yy,'m*')% Plot the data

% Modaliza this data using a 3rd degree polynomial
% p = a0 + a1x + a2x^2 + a3x^3 = yy
m = length(xx) % = length(xx) es lo mismo
A = [ones(m,1) xx xx.^2 xx.^3]; % The matrix of coeficientes - xx.^2 eleva al cuadrado miembro por miembro
b = yy(:);

sol = A\b % A\b == A^-1 * b
% sol = a0, a1, a2, a3
y_pred = A * sol;
hold on
plot(xx,y_pred,'b')

a0 = sol(1);
a1 = sol(2);
a2 = sol(3);
a3 = sol(4);
% Predict the next year: Jan 2022
x = xx(end) + 1; % Next time
pred = a0 + a1*x + a2*x^2 + a3*x^3
plot(x,pred,'ro')

%% Ex 6:
u1 = [1; -1; -1];
u2 = [-1; 2; 0];

w = cross(u1, u2)

v = [-4; -2; -2];

% Compute the dot products and norms
dot_u1_v = dot(u1, v);
dot_u1_u1 = dot(u1, u1);
dot_u2_v = dot(u2, v);
dot_u2_u2 = dot(u2, u2);

% Orthogonal projection
proj_U_v = (dot_u1_v / dot_u1_u1) * u1 + (dot_u2_v / dot_u2_u2) * u2

