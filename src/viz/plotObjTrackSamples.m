function plotObjTrackSamples(wsDirString,dataExtractWsString)
%function plotObjParamSamples(wsDirString,t)
% takes wsDir containing workspaces, each with a sample (stored in state)
% and plots all object spatial parameter samples at time t.

    load(dataExtractWsString,'saveParams');
    statecell = getStateCell(wsDirString);
    dataCell = getDataCell(wsDirString);
    trackCell = getTrackCell(statecell);
    plotTrackSamples()
    set(gca,'YDir','reverse'); box;
    %xlim([0,320]); ylim([0,220]); % only for ants video

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

    function dc = getDataCell(dirstring)
        files = dir(dirstring);
        dc = {};
        for k = 3:length(files) % first two files are . & ..
            if length(strfind(files(k).name,'DS_Store'))==0
                load([dirstring, '/', files(k).name],'data');
                dc{end+1} = data;
            end
        end
    end

    function tc = getTrackCell(sc)
        tc = {};
        for i=1:length(sc) 
            for k=1:size(sc{i}{2},2)
                onInd = find(sc{i}{3}(:,k));
                startT = dataCell{i}(onInd(1),end);
                endT = dataCell{i}(onInd(end),end);
                aTrack = [];
                for t=startT:endT
                    aTrack(end+1,:) = sc{i}{2}{t,k}{1};
                end
                tc{end+1} = aTrack;
            end
        end
    end

    function plotTrackSamples()
        figure,
        for i=1:length(trackCell)
            track = trackCell{i};
            track = convertUnits(track);
            track_x = track(:,2);
            track_y = track(:,1);
            hold on; plot(track_x,track_y,'-k','LineWidth',2);
        end
    end

    function dataPts = convertUnits(dataPts)
        dataPts(:,1) = dataPts(:,1) + saveParams(8);
        dataPts(:,2) = dataPts(:,2) + saveParams(9);
        dataPts(:,1) = (dataPts(:,1)/saveParams(5))*saveParams(6);
        dataPts(:,2) = (dataPts(:,2)/saveParams(5))*saveParams(7);
    end


end
