function [ cmat ] = threshCmat( blackdots, quantile )
    T = size(blackdots, 3);
    cmat = cell(T, 1);
    for t = 1:T
        maxVal = max(max(blackdots(:,:,t)));
        [x y] = find(blackdots(:,:,t) > quantile);
        %[x y] = find(blackdots(:,:,t) > maxVal*quantile);
        cmat{t} = [x y];
    end
end
