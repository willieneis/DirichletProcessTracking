
function logprob = smc1_joint_log_prob(state, data, params)


% calculate the joint log-probability of the model
% for smc1



% [s_c, s_th, s_aux, s_d, clustersizes, birthdeath, birthdeath_time] = state{1:7};

N = length(s_c);

T = size(s_th, 1);

K = size(s_th, 2);

M = params{3};

numbins = length(data(1, 3:end-1));

clustersizes(:, end+1) = params{1};



for k = 1 : K
	
	for t = 2 : T

		params_M = update_mvn_params(s_aux{t-1, k}{1}, params);
		
		params_M = update_mn_params(s_aux{t-1, k}{2}, params_M);

		th_probs(t, k) = my_log_mvnpdf(s_th{t,k}{1}, params_M{6}, s_th{t,k}{2}/params_M{7}) + my_log_iwishpdf(s_th{t,k}{2}, params_M{4}, params_M{5}) + my_log_dirpdf(s_th{t,k}{3}, params_M{8});

		for m = 1 : M

			auxvar_mvn = s_aux{t, k}{1}(m);

			auxvar_mn = s_aux{t, k}{2}(m, :);

			aux_probs(t, k, m) = my_log_mvnpdf(auxvar_mvn, s_th{t,k}{1}, s_th{t,k}{2}) + my_log_mnpdf(auxvar_mn, numbins, s_th{t,k}{3});

			% aux_probs(t, k, m) = my_log_mnpdf(auxvar_mn, numbins, s_th{t,k}{3});

		end

	end

end



for i = 1 : N

	d_probs(i) = my_log_geopdf(s_d(i)-1-i, params{2});

	c_probs(i) = clustersizes(i, s_c(i)) / sum(clustersizes(i,:));

	x = data(i, :);

	t = data(i, end);

	x_probs(i) = my_log_mvnpdf(x(1:2), s_th{t,s_c(i)}{1}, s_th{t,s_c(i)}{2}) + my_log_mnpdf(x(3:end-1), sum(x(3:end-1)), s_th{t,s_c(i)}{3});

end


logprob = sum(th_probs(:)) + sum(aux_probs(:)) + sum(d_probs) + sum(c_probs) + sum(x_probs);




disp(sum(th_probs(:)));
disp(sum(aux_probs(:)));
disp(sum(d_probs));
disp(sum(c_probs));
disp(sum(x_probs));



