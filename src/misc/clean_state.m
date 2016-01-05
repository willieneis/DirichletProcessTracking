function state = clean_state(state)
% find clusters with no assignments and remove 
% from state{1}, state{2}, and state{3}
    
    currobs = length(state{1});
    sumsizes = sum(state{3}(1:currobs, :), 1);
    counter = 0;
    for k = 1 : length(sumsizes)
        if sumsizes(k) > 0
            counter = counter+1;
            state{1}(find(state{1}==k)) = counter;
            state{2}(:,counter) = state{2}(:,k);
            state{3}(:,counter) = state{3}(:,k);
        end
    end
    state{2}(:, counter+1:end) = [];
    state{3}(:, counter+1:end) = [];
