
function result = my_log_gampdf(x, a, b)


% pdf of gamma dist:

%	b^a *
% 	( 1 / gamma(a) )  *
%	x ^ (a-1)
%	e ^ (-b*x)    [exp(-b*x)]



term1 = a * log(b);

term2 = 0;
for i = floor(a+0.001-1) : -1 : 1
	term2 = term2 + log(i);
end

term3 = (a-1) * log(x);

term4 = (-b*x);


result = term1 - term2 + term3 + term4;