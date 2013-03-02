
function viz_result(data, s_c, s_th, fill, stddev, nodata)



% unpack state

% [s_c, s_th, s_aux, s_d, clustersizes, birthdeath] = state{1:6};



if nargin < 6
	
	if nargin > 1
		
		if nargin > 3
			
			if strcmp(fill, 'fill')
				
				figure, plot3k(data, s_c(1, :), [], {'o',5});
				
			else
				
				figure, plot3k_2(data, s_c(1, :), [], {'o',5});

				% figure, viz_plot3_colorspec(s_c, s_th, data);
				
			end
			
		else
			
			figure, plot3k_2(data, s_c(1, :), [], {'o',5});
			
		end
	
	else
		
		figure, plot3k(data, data(:,2)+data(:,1), [], {'o',5});
		
	end
	
else
	
	figure,
	
end





axis vis3d

hold on







% specify deletion times

if nargin > 1
	
	birthdeath = evalin('caller', 'state{7}');
	
end



% plot mean parameters

if nargin > 2
	
	for j = 1 : size(s_th, 2)
		
		holder = [];
		
		for i = 1 : size(s_th, 1)
			
			if  i >= birthdeath(j, 1) &&  i <= birthdeath(j, 2)
				
				holder = [holder; s_th{i, j}{1}, i];
				
			end
			
		end
		
		if length(holder) > 0
			
			plot3(holder(:,1), holder(:,2), holder(:, 3), 'Color', 'k', 'Linewidth', 3);	
			
		end
		
		hold on
		
	end
	
end


% plot covariance points

if nargin > 4
	
	if strcmp(stddev, 'stddev')
		
		for j = 1 : size(s_th, 2)
			
			holder = [];
			
			for i = 1 : size(s_th, 1)
				
				if i >= birthdeath(j, 1) &&  i <= birthdeath(j, 2)
					
					meantoplot = s_th{i, j}{1};

					covpoints = get_cov_points2(s_th{i, j}{2}, meantoplot, 'conf', 0.4);

					%covpoints = get_rect_points(s_th{i, j}{2}, meantoplot, 'conf', 0.2);
					
					stddevtoplot = covpoints;

					holder = [holder; stddevtoplot, repmat(i, [size(covpoints, 1), 1])];
					
				end
				
			end
			
			if size(holder, 1) > 0
				
				% plot3(holder(:,1), holder(:,2), holder(:, 3), '-', 'Color', [0.25, 0.25, 0.25], 'Linewidth', 1, 'Markersize', 5);
				
				plot3(holder(:,1), holder(:,2), holder(:, 3), '-', 'Color', [0, 0, 0], 'Linewidth', 1, 'Markersize', 5);
				
			end
			
			hold on
			
		end
		
	end
	
end







xlim([-5, 5]);

ylim([-5, 5]);

axis square





%