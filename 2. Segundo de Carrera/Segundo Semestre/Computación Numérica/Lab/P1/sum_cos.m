function sol = sum_cos(vector)
% Computes the sum of the cosines of the elements of a given vector, using the  for structure.
%   INPUT:  vector = The vector of angles in radians
%   OUTPUT: sol = Sum of the cosines of all the elements in the vector,
%                 only if they are in the first quadrant

sol = 0;
for i = 1:length(vector)
    while vector(i) < 0
        vector(i) = vector(i) + 2 * pi;
    end
    rem = mod(vector(i), 2 * pi);
    if rem > pi/2
        error('All elements must be in the first quadrant (0 to pi/2 radians).');
    end

    sol = sol + cos(vector(i));
end