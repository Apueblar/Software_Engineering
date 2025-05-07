% Derivates
close all
clear
clc
%% Calculation of derivatives
syms x y
% diff(f,x) -> f (d/dx) = f'(x)
diff(x^2,x)
diff(cos(x*y),x)
diff(cos(x*y),y)
diff(x*sin(x),x,3)
diff(log(x),x,2)
f=1/x
diff(f,x), diff(f,x,2), diff(f,x,3)

%% Ex 1.1:
syms x
f=x/(1+x^2); pretty(f)
df=diff(f,x); % Primera derivada
df = simplify(df); pretty(df) % Simplifica la primera derivada y la muestra guapa
d2f=diff(f,x,2);
d2f = simplify(d2f); pretty(d2f)

ezplot(f,[-3,3])
hold on
ezplot(df,[-3,3])
ezplot(d2f,[-3,3])
grid on
legend('f','df','d2f')

%% Ex 1.2:
figure
syms x
f=(x^2-4)/x^3; pretty(f)
df=diff(f)
crit=solve(df,x) % Igualar la derivada a 0 (Critical points)

subs(df,x,-4)
subs(df,x,-1) % To now if it's increasing or decreasing

d2f=diff(f,2)
infl=solve(d2f,x)% Possible inflection points

subs(d2f,x,-5)
subs(d2f,x,-1) 

ezplot(f,[-8,8])
hold on
ezplot(df,[-8,8])
ezplot(d2f,[-8,8])
grid on
legend('f','df','d2f')
title('(x^2- 4)/x^3')

% Asymptote:
limit(f,x,0,'right')
limit(f,x,0,'left')

m=limit(f/x,x,inf)
n=limit(f-m*x,x,inf)

solve(f,x) % Cortes con eje X

% subs(f,x,0) % Cortes eje Y (Esta no tiene 0 en su dominio)

%% Ex 1.3:
syms t
f = (exp((1/2)-(1/t)))/t
df=diff(f)
crit=double(solve(df,t))
limit(f,inf)
limit(f,t,0,'right')
solve(f)
%subs(f,0)
ezplot(f,[0,15])
grid on

%% Taylor polynomials
syms x
f = exp(x), g = cos(x)
% taylor(f , x , a ,'order', n+1)-> Sirve para simpificar límites difíciles
% f -> función a aproximar
% x -> variable
% a -> punto al que aproximar el polinomio
% n+1 -> orden del polinomio que aproxima a f
taylor(f,x,0,'order',5)
taylor(f,x,0,'order',7)
taylor(f,x,2,'order',4)
taylor(g,x,pi/4,'order',5)

%% Ex 2.1:

syms x
f=sin(x);
tf1=taylor(f,x,0,'order',2)
% tf2=taylor(f,x,0,'order',3) % Al ser sin(x) los pares se van
tf3=taylor(f,x,0,'order',4)
% tf4=taylor(f,x,0,'order',5) % Al ser sin(x) los pares se van
tf5=taylor(f,x,0,'order',6)

ezplot(f,[-pi,pi])
hold on
ezplot(tf1,[-pi,pi])
ezplot(tf3,[-pi,pi])
ezplot(tf5,[-pi,pi])
grid on
legend('f','tf1','tf3','tf5')
