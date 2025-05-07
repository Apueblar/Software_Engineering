%% Final Exercises:
%% 1.
10000 / (400 + 6 * 500) % A)

270^(1/3) * (690 + 876) % B)

(500 * (645+7843)) / (45 + 9) % C)

(21 + 78) / (43^(1/2) + 80^3) % D)

%% 2.
syms x
f = @(x) x^2 / (6 * x + x^3);
a = vpa(subs(f,1))
b = vpa(subs(f,-0.5)) % A)

syms x
f = @(x) sin(x) / (1 + cos(x));
a = vpa(subs(f,2))
b = vpa(subs(f,pi/90)) % B)

syms x
f = @(x) log(abs(x+2));
a = vpa(subs(f,4))
b = vpa(subs(f,-2))
c = vpa(subs(f,-10)) % C)

syms x
f = @(x) exp(x) / exp(2 * x + 1)
a = vpa(subs(f,5))
b = vpa(subs(f,-2)) % D)

%% 3.
syms x
f = x^3 - 3*x + 2;
solve(f) % A)

syms x
f = x^4 - 2*x + 1
vpa(solve(f)) % B)

syms x
f = log(x^2 - 1) - 1
vpa(solve(f)) % C)

syms x
f = sin(x) + 1
solve(f) % D)

%% 4.
syms x
f = x * sin(x);
g = x^2 - 1;
h = exp(x + 3);

i = compose(h,compose(g,f));
j = compose(f,compose(g,h));
k = compose(h,finverse(h));
l = compose((f + g),h);
m = compose(f,(g + h));
n = subs(f,x,2) * subs(g,x,3);
o = (subs(f,x,1) + subs(g,x,4)) * subs(h,x,4); 