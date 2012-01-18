
function prob = my_log_dirpdf(p, q)





k = length(q);


t1 = 0;

for i = 1 : k
	
	t1 = t1 + (q(i)-1)*log(p(i));
	
end


t2 = my_log_gamma(sum(q));


t3 = 0;

for i = 1 : k
	
	t3 = t3 + my_log_gamma(q(i));
	
end


prob = t1 + t2 - t3;
