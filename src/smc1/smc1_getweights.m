
function s_weights = smc1_getweights(state, data, params, t, s_samples)

% provide a weight for each sample in s_samples




ind_t = find(data(:,end)==t);

data_t = data(ind_t, :);



for s = 1 : length(s_samples)

	s_sample = s_samples{s};

	for i = 1 : size(data_t, 1)

		x = data_t(i,:);

		obs_prob_vec(i) = my_log_mvnpdf(x(1:2), s_sample{2}{s_sample{1}(i)}{1}, s_sample{2}{s_sample{1}(i)}{2}) + my_log_mnpdf(x(3:end-1), sum(x(3:end-1)), s_sample{2}{s_sample{1}(i)}{3});

		%sizes = s_sample{3}(ind_t(1)-1+i, :);
		sizes = s_sample{3}(i, :);

		assig_prob_vec(i) = log(sizes(s_sample{1}(i)) / sum(sizes));

	end

	obs_prob = sum(obs_prob_vec);

	assig_prob = sum(assig_prob_vec);

	% del_prob = log

	if t > 1

		for k = 1 : size(s_sample{2}, 2)

			if k <= size(state{2}, 2)

				% theta_prob = ;

				size_prob_vec(k) = abs(s_sample{3}(end, k) - state{3}(ind_t(1) - 1, k));

			else

				% theta_prob = ;

				size_prob_vec(k) = 1;

			end

		end

		size_prob = 1 ;%/ sum(size_prob_vec);

	else

		size_prob = 1;

	end

	

	sample_prob(s) = obs_prob + assig_prob + 100*size_prob; % + del_prob + theta_prob;

end

% get ??[prob of assig given: cluster-size, cluster params, and obs]??  <-- include


% are the following justified at all?

s_weights = exp(sample_prob / sum(sample_prob));

s_weights = s_weights / sum(s_weights);


