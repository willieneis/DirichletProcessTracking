
function log_mvncoef_ratio = my_log_mvncoefratio(obs, params)





n = size(obs, 1);

d = size(obs, 2);

params_n = update_mvn_params(obs, params);




t1 = my_log_mvgamma(params_n{5}/2, d);

t2 = (params{5}/2) * log(det(params{4}));

if params{7} > 0
	
	t3 = (d/2) * log(params{7});

else

	t3 = 0;

end

t4 = (n*d/2) * log(pi);

t5 = my_log_mvgamma(params{5}/2, d);

t6 = (params_n{5}/2) * log(det(params_n{4}));

if params{7} > 0
	
	t7 = (d/2) * log(params_n{7});

else

	t7 = 0;

end


log_mvncoef_ratio = t1 + t2 + t3 - t4 - t5 - t6 - t7;





