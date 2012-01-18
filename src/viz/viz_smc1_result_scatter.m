
function viz_smc1_result_scatter(data, state, fill, stddev, nodata)

% scatter version of the main 3D viz for result; this is for the smc1 scheme
	% this function does not create new figure window
	% we assume data is N x 3, with the three columns being: x-pos, y-pos, and temp





% plotting observations:
% ----------------------

markertype = ['+', '.', 'o', 'x', '*', 'x', 's', '^', '>', 'h'];
% markertype = ['+', 'o', 'x', '.', '*', 'x', 's', '^', '>', 'h'];  % use in synth4

numclust = max(state{1});

ind = {};
for i = 1 : numclust
	temp = find(state{1} == i);
	if length(temp > 0)
		ind{end+1} = temp;
	end
end

% colormap(0.7*fliplr(Winter));     % use in synth1 for better color constrast btw clusters
colormap(jet);
for i = 1 : size(ind, 2)
	color_rand = [rand, rand, rand];
	hold on
	% scatter3(data(ind{i},1), data(ind{i},2), data(ind{i},3), 50, i*ones(1, length(data(ind{i},1))), markertype(mod(i, length(markertype)) + 1) ); % choose this for plots to save (fixed color)

	%scatter3(data(ind{i},1), data(ind{i},2), data(ind{i},3), 50, markertype(mod(i, length(markertype)) + 1), 'MarkerEdgeColor', color_rand ); % choose this for plots to save (random color)

	plot3(data(ind{i},1), data(ind{i},2), data(ind{i},3), markertype(mod(i, length(markertype)) + 1), 'MarkerSize', 5, 'MarkerFaceColor', 'none', 'MarkerEdgeColor', color_rand); % for quicker viewing, but worse for saving plots (random color)
end


% axis and graph settings:
% -----------------------

% view(45, 25)   % "front" view for synth4 and pets2000?
% view(225, 25)  % "front" view for synth1 ?
% view(315, 25)    % "front" view for pets2001?
% view(115, 25) % "front" view for pets2009
view(250, 25) % "back" view for pets2009

axis square
axis vis3d
grid on
box on


% old code for plotting observations:
% ----------------------------------

% if nargin < 5
% 	if nargin > 1
% 		if nargin > 2
% 			if strcmp(fill, 'fill')
% 				% plot solid markers
% 				plot3k(data, state{1}(:), [], {'o',5});
% 			else
% 				% plot open markers
% 				plot3k_2(data, state{1}(:), [], {'o',5});
% 					% figure, viz_plot3_colorspec(state{1}, state{2}, data);
% 			end
% 		else
% 			% default, no fill specified, is open markers
% 			plot3k_2(data, state{1}(:), [], {'o',5});
% 		end
% 	else
% 		% to only plot the data
% 		plot3k(data, data(:,2)+data(:,1), [], {'o',5});
% 	end
% else
% 	% figure,
% end
% axis vis3d
% hold on


% specify birth/death times (into bd_t matrix) of clusters (note that this function is for smc1):
% ----------------------------------------------------------------------------------------------

for k = 1 : size(state{2}, 2)

	ind = find(state{3}(:,k));

	if length(ind) > 0

		if max(ind) > size(data, 1), maxxy = size(data,1);, else, maxxy = max(ind);, end

		bd_t(k, 1:2) = [data(min(ind), end), data(maxxy, end)];

	end

end

bd_t


% plotting mean parameters:
% ------------------------

start_t = data(1, end);

end_t = data(end, end);

if nargin > 1
	
	for j = 1 : size(state{2}, 2)
		
		holder = [];
		
		for i = 1 : size(state{2}, 1)
			
			if size(bd_t, 1) >= j

				if  i+data(1,end)-1 >= bd_t(j, 1) &&  i+data(1,end)-1 <= bd_t(j, 2)  &&  length(state{2}{i,j}) > 0 %%%%
					
					holder = [holder; state{2}{i, j}{1}, i+data(1,end)-1];
					
				end

			end
			
		end
		
		if length(holder) > 0
			
			plot3(holder(:,1), holder(:,2), holder(:, 3), 'Color', 'k', 'Linewidth', 3);	
			
		end
		
		hold on
		
	end
	
end


% plotting covariance points:
% ---------------------------

if nargin > 3
	
	if strcmp(stddev, 'stddev')
		
		for j = 1 : size(state{2}, 2)
			
			holder = [];
			
			for i = 1 : size(state{2}, 1)

				if size(bd_t, 1) >= j
				
					if i+data(1,end)-1 >= bd_t(j, 1) &&  i+data(1,end)-1 <= bd_t(j, 2)  &&  length(state{2}{i,j}) > 0 %%%%
						
						meantoplot = state{2}{i, j}{1};

						covpoints = get_cov_points2(state{2}{i, j}{2}, meantoplot, 'conf', 0.5);

						%covpoints = get_rect_points(state{2}{i, j}{2}, meantoplot, 'conf', 0.7); % for showing result of conversion to bounding box
						
						stddevtoplot = covpoints;

						holder = [holder; stddevtoplot, repmat(i+data(1,end)-1, [size(covpoints, 1), 1])];
						
					end

				end
				
			end
			
			if size(holder, 1) > 0
				
				plot3(holder(:,1), holder(:,2), holder(:, 3), '-', 'Color', [0, 0, 0], 'Linewidth', 1, 'Markersize', 5);
				
			end
			
			hold on
			
		end
		
	end
	
end