
function result = my_log_normpdf(x, mu, lam)





term1 = log(sqrt(lam));

term2 = log(sqrt(2 * pi));

term3 = (1/2) * lam * ((x - mu)^2);



result = term1 - term2 - term3;