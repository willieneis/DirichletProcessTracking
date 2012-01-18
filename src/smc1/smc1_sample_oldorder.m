
function state = smc1_sample(state, data, params, t, delstep)

% sample each assignment, each alive cluster, perform deletion step, update size matrix





% data_t holds observations at current time t

ind_t = find(data(:,end)==t);

data_t = data(ind_t, :);


% final_obs is index of 'most recent' observation (from either current or a previous time)

if size(ind_t, 1) > 0

	final_obs = ind_t(end);

else   %%%%% still need to handle case where t-1 also has 0 obs!

	ind_t_minus_1 = find(data(:,end)==t-1);

	final_obs = ind_t_minus_1(end);

end


% K_init contains number of clusters before a sample is taken

K_init = size(state{2}, 2);

K = K_init;


% allows for easier coding: let state_t = state_t-1 at the start (ie for first sample of a time-step t, for t > 1)

if t > 1  &&  size(state{2}, 1) < t

	state{2}(t, :) = state{2}(t-1, :);    %%%%% do i ever use this in code?  -->yes? when doing assignments for first sample of a time-step?

	state{3}(t, :) = state{3}(t-1, :);

end


% sample assignment for each data_t obs and put into state{1}

for i = 1 : size(data_t,1)

	% specify old assignment, if it exists

	if size(state{1},2) >= ind_t(1)-1+i

		old_k = state{1}(ind_t(1)-1+i);

	else

		old_k = -1;

	end

	% find prob of assignment given clustersizes and alpha

	if size(state{3}, 2) > 0

		sizes = state{3}(ind_t(1)-1+i,:);

	else

		sizes = [];

	end

	sizes(K+1) = params{1};

	prob_assig = sizes / sum(sizes);

	% find prob of observation given cluster parameters

	x = data_t(i, :);

	for k = 1 : K

		if sizes(k) > 0

			prob_obs(k) = my_log_mvnpdf(x(1:2), state{2}{t,k}{1}, state{2}{t,k}{2}) + my_log_mnpdf(x(3:end-1), sum(x(3:end-1)), state{2}{t,k}{3});

		else

			prob_obs(k) = -inf;

		end

	end

	predictive_marginal = my_log_niwdir_coefratio(x, params);
	% predictive_marginal = my_log_niwdir_coefratio2test(data_t(:,1:end-1), params, x(1:end-1));

	prob_obs(K+1) = predictive_marginal;

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

		state = smc1_newclust(state, params, x, t);

	end

	% update sizes ie state{3}

	if old_k ~= -1

		state{3}(ind_t(1)-1+i:end, old_k) = state{3}(ind_t(1)-1+i:end, old_k) - 1;

	end

	state{3}(ind_t(1)-1+i:end, sample_k) = state{3}(ind_t(1)-1+i:end, sample_k) + 1;

end

if size(ind_t, 1) > 0

	s_sample{1} = state{1}(ind_t(1):ind_t(end));

else
	
	s_sample{1} = [];

end




% sample new cluster-params for each alive k (and put into s_sample{2}) [this includes new clusters, as K<-K+1 above]

for k = 1 : K

	if state{3}(final_obs, k) > 0

		data_k = data_t(find(s_sample{1} == k), :);

		if length(data_k) > 0
			
			if k > K_init  ||  t == 1

				% get updated cluster params via posterior (given data only)

				params_post = update_mvnmn_params(data_k(:,1:end-1), params);

			else

				% get updated cluster params via posterior (given data and aux vars)

				% aux_vars = [mvnrnd(state{2}{t-1,k}{1}, state{2}{t-1,k}{2}, params{3}),  mnrnd(params{11}, state{2}{t-1,k}{3}, params{3})];
				aux_mvn = mvnrnd(state{2}{t-1,k}{1}, state{2}{t-1,k}{2}, params{3});
				aux_mn = mnrnd(params{11}, state{2}{t-1,k}{3}, params{3}+150);

				% params_post = update_mvnmn_params([aux_vars; data_k(:, 1:end-1)], params);
				params_post = update_mvnmn_params2([aux_mvn; data_k(:, 1:2)], [aux_mn; data_k(:, 3:end-1)], params);

			end

		else

			% get updated cluster params via transition kernel (aux vars only)
			
			% aux_vars = [mvnrnd(state{2}{t-1,k}{1}, state{2}{t-1,k}{2}, params{3}),  mnrnd(params{11}, state{2}{t-1,k}{3}, params{3})];
			aux_mvn = mvnrnd(state{2}{t-1,k}{1}, state{2}{t-1,k}{2}, params{3});
			aux_mn = mnrnd(params{11}, state{2}{t-1,k}{3}, params{3}+150);

			% params_post = update_mvnmn_params(aux_vars, params);
			params_post = update_mvnmn_params2(aux_mvn, aux_mn, params);

		end

		% sample cluster params

		% params_post{4} = params_post{4} + (0.01 * eye(2));

		state{2}{t,k}{2} = iwishrnd(params_post{4}, params_post{5});

		state{2}{t,k}{1} = mvnrnd(params_post{6}, state{2}{t,k}{2}/params_post{7});

		state{2}{t,k}{3} = dirrnd(params_post{8}, 1);

		% note: this just leaves empty spots in kth s_sample{2} cell, where kth cluster size (after the final obs of t) is 0. is this ok?

		% for sampling reasons, add new cluster as cluster params for previous time step
		if k > K_init  &&  t ~= 1

			state{2}{t-1,k}{1} = state{2}{t,k}{1};
			state{2}{t-1,k}{2} = state{2}{t,k}{2};
			state{2}{t-1,k}{3} = state{2}{t,k}{3};

		end

	end

end




% if final arg == 'delstep', perform deletion for the obs in each alive cluster (and update s_sample{3} a final time)

if nargin >= 5

	if strcmp(delstep, 'delstep')

		for k = 1 : K

			if state{3}(final_obs, k) > 0

				unifrand = rand(1, state{3}(final_obs, k));

				numdead = length(find(unifrand < params{2}));

				state{3}(final_obs+1:end, k) = state{3}(final_obs+1:end, k) - numdead;

			end

		end

	end

end

