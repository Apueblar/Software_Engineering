% Practice 2: Matrices
clear
clc
%% Vectors
v = [-2 3 0 -11 51]; %row vector
w = [2+3i;-1;0;-i]; %colum vector
t = v' %transpose the conjugate
u = w.' %transpose
syms x y
a = [x x^2+y^2 x-y y].'

%% Long vectors
clear
clc

v = linspace(0,1,10) %Divide el intervalo [0,1] en 10 puntos
% v es un row vector
w = [0:0.11:1] %[a:step:b] Suma step desde "a" hasta "b"
% W es un row vector

%% Matrices
clear
clc

A = [1 0 -3 4;0 0 0 1;-11 0 1 5]; % Para cada fila espacio y cada columna ;
B = [3 0 7 -2].'; % Row vector transpuesto
P = A * B;
[ma,na] = size(A); % Incluye el tamaño de A

nr_rows = size(A,1);
nr_colums = size(A,2);

[mb,nb] = size(B);

v = linspace(0,1,10);
N = length(v); % The number of elements

elemA_23 = A(2,3); % 2 row 3 colum

row2A = A(2,:); % All row 2
col3A = A(:,3); %All col 3

O = ones(3,size(A,2)); %Unos

B = [A;O];
Z = zeros(size(B,1),3); %Zeros

C = [B Z];

M = C([3:5],[2:4]); % Cortamos un trozo de C

In = eye(size(A)); %Identidad

R = rand(5,3) %Random

% Matrix to vector
w = R(:) %colum vector

%% Applications to matrices: Images
clear
clc
close all
I1 = imread('playaBW.jpg');
imshow(I1);
max(max(I1));

I2 = I1([1:15],[end-39:end])

figure
imshow(I2);
%Color image
I = imread("playa.jpg");
figure
imshow(I)
Ir = I(:,:,1);
Ig = I(:,:,2);
Ib = I(:,:,3);

figure
imshow(Ir)

figure
imshow(Ig)

figure
imshow(Ib)

%% Vectorial Spaces

v1= [1 2 3]'
v2= [0 0 1]'
v3= [1 0 0]'

B = [v1 v2 v3]
r = rank(B)
E = rref(B)

w = [3 4 5]

Amp = [B w]

sol = R(:,end)