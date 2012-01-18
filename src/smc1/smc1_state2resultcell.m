
function resultcell = smc1_state2resultcell(state, data, conf)

% create resultcell, a cell of length (# of objects algo found), each containing a matrix of rows: startframe, endframe, rect






resultcell = {};


% only keep data up until final time-step of inference

ind_final_t = find(data(:,end) == size(state{2},1));

data = data(1:ind_final_t(end), :);


for k = 1 : size(state{2}, 2)

	ind = find(state{3}(:,k));

	if length(ind) > 0

		if max(ind) > size(data, 1), maxxy = size(data,1);, else, maxxy = max(ind);, end

		bd_t(k, 1:2) = [data(min(ind), end), data(maxxy, end)];

	end



	if bd_t(k, 1) > 0

		next_index = length(resultcell) + 1;

		startframe = bd_t(k,1);

		endframe = bd_t(k,2);

		for t = 1 : endframe-startframe+1

			if nargin < 2

				covpoints = get_cov_points2(state{2}{startframe+t-1,k}{2}, state{2}{startframe+t-1,k}{1}, 'conf', 0.7);

				%covpoints = get_rect_points(s_th{startframe+t-1,k}{2}, s_th{startframe+t-1,k}{1}, 'conf', 0.2);

			else

				covpoints = get_cov_points2(state{2}{startframe+t-1,k}{2}, state{2}{startframe+t-1,k}{1}, 'conf', conf);

			end	

			xmax = max(covpoints(:,1))-0.32;
			xmin = min(covpoints(:,1))-0.32;
			ymax = max(covpoints(:,2))-0.35;  % why is shift necessary for pets2009full??
			ymin = min(covpoints(:,2))-0.35;

			resultcell{next_index}(t, 1:6) = [startframe, endframe, xmin, ymin, (xmax-xmin+1)*0.9, (ymax-ymin+1)*0.9];

		end
	
	end

end