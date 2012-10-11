
function log_dircoef_ratio = my_log_dircoefratio(x, params)



log_dircoef_ratio = (my_log_dircoef(params{8}) - my_log_dircoef(params{8} + x/sum(x)));