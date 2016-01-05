function [data,data_orig,saveParams] = extraction_new(video,thresh)
% This function performs a specific motion/color data
%   extraction ("hsv322 extraction"), which was used 
%   for benchmark datasets (such as pets2009full).
%   Eg: data = extraction_new(videoCell,0.5);

    addpath('~/proj/ddpTracking/src/viz');

    startframe = 1;
    endframe = length(video);
    L = 5;
    data = []; bincomb = {}; bw = {};

    figure,
    for f = startframe:endframe-1
        bw{end+1} = im2bw(video{f},thresh);
        bincomb{end+1} = [];
        imshow(bw{end}); %drawnow; pause;
    end

    % make data points
    for i = 1:length(bw)
        for p = 1:size(bw{i}, 1)
            for q = 1:size(bw{i}, 2)
                if bw{i}(p,q)==1
                    colorhist = zeros(1,L);  %%%% this assumes we are using only 1 slice
                    % colorhist(bincomb{i}(p, q)) = colorhist(bincomb{i}(p, q)) + 1;   %%%%% this assumes we only want to color count the pixel itself (no neighbors, ie L=0)
                    data(end+1,:) = [p,q,colorhist,i];
                end
            end
        end
        fprintf('Completed frame %d.\n',i);
    end

    % normalize spatial data
    data_orig = data;
    scalesize = 10;
        % maxd1 = max(data(:, 1));
        % maxd2 = max(data(:, 2));
    maxd1 = size(bw{1},1);
    maxd2 = size(bw{1},2);
    data(:,1) = (data(:,1)/maxd1)*scalesize;
    data(:,2) = (data(:,2)/maxd2)*scalesize;
    % center data
    newScaleMeanX = mean(data(:,1));
    newScaleMeanY = mean(data(:,2));
    data(:,1) = data(:,1)-newScaleMeanX;
    data(:,2) = data(:,2)-newScaleMeanY;
    saveParams = [thresh,L,startframe,endframe,scalesize,maxd1,maxd2,newScaleMeanX,newScaleMeanY];

    % viz
    viz_result(data(:,[1,2,end]));
