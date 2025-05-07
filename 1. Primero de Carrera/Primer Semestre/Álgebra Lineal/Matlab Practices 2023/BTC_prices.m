% Prises of BTC
% https://coinmarketcap.com/es/currencies/bitcoin/
clear
clear all
clc
%% Data:
% Prices:
y2017 = [962 968 1181 1065 1333 2276 2531 2890 4708 4334 6400 10082];
y2018 = [14135 10170 10514 6936 9299 7558 6369 7734 7038 6582 6327 4001];
y2019 = [3738 3475 3854 4106 5327 8524 11438 10033 9536 8246 9167 7569];
y2020 = [7201 9389 8659 6441 8828 9509 9156 11328 11683 10722 13838 19446];
y2021 = [29029 33014 45834 59195 56850 36772 34716 41604 46952 43479 61433 57304];
y2022 = [46430 38458 43152 45772 38360 31782 18767 23808 20206 19423 20477 17135];
y2023 = [16532 23184 23181 28388 29348 27092 30476 29240 25934 27007 34580];
price = [y2017 y2018 y2019 y2020 y2021 y2022 y2023];
yy = price;

dic2023 = 40000; % Imaginary price BTC - The one to predict

% Months
months=[1:length(yy)]; % From 1-2017 / 10-2023
xx = months - months(1); % Para empezar en 0
xx = xx(:); % o xx'

plot(xx,yy,'m*')% Plot the data

%% Modaliza this data using a 5rd degree polynomial
% p = a0 + a1*x + a2*x^2 + a3*x^3 + a4*x^4 + a5*x^5 + a6*x^6 + a7*x^7= yy
% A * (ak) = b
m = length(xx);
A = [ones(m,1) xx xx.^2 xx.^3 xx.^4 xx.^5 xx.^6 xx.^7]; % The matrix of coeficientes
b = yy(:);

sol = A\b; % A\b == A^-1 * b
% sol = a0, a1, a2, a3, a4, a5, a6, a7
y_pred = A * sol;
hold on
plot(xx,y_pred,'b')

a0 = sol(1);
a1 = sol(2);
a2 = sol(3);
a3 = sol(4);
a4 = sol(5);
a5 = sol(6);
a6 = sol(7);
a7 = sol(8);

%% Predict nov2023:
x = xx(end) + 1; % Next month
prediction = a0 + a1*x + a2*x^2 + a3*x^3 + a4*x^4 + a5*x^5 + a6*x^6 + a7*x^7
plot(x,prediction,'ro')
plot(x, dic2023,'go')
grid on