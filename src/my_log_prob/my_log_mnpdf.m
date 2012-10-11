
function prob = my_log_mnpdf(vec, n, p)





t1 = my_log_factorial(n);


k = length(vec);

t2 = 0;

for i = 1 : k
	
	t2 = t2 + vec(i)*log(p(i));
	
end


t3 = 0;

for i = 1 : k
	
	t3 = t3 + my_log_factorial(vec(i));
	
end



prob = t1 + t2 - t3;