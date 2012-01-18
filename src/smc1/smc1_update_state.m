
function state = smc1_update_state(state, data, s_choice, t)

% add s_choice = {assig_samples, cluster_param_samples, size_samples}





% update assignments

state{1} = [state{1}, s_choice{1}];


% update cluster params

state{2}(t, 1:size(s_choice{2}, 2)) = s_choice{2};


% update sizes

ind_t = find(data(:,end)==t);

state{3}(ind_t(1):ind_t(end)+1, 1:size(s_choice{3}, 2))  =  s_choice{3};

after_t_to_end = ind_t(end)+1:size(state{3}, 1);

state{3}(after_t_to_end, :) = repmat(state{3}(ind_t(end)+1, :), [length(after_t_to_end), 1]);