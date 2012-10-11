
function prob = my_log_dircoef(q)





k = length(q);


t1 = my_log_gamma(sum(q));


t2 = 0;

for i = 1 : k
	
	t2 = t2 + my_log_gamma(q(i));
	
end


prob = t1 - t2;
