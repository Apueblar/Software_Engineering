%% Project 3: Projecting the Ibex35 onto their components
clear
load('data_Ibex35.mat')
clc
company = string(company);

%% Task 1: Orthogonally project the index onto the companies
% Store datos
companies_data = datos(:,1:35);
index_data = datos(:,end);

% Find projection coefs
covariance_matrix = cov(companies_data);
projection_coef = covariance_matrix \ (companies_data' * index_data);

% Importance of each company
importance = 100 * abs(projection_coef) / sum(abs(projection_coef));

% Find importance ranking
importance_index = 1:35;
importance = [importance, importance_index'];
importance = sortrows(importance, 1, 'descend');

% Display it
disp('Rank | Company | Importance(%)');
disp('------------------------------');
for i = 1:35
    company_name = company{1,importance(i,2)};
    fprintf('%4d | %-7s | %.4f\n', i, company_name, importance(i,1));
end

%% Task 2: Perform the PCA of this data
% 1. Centered matrix
Xc = datos(:,1:36) - mean(datos(:,1:36)); % 60 * 36

% 2. Covariance matrix: 
C = (Xc' * Xc) / (size(Xc, 1) - 1); % 36 * 36

% 3. Rank of C and eigenvalues
rank_C = rank(C); % 36
eigenvalues = sort(eig(C), "descend");

% 4. Find the eigenvectors
V = [];
for i = 1:3
    % Solve the linear system (C - lambda*I)*v = 0
    v = null(C - eigenvalues(i,1)*eye(size(C)));
    
    % 5. Construct V
    V = [V v];
end

% Check that is orthonormal
disp(V' * V)

% 6. Project Xc onto V.
PCA_coor = Xc * V;

% 7. 2D plot
figure;
hold on;
plot(PCA_coor(1:end-1, 1), PCA_coor(1:end-1, 2), 'b*');
plot(PCA_coor(size(PCA_coor,2), 1), PCA_coor(size(PCA_coor,2), 2), 'r*');
grid on;
xlabel('Principal Component 1');
ylabel('Principal Component 2');
title('2D PCA Plot of Companies (Last 60 Days)');

% 8. 3D plot
figure;
plot3(PCA_coor(1:end-1, 1), PCA_coor(1:end-1, 2), PCA_coor(1:end-1, 3), 'b*');
hold on;
plot3(PCA_coor(size(PCA_coor,2), 1), PCA_coor(size(PCA_coor,2), 2), PCA_coor(size(PCA_coor,2), 3), 'r*');
grid on;
hold off;
title('3D PCA Plot with Index Marked');
xlabel('PC1');
ylabel('PC2');
zlabel('PC3');