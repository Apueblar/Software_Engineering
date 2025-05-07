%% Project 2:
clear
clc
%% Task 1: Generate a random matrix M for a web page graph with N nodes.
N = randi(51) + 49;
A = rand(N);
c = 0.6;
M = double(A > c);

%% Task 2: Define the Google matrix for p = 0.1
T = [];
for i = 1:N
    column_M = M(:,i);
    normalize_M = column_M ./ sum(column_M);
    T = [T normalize_M];
end

B = (1/N) .* [ones(N,N)];
p = 0.1;
G = (1-p) * T + p * B;

%% Task 3: Show that (Lambda​) = 1 is its biggest eigenvalue
eigenvalues = eig(G);
figure;
hold on;
plot(real(eigenvalues), imag(eigenvalues), 'o');
title('Eigenvalues');
xlabel('Real Part');
ylabel('Imaginary Part');
grid on;
axis equal;
axis([-1 1 -1 1]);

max_eigenvalue = max(eigenvalues);

%% Task 4: Finding the eigenvalue of (Lambda​) = 1 by power method
x0 = ones(N, 1) / N;
max_iterations = 1000;
tolerance = 1e-10;

y = G * x0;
lambda_estimate = y(1) / x0(1); 
iterations = 0;

% Power method
while norm(y - lambda_estimate * x0) > tolerance
    iterations = iterations + 1;
    y = G * x0;
    % Extract the eigenvalue estimate of first component (random)
    lambda_estimate = y(1) / x0(1); 

    % Update the guess
    x0 = y;
end

disp("Power method:")
disp(" ")
disp(lambda_estimate)

%% Task 5: Finding the page rank
[T,D] = eig(T);
V1 = D(:,1);
max_V1 = max(V1);
pagenumeration = 1:N;
y = [y pagenumeration'];
sorted_PageRank = sortrows(y, 1, 'descend');

% The first column is the rank, the second the page.
PageRank = [pagenumeration' sorted_PageRank(:,2)];
%% Task 6: Compare the result with the page rank obtained calculating the popularity of a page
Popularity = [];
for i = 1:N
    outputs = sum(M(:,i));
    inputs = sum(M(i,:));
    suma = inputs + outputs;
    Popularity = [Popularity [suma inputs outputs i]'];
end
Popularity = Popularity.';
% Is more important the sum, later in case of draw, the one with higher inputs
Popularity = sortrows(Popularity, [-1 -2], "descend");
Popularity2 = sortrows(Popularity, [-2 -1], "descend");
Popularity = [pagenumeration' Popularity(:,4)];

% Rank, PageRank, Popularity, Popularity by giving more importance to the input
Mixed_pagerank = [PageRank Popularity(:,2) Popularity2(:,4)]