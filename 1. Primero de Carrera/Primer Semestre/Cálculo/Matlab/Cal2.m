u = [4 -6 5]
v = linspace(0,1,1000) % linspace(a,b,n) a[inicio], b[final], n[cantidad de segmentos]
x = [-1:0.001:1]; % a:h:b a[inicio], h[lo que se suma], b[límite máximo]
y = x.^2;
w = x.^3;
plot(x,y,'r',x,w,'b');
%fplot(y,[0,1]);

%%
x = -pi:0.01:pi;
y1 = cos(x);
y2 = sin(x)
plot(x,y1,x,y2)
axis([-pi,pi,-1,1]) % axis([x1,x2,y1,y2]
grid on
%% 
x1 = 0:1:5;
y1 = [102.9, 75.8, 56.1, 42.2, 31.1, 23.6];
x2 = 0:0.01:5;
y2 = 102.04  * exp(-0.29 * x2);
plot(x1,y1,'r*',x2,y2,'c')
grid on
%%
figure(1) % Crea una ventana
syms x
ezplot(x^2,[-3,3])
grid on
hold on % Continua en la misma gráfica para dibujar otra cosa
hold off % Reinicia a como siempre
close all % Cierra todas las graphic windows
%%
x1=[-5:0.01:1];
x2=[1:0.01:3];
x3=[3:0.01:5];
y1=(2*x1.^2+3)/5;
y2=6-5*x2;
y3=x3-3;
plot(x1,y1,x2,y2,x3,y3)
grid on
%%
clear all
clc
syms x
f=1/(1+2^(1/x))
pretty(f)
figure(1)
ezplot(f,[-1 1])
figure(2)
ezplot(f,[-1 0])
hold on
ezplot(f,[0 1])
axis([-1,1,-0.2,1.2])

%%
syms x
limit(sin(x)/x,x,0)
limit((x-2)/(x^2-4),x,2)
limit(1/x,x,0)
limit(1/x,x,0,'right')
limit(1/x,x,0,'left')
limit(1/x,x,+inf)
limit(1/x,x,-inf)

%%
figure('Name','Simulation Plot Window','NumberTitle','off')
%%
syms x
f = log(x^2)/x;
fplot(f)
g = (x^2 + 2)^(1/2);
fplot(g)
%%
clc
x1 = -5:0.01:-1;
y1 = -2.*x1 + 1;
x2 = -1:0.01:0;
y2 = x2.^2;
x3 = 0:0.01:5;
y3 = sin(x3);
plot(x1,y1,x2,y2,x3,y3)
grid on

%%
syms x
limit(((exp(-x)-1)/x),x,0)
limit(cos(x)^(1/x),x,0)