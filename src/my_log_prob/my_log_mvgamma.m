
function result = my_log_mvgamma(n, dimension)




d = dimension;

t1 = (d*(d-1)/4) * log(pi);

t2 = 0;

for i = 1 : d

	t2 = t2 + my_log_gamma((2*n + 1 - i)/2);

end

result = t1 + t2;