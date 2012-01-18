
function [state, data] = smc1_chop_state_and_data(state, start_t, end_t, data)

% converts state to a state going form start_t to end_t (inclusive of these endpoints)





% specify birth/death times of clusters (into bd_t matrix):
% ---------------------------------------------------------

% do I actually need or use bd_t anywhere in here?

% for k = 1 : size(state{2}, 2)

% 	ind = find(state{3}(:,k));

% 	if length(ind) > 0

% 		if max(ind) > size(data, 1), maxxy = size(data,1);, else, maxxy = max(ind);, end

% 		bd_t(k, 1:2) = [data(min(ind), end), data(maxxy, end)];

% 	end

% end


% remove all parts of clusters outside specified time range:
% ---------------------------------------------------------

start_ind_vec = find(data(:, end) == start_t);

end_ind_vec = find(data(:, end) == end_t);

start_ind = start_ind_vec(1);

end_ind = end_ind_vec(end);

% chop assignments
state{1} = state{1}(start_ind:end_ind);

% chop cluster parameters
state{2} = state{2}(start_t:end_t, :);

% chop sizes
state{3} = state{3}(start_ind:end_ind, :);
	% not sure if this is the best way, but it seems to work...


% clean state to remove the (now) empty clusters
% ----------------------------------------------

state = clean_state(state);


% make data only the desired range
% --------------------------------

data = data(start_ind:end_ind, :);
