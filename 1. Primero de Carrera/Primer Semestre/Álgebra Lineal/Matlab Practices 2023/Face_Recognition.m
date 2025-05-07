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

cos = [];
figure % Nueva ventana
for k= 1:N-1
    Ik = img(k).imagen; % Llama la imagen
    subplot(4,6,k) % 4 filas 6 columnas
    imshow(Ik)% Coloca la imagen en el subplot
    Ik = double(Ik(:)); % Incrementa los decimales
    cosk = dot(Ik,I) / (norm(Ik) * norm(I)); % Calcula el cos
    cos = [cos;cosk k]; % Añade la similitud y el ID en orden
end
% Order the cos
clasif = sortrows(cos,'descend'); % Ordena de mayor a menor la primera columna
figure
subplot(1,4,1),imshow(I_new) % La Foto original
subplot(1,4,2),imshow(img(clasif(1,2)).imagen) % La foto más parecida
subplot(1,4,3),imshow(img(clasif(2,2)).imagen) % La segunda más
subplot(1,4,4),imshow(img(clasif(3,2)).imagen) % La tercera