function plotSingleObjectTracks_multiple(wsDirString,dataExtractWsString)
% for each object, plot inferred covariance ovals (centered at zero)

    load(dataExtractWsString,'saveParams');
    stateCell = getStateCell(wsDirString);
    %for s=1:length(stateCell)
    for s=1:5 % for figure
        st = struct2cell(stateCell{s}); st = st{1}; % not sure why I need to do this
        for k=1:size(st{2},2)
            track = [];
            for t=1:size(st{2},1)
                if length(st{2}{t,k})>0
                    centroid = st{2}{t,k}{1};
                    centroid = convertUnits(centroid);
                    track(end+1,:) = [centroid(2),centroid(1)];
                end
            end
            figure(k), hold on; plot(track(:,1),track(:,2),'-k','LineWidth',2);
            xlim([20,280]); ylim([20,280]); % for synthetic video
            axis equal;
        end
    end

    % Aux functions
    % -------------

    function sc = getStateCell(dirstring)
        % load each ws, save the state in st, and return
        files = dir(dirstring);
        sc = {};
        for k = 3:length(files) % first two files are . & ..
            if length(strfind(files(k).name,'DS_Store'))==0
                state = load([dirstring, '/', files(k).name],'state');
                sc{end+1} = state; 
            end
        end
    end

    function dataPts = convertUnits(dataPts)
        dataPts(:,1) = dataPts(:,1) + saveParams(8);
        dataPts(:,2) = dataPts(:,2) + saveParams(9);
        dataPts(:,1) = (dataPts(:,1)/saveParams(5))*saveParams(6);
        dataPts(:,2) = (dataPts(:,2)/saveParams(5))*saveParams(7);
    end

end
