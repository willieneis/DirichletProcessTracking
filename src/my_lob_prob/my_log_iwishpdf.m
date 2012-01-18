
function prob = my_log_iwishpdf(sig, tau, v)





t1 = (v/2) * log(det(tau));

t2 = (-1/2) * trace(tau * inv(sig));

d = size(sig, 1);

t3 = (v*d / 2)*log(2);

t4 = (d*(d-1) / 4) * log(pi);

t5 = ((v+d+1)/2) * log(det(sig));

t6 = 0;

for i = 1 : d
	
	t6 = t6 + log(gamma((v/2) + ((1-i)/2)));    %%%% does it make any difference if order of i and 1 are switched, ie (i-1)
	
end


prob = t1 + t2 - t3 - t4 - t5 - t6;
