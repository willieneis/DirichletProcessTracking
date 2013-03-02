function data = rarefy_data(data,sizegoal)
% Subsamples data to sizegoal

    if size(data, 1) < sizegoal
        disp('Data is already smaller than desired size!');
    else
        perm = randperm(size(data, 1));
        toremove = perm(1:(size(data,1)-sizegoal));
        data([toremove], :) = [];
    end
