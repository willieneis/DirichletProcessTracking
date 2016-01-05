function viz_smc1_result(data, state, fill, stddev, nodata)
% main viz for result, this is for the smc1 scheme

    if nargin < 5
        if nargin > 1
            if nargin > 2
                if strcmp(fill, 'fill')
                    % plot solid markers
                    plot3k(data, state{1}(:), [], {'o',5});
                else
                    % plot open markers
                    plot3k_2(data, state{1}(:), [], {'o',5});
                        % figure, viz_plot3_colorspec(state{1}, state{2}, data);
                end
            else
                % default, no fill specified, is open markers
                plot3k_2(data, state{1}(:), [], {'o',5});
            end
        else
            % only plot the data
            plot3k(data, data(:,2)+data(:,1), [], {'o',5});
        end
    else
        % figure,
    end
    axis vis3d
    hold on

    % specify birth/death times (into bd_t matrix) of clusters
    for k = 1 : size(state{2}, 2)
        ind = find(state{3}(:,k));
        if length(ind) > 0
            if max(ind) > size(data, 1), maxxy = size(data,1);, else, maxxy = max(ind); end
            bd_t(k, 1:2) = [data(min(ind), end), data(maxxy, end)];
        end
    end

    % plot mean parameters
    if nargin > 1
        for j = 1 : size(state{2}, 2)
            holder = [];
            for i = 1 : size(state{2}, 1)
                if size(bd_t, 1) >= j
                    if  i >= bd_t(j, 1) &&  i <= bd_t(j, 2)  &&  length(state{2}{i,j}) > 0
                        holder = [holder; state{2}{i, j}{1}, i];
                    end
                end
            end
            if length(holder) > 0
                plot3(holder(:,1), holder(:,2), holder(:, 3), 'Color', 'k', 'Linewidth', 3);	
            end
            hold on
        end
    end

    % plot covariance points
    if nargin > 3
        if strcmp(stddev, 'stddev')
            for j = 1 : size(state{2}, 2)
                holder = [];
                for i = 1 : size(state{2}, 1)
                    if size(bd_t, 1) >= j
                        if i >= bd_t(j, 1) &&  i <= bd_t(j, 2)  &&  length(state{2}{i,j}) > 0
                            meantoplot = state{2}{i, j}{1};
                            covpoints = get_cov_points2(state{2}{i, j}{2}, meantoplot, 'conf', 0.9);
                            %covpoints = get_rect_points(state{2}{i, j}{2}, meantoplot, 'conf', 0.2);
                            stddevtoplot = covpoints;
                            holder = [holder; stddevtoplot, repmat(i, [size(covpoints, 1), 1])];
                        end
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
