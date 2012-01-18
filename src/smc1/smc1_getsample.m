
function s_sample = smc1_getsample(state, data, params, t)

% sample each assignment, each alive cluster, perform deletion step, update size matrix




ind_t = find(data(:,end)==t);

data_t = data(ind_t, :);

K_init = size(state{2}, 2);

K = K_init;


% sample assignment for each data_t obs (and put into s_sample{1})

for i = 1 : size(data_t,1)

	% find prob of assignment given clustersizes and alpha

	if size(state{3}, 1) > 0

		sizes = state{3}(ind_t(1)-1+i,:);

	else

		sizes = [];

	end

	sizes(end+1) = params{1};

	prob_assig = sizes / sum(sizes);

	% find prob of observation given cluster parameters

	x = data_t(i, :);

	for k = 1 : K

		if sizes(k) > 0

			prob_obs(k) = my_log_mvnpdf(x(1:2), state{2}{t-1,k}{1}, state{2}{t-1,k}{2}) + my_log_mnpdf(x(3:end-1), sum(x(3:end-1)), state{2}{t-1,k}{3});

		else

			prob_obs(k) = -inf;

		end

	end
	
	predictive_marginal_mvn = my_log_mvncoefratio(x(1:2), params);

	predictive_marginal_mn = my_log_dircoefratio(x(3:end-1), params);
		
	prob_obs(K+1) = predictive_marginal_mvn + predictive_marginal_mn;

	% make discrete probability vector from which assignment is sampled

	prob_vec = prob_assig .* exp(prob_obs);

	if sum(prob_vec) > 0

		sample_k = randcat(prob_vec);

	else
	
		[del, sample_k] = max(log(prob_assig) + prob_obs);

		disp('PROBABILITY VECTOR TOO SMALL TO TAKE EXPONENT WITHOUT UNDERFLOW!')

	end
	
	% update state{1}

	state{1}(ind_t(1)-1+i) = sample_k;

	% in case where sample_k is a new cluster

	if sample_k == K+1

		K = K+1;

		state = smc1_newclust(state, params, x t-1);
			% this must add a new cluster parameter to state{2}, and new column to state{3}

	end

	% update sizes in state{3} and s_sample{3}

	state{3}(ind_t(1)-1+i, sample_k) = state{3}(ind_t(1)-1+i, sample_k) + 1;

	% also do?: s_sample{3}{i, sample_k} = s_sample{3}{i, sample_k};
	% or do this at the end

end

s_sample{1} = state{1}(ind_t(1):ind_t(end));




% sample new cluster-params for each alive k (and put into s_sample{2})

for k = 1 : K   % also can do: 1 : size(state{2}, 2)

	if state{3}(ind_t(end), k) > 0

		data_k = data_t(find(s_sample{1} == k), :);

		if length(data_k) > 0
			
			if k > K_init

				% get updated cluster params via posterior (given data only)

				params_post = update_mvnmn_params(data_k(:,1:end-1), params);

			else

				% get updated cluster params via posterior (given data and aux vars)

				aux_vars = [mvnrnd(state{2}{t-1,k}{1}, state{2}{t-1,k}{2}, params{3}), mnrnd(params{11}, state{2}{t-1,k}{3}, params{3})];

				params_post = update_mvnmn_params([aux_vars; data_k(:, 1:end-1)], params);

			end

		else

			% get updated cluster params via transition kernel (aux vars only)
			
			aux_vars = [mvnrnd(state{2}{t-1,k}{1}, state{2}{t-1,k}{2}, params{3}), mnrnd(params{11}, state{2}{t-1,k}{3}, params{3})];

			params_post = update_mvnmn_params(aux_vars, params);

		end

		% sample cluster params

		s_sample{2}{k}{2} = iwishrnd(params_post{4}, params_post{5});

		s_sample{2}{k}{1} = mvnrnd(params_post{6}, s_sample{2}{k}{1}/params_post{7});

		s_sample{2}{k}{3} = dirrnd(params_post{8}, 1);

		% note: this just leaves empty spots in kth s_sample{2} cell, where kth cluster size (after the final obs of t) is 0. is this ok?

	end

end




% perform deletion for the obs in each alive cluster (and update s_sample{3} a final time)

for k = 1 : K   % also can do: 1 : size(state{2}, 2)

	if state{3}(ind_t(end), k) > 0

		unifrand = rand(1, state{3}(ind_t(end), k));

		numdead = length(find(unifrand < params{2}));

		state{3}(ind_t(end)+1, k) = state{3}(ind_t(end)+1, k) - numdead;

	end

end

s_sample{3} = state{3}(ind_t(1):ind_t(end)+1, :);   %%%%% or should i include for ind_t(1):ind_t(end)+1, :)?



