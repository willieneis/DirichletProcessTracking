
function state = smc1_infer(state, data, params, numsamples, dirstring)

% inference for a 1-particle particle filter (sequential monte carlo)



tic

t_start = size(state{2}, 1)+1;

t_end = max(data(:, end));

for t = t_start : t_end

	for s = 1 : numsamples

		if s < numsamples

			state = smc1_sample(state, data, params, t, s);

		else

			state = smc1_sample(state, data, params, t, s, 'delstep');

		end

		close
		viz_smc1_result(data(1:size(state{1},2), [1,2,end]), state, 'fil', 'stddev')
		% view(360*s/25, 10)
		view(45, 25)
		zlim([1, t_end])
		drawnow

		disp('t:'); disp(t); disp('sample#:'); disp(s);

	end

	state = clean_state(state);

	% save workspace periodically

	if mod(t-t_start+1, 5)==0, save([dirstring, 'most_recent_infer_ws.mat']);, end

	disp([int2str(t), ' complete']);

end

toc