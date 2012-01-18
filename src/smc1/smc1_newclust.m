
function state = smc1_newclust(state, params, x, t)

% add a new cluster to the state at time t, with mvn-mean=x, and the other cluster params sampled from the prior




K = size(state{2}, 2)+1;


% add new column to state{2} cell

state{2}{t,K}{1} = x(1:2);

state{2}{t,K}{2} = iwishrnd(params{4}, params{5});

state{2}{t,K}{3} = (x(3:end-1)+1) / sum((x(3:end-1)+1));
% state{2}{t,K}{3} = dirrnd(params{8}, 1);
% state{2}{t,K}{3} = (x(3:end-1) / sum(x(3:end-1)));

	% is this really better than sampling from prior?:
	% state{2}{t,K}{3} = dirrnd(params{8}, 1);
	% or from posterior given x
	% params_post = update_mvnmn_params(data_k(:,1:end-1), params);
	% state{2}{t,K}{3} = dirrnd(params_post{8}, 1);


% add new column to state{3} matrix and set sizes = 0;

state{3}(:,end+1) = 0;