function x_mapped = transform_range(x, a, b)
% Transforms x from [-1,1] to [a,b]
% INPUT:  x = values in [-1,1]
%         a, b = new interval endpoints
% OUTPUT: x_mapped = values in [a,b]

x_mapped = (b - a) / 2 * x + (a + b) / 2;
end
