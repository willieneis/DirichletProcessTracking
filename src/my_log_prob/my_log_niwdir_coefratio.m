function log_niwdir_coefratio = my_log_niwdir_coefratio(obs, params)

addpath('~/proj/ddpTracking/src/mcmc/');


params_n = update_mvnmn_params(obs, params);


n = size(obs, 1);

% for spatial dimensions
d = 2;




% compute log niw coef ratio

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


log_niw_coefratio = t1 + t2 + t3 - t4 - t5 - t6 - t7;



% compute log dir coef ratio

%log_dir_coefratio = my_log_dircoef(params{8}) - my_log_dircoef(params_n{8} / sum(obs(3:end-1)));
log_dir_coefratio = my_log_dircoef(params{8}) - my_log_dircoef(params_n{8});



% compute log niwdir coef ratio

log_niwdir_coefratio = log_niw_coefratio - 3; % + log_dir_coefratio;
