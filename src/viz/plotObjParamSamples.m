function plotObjParamSamples(wsDirString,dataExtractWsString,t)
% takes wsDir containing workspaces, each with a sample (stored in state)
% and plots all object spatial parameter samples at time t.
% Note: a workspace containing a stateCell (such as the "samples" variable
%   in PMCMC workspaces can be entere instead of wsDirString

    load(dataExtractWsString,'saveParams');
    statecell = getStateCell(wsDirString);
    ind_t = getIndT(wsDirString);
    paramCell = getParamCell(statecell);
    plotParamSamples()
    set(gca,'YDir','reverse'); box;
    xlim([0,320]); ylim([0,220]); % only for ants video

    % Aux functions
    % -------------

    function sc = getStateCell(dirstring)
        % load each ws, save the state in st, and return
        if strfind(dirstring,'.mat')
            samplesSc = load(dirstring,'samples');
            sc = samplesSc.samples;
        else
            files = dir(dirstring);
            sc = {};
            for k = 3:length(files) % first two files are . & ..
                if length(strfind(files(k).name,'DS_Store'))==0
                    try
                        load([dirstring, '/', files(k).name],'samples');
                        for j=1:length(samples)
                            sc{end+1} = samples{j}; 
                        end
                    catch
                        load([dirstring, '/', files(k).name],'state');
                        sc{end+1} = state; 
                    end
                end
            end
        end
    end

    function indmat = getIndT(dirstring)
        indmat = [];
        if strfind(dirstring,'.mat')
            dataLoad = load(dirstring,'data');
            data = dataLoad.data;
            data_t_ind = find(data(:,end)==t);
            indmat = repmat([data_t_ind(1),data_t_ind(end)],length(statecell),1);
        else
            files = dir(dirstring);
            for k = 3:length(files) % first two files are . & ..
                if length(strfind(files(k).name,'DS_Store'))==0
                    try
                        load([dirstring, '/', files(k).name],'data');
                        data_t_ind = find(data(:,end)==t);
                        indmat = [indmat; repmat([data_t_ind(1),data_t_ind(end)],length(statecell),1)]; % isn't quite right
                    catch
                        load([dirstring, '/', files(k).name],'data');
                        data_t_ind = find(data(:,end)==t);
                        indmat(end+1,:) = [data_t_ind(1),data_t_ind(end)];
                    end
                end
            end
        end
    end

    function pc = getParamCell(sc)
        meanMat = [];
        covCell = {};
        for i=1:length(sc) 
            for k=1:size(sc{i}{2},2)
                if sum(sc{i}{3}(ind_t(i,1):ind_t(i,2),k))>0
                    meanMat(end+1,:) = sc{i}{2}{t,k}{1};
                    covCell{end+1} = sc{i}{2}{t,k}{2};
                end
            end
        end
        pc = {meanMat,covCell};
    end

    function plotParamSamples()
        meanMat = paramCell{1};
        covCell = paramCell{2};
        figure,
        for i=1:size(meanMat,1)
            covpoints = get_cov_points2(covCell{i},meanMat(i,:),'conf',0.9);
            covpoints = convertUnits(covpoints);
            ovalpoints_x = covpoints(:,2);
            ovalpoints_y = covpoints(:,1);
            centroid = meanMat(i,:);
            centroid = convertUnits(centroid);
            centroid_x = centroid(2);
            centroid_y = centroid(1);
            hold on; plot(ovalpoints_x,ovalpoints_y,'-k','LineWidth',2);
            hold on; plot(centroid_x,centroid_y,'ok','LineWidth',2);
        end
    end

    function dataPts = convertUnits(dataPts)
        dataPts(:,1) = dataPts(:,1) + saveParams(8);
        dataPts(:,2) = dataPts(:,2) + saveParams(9);
        dataPts(:,1) = (dataPts(:,1)/saveParams(5))*saveParams(6);
        dataPts(:,2) = (dataPts(:,2)/saveParams(5))*saveParams(7);
    end


end
