
function result = mvgamma(input, dim)

% the multivariate gamma distribution, sometimes written Gamma_{dim}(input)

d = dim;

t1 = pi^(d * (d-1) / 4);

t2 = 1;

for i = 1 : d
	
	t2 = t2 * gamma((2*input + 1 - i)/2);
	
end

result = t1 * t2;