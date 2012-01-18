
function log_niwdir_coefratio = my_log_niwdir_coefratio2test(data, params, x)




params_n = update_mvnmn_params(data, params);


n = size(data, 1);

% for spatial dimensions
d = 2;




x1 = x(1:2);

df = params_n{5} - d + 1;

mu = params_n{6};

sig = sqrt( (params_n{4} * (params_n{7}+1))  /  (params_n{7} * df) );

log_c = my_log_gamma((df/2) + (1/2)) - my_log_gamma(df/2) - my_log_gamma(sqrt(df * pi * sig));

log_inner = log(1 + ((1/df)*(((x1-mu)/sig)*((x1-mu)/sig)')));

log_niw_coefratio = log_c + ((-(df+1)/2)*log_inner);





% compute log niw coef ratio



% compute log dir coef ratio

%log_dir_coefratio = my_log_dircoef(params{8}) - my_log_dircoef(params_n{8} / sum(data(3:end-1)));
log_dir_coefratio = my_log_dircoef(params{8}) - my_log_dircoef(params_n{8});



% compute log niwdir coef ratio

log_niwdir_coefratio = log_niw_coefratio   ; %+ log_dir_coefratio;