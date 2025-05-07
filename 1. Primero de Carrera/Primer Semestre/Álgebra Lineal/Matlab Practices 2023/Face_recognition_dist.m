% Face Recognition
clear
clc
close all
% ORL -> Database de caras
load faces.mat
N = length(img);
I_new = img(N).imagen;
imshow(I_new) %Muestra la imagen
I = double(I_new(:)); %Toda la imagen en un vector vertical

dist = [];
figure % Nueva ventana

for k= 1:N-1
    Ik = img(k).imagen; % Llama la imagen
    subplot(4,6,k) % 4 filas 6 columnas
    imshow(Ik)
    Ik = double(Ik(:)); % Incrementa los decimales
    distk = norm(Ik-I); % Calcula la distancia
    dist = [dist;distk k];
end
% Order the distance
clasif = sortrows(dist) % Ordena de mayor a menor
figure
subplot(1,4,1),imshow(I_new)
subplot(1,4,2),imshow(img(clasif(1,2)).imagen) % La foto más parecida
subplot(1,4,3),imshow(img(clasif(2,2)).imagen) % La segunda más
subplot(1,4,4),imshow(img(clasif(3,2)).imagen) % La tercera
