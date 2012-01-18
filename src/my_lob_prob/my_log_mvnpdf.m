
function prob = my_log_mvnpdf(x, m, sig)





t1 = (-1/2) * (x-m) * inv(sig) * (x-m)';

t2 = (1/2) * log(det(sig));

d = length(x);

t3 = (d/2) * log(2*pi);


prob = t1 - t2 - t3;