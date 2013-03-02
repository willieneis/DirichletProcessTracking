function numObjVec = plotNumObjectsDistro(wsDirString,tStart,tEnd,varargin)
% takes wsDir containing workspaces, each with a sample (stored in state)
% and plots a histogram over number of objects. If no t is given, plot 
% for all objects in video, if a t is given only plot for frame t

    statecell = getStateCell(wsDirString);
    if nargin==1
        numObjVec = getNumObjVec(statecell);
    elseif nargin==2
        tEnd = tStart;
        ind_t = getIndT(wsDirString);
        numObjVec = getNumObjVec_t(statecell);
    elseif nargin==3
        ind_t = getIndT(wsDirString);
        numObjVec = getNumObjVec_t(statecell);
    end
    %figure,hist(numObjVec);
    [hist_n,xout] = hist(numObjVec,17); % 17 good for T cel experiment
    figure,
    bar(xout,hist_n)
    disp(length(xout))


    % Aux functions
    % -------------

    function sc = getStateCell(dirstring)
        % load each ws, save the state in st, and return
        files = dir(dirstring);
        sc = {};
        for k = 3:length(files) % first two files are . & ..
            if length(strfind(files(k).name,'DS_Store'))==0
                load([dirstring, '/', files(k).name],'state');
                sc{end+1} = state; 
            end
        end
    end

    function nov = getNumObjVec(sc)
        nov = []; 
        for i=1:length(sc)
            nov(end+1) = length(find(sum(sc{i}{3},1)));
        end
    end

    function indmat = getIndT(dirstring)
        % load each ws, save the state in st, and return
        files = dir(dirstring);
        indmat = [];
        for k = 3:length(files) % first two files are . & ..
            if length(strfind(files(k).name,'DS_Store'))==0
                load([dirstring, '/', files(k).name],'data');
                data_t_ind_s = find(data(:,end)==tStart);
                data_t_ind_e = find(data(:,end)==tEnd);
                indmat(end+1,:) = [data_t_ind_s(1),data_t_ind_e(end)];
            end
        end
    end

    function nov = getNumObjVec_t(sc)
        nov = []; 
        for i=1:length(sc)
            nov(end+1) = length(find(sum(sc{i}{3}(ind_t(i,1):ind_t(i,2),:),1)));
        end
    end

end
