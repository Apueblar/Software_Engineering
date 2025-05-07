% Prises of Amazon
% https://www.macrotrends.net/stocks/charts/AMZN/amazon/stock-splits
clear
clear all
clc
%% Data:
years=[2010:2021];
xx = years - years(1) % Para empezar en 0
xx = xx(:) % o xx'
% Stock prices before the split:
stocks=[136.25 181.36 175.88 256.07 398.79 312.57 656.28 757.92 1172 1465.2 1875 3206];
january_22 = 2991.47;
yy = stocks;
% february_22 = 32.95; Dividieron las acciones - Max price nov 21: 3507

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
x = xx(end) + 1; % Next year
pred_22 = a0 + a1*x + a2*x^2 + a3*x^3
plot(x,pred_22,'ro')
plot(x, january_22,'go')