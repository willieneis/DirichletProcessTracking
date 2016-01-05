% process images and make data matrix
function makeData()
    load dots
    cmat = threshCmat(DOTS,0.5);
    data = [];
    for t=1:length(cmat)
        mat = cmat{t};
        mat(:,end+1:end+5) = 0;
        mat(:,end+1) = t; 
        data = [data; mat];
    end
    scalesize = 10;
    maxd1 = max(data(:,1));
    maxd2 = max(data(:,2));
    data(:,1) = (data(:,1)/maxd1)*scalesize;
    data(:,2) = (data(:,2)/maxd2)*scalesize;
    % center data
    newScaleMeanX = mean(data(:,1));
    newScaleMeanY = mean(data(:,2));
    data(:,1) = data(:,1)-newScaleMeanX;
    data(:,2) = data(:,2)-newScaleMeanY;
    save('data.mat');
    fprintf('Data matrix constructed. Saved as data.mat.\n');
end
