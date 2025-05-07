% Practice 4. Functions of a real variable: integration
clear
close all
clc
%% Integral Calculus:
% int(f,x) -> Integral indefinida
% int(f,x,a,b) -> Integral definida entre a y b
syms x y
int(x*exp(x));
int(x*exp(x),0,1);
int(cos(x*y));
int(cos(x*y),y);
syms a b
int(cos(x),a,b);
int(1/x^2,1,inf);
int(1/x,1,inf);

%% Ex1:
%Paso 1: Escribir las eq.
syms x
f = 2*x^3;
g = 8*x;
solve(f-g,x); % Te iguala f-g a 0
%Paso 2: Plot the curve and the line
ezplot(f,[-2.5,2.5])
hold on
ezplot(g,[-2.5,2.5])
grid on
hold off
%Paso 3: Calculate the integral
A = int(abs(f-g),x,-2,2)

%Paso 4: Colorear el area
%Colocar minipuntos
x1=-2:0.01:2;
x2=2:-0.01:-2;

%Metes las funciones
y1=8*x1;
y2=2*x2.^3;

x=[x1 x2];
y=[y1 y2];
patch(x,y,'r')

% Si quieres la integral con 0, y2 = zeros(size(y1))

%% Ex2:
syms x
f = (x^2-1)/(x^2+1);
limit(f,x,inf)
limit(f,x,-inf)

solve(f-1,x); % Al no dar solución, no corta y=1

ezplot(f,[-7.5,7.5])
hold on
ezplot('1',[-7.5,7.5])
grid on
hold off

x1=-7.5:0.01:7.5;
x2=7.5:-0.01:-7.5;
y1=(x1.^2-1)./(x1.^2+1);
y2=ones(size(x2));
xn=[x1 x2];
yn=[y1 y2];
patch(xn,yn,'b')

A = int(1-f,x,-inf,inf)

%% Ex3:
syms x
f = (-x^2 + x + 3)*log(x);
sol = double(solve(f,x));
sol = sort(sol) % Te lo ordena de menor a mayor

ezplot(f,[sol(2),sol(3)]) % Integral entre los positivos
grid on

double(int(f,x,sol(2),sol(3))) %Calcula la integral y te la muestra en número

%We can calculate the volume of a solid generate by rotating x-axis as:
% Vx = pi * int(f^2,x,a,b) - En una pi y f^2

%We can calculate the volume of a solid generate by rotating y-axis as:
% Vy = 2*pi * int(x*f,x,a,b) - En la otra 2pi y x*f

double(pi * int(f^2,sol(2),sol(3)))

double(2*pi * int(x*f,x,sol(2),sol(3))) % El segundo valor ,x, se puede omitir por solo tener una variable

%% Ex4:
format long
syms x
f=exp(-x^2);
double(int(f,0,1))

ezplot(f,[0,1])

x1=-7.5:0.01:7.5;
x2=7.5:-0.01:-7.5;
y1=(x1.^2-1)./(x1.^2+1);
y2=ones(size(x2));
xn=[x1 x2];
yn=[y1 y2];
patch(xn,yn,'b')

% We calculate MacLaurin polynomials of f of order 2, 4, 6, 10 y 14.
% We need to aprrox the value

% taylor(f,x,a,'order',n) -> Taylor polynomial of f of order n − 1 at the point a.

p2 =taylor(f,x,0,'order',3)
double(int(p2,0,1))
p4 =taylor(f,x,0,'order',5)
double(int(p4,0,1))
p6 =taylor(f,x,0,'order',7)
double(int(p6,0,1))
p10=taylor(f,x,0,'order',11)
double(int(p10,0,1))
p14=taylor(f,x,0,'order',15)
double(int(p14,0,1))

%% Ex 2.1:
syms x
int((1+exp(x))^-1,x)
int(sec(x),x)
syms a b
int(exp(a*x)*sin(b*x),x)
int(x^3 * log(x),x)
int(asin(x),x)
int(x * atan((-1 + x^2)^(1/2)),x)

%% Ex 2.2:
double(int(1/(-1 + x^2),x,2,inf))
double(int(1/(x*log(x)^2),x,exp(1),inf))
double(int(x*exp(x),x,-inf,0))
int(1/(1+x^2),-inf,inf)
double(int(x * (x^2 - 9)^(-1/2),x,3,5))
double(int(sin(x),x,-inf,inf))










