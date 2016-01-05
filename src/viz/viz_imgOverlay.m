function viz_imgOverlay(imgsDirString,resultsWsString,dataExtractWsString)
% This function shows images with state-ovals overlaid.
    
    addpath('~/proj/ddpTracking/src/extract');
    videocell = imgfolder2videocell(imgsDirString);
    load(resultsWsString,'state','data');
    load(dataExtractWsString,'saveParams');
    bdmat = getBirthDeathsFromSizes();
    for t=1:length(videocell)
        overlaySingleImage()
        drawTracks();
        drawnow(); pause();
    end

    function overlaySingleImage()
        imshow(videocell{t})
        for k=1:size(state{2},2)
            if t>=bdmat(k,1) & t<=bdmat(k,2) % if cluster is alive
                meantoplot = state{2}{t,k}{1};
                covpoints = get_cov_points2(state{2}{t,k}{2},meantoplot,'conf',0.9);
                covpoints = convertUnits(covpoints);
                ovalpoints_x = covpoints(:,2);
                ovalpoints_y = covpoints(:,1);
                hold on; plot(ovalpoints_x,ovalpoints_y,'-w','LineWidth',2);
            end
        end
    end

    function drawTracks()
        for k=1:size(state{2},2)
            if t>=bdmat(k,1) & t<=bdmat(k,2) % only plot clusters alive at t
                track = [];
                for time=1:size(state{2},1)
                    if iscell(state{2}{time,k}) % track only exists when cluster is alive
                        track(end+1,:) = state{2}{time,k}{1}; % doesn't save when tracks start/stop
                    end
                end
                track = convertUnits(track); 
                trackpoints_x = track(:,2);
                trackpoints_y = track(:,1);
                hold on; plot(trackpoints_x,trackpoints_y,'-w','LineWidth',2);
            end
        end
    end

    function dataPts = convertUnits(dataPts)
        dataPts(:,1) = dataPts(:,1) + saveParams(8);
        dataPts(:,2) = dataPts(:,2) + saveParams(9);
        dataPts(:,1) = (dataPts(:,1)/saveParams(5))*saveParams(6);
        dataPts(:,2) = (dataPts(:,2)/saveParams(5))*saveParams(7);
    end

    function birthDeathMat = getBirthDeathsFromSizes()
        for k=1:size(state{3},2)
            aliveind = find(state{3}(:,k));
            birthDeathMat(k,1:2) = [data(aliveind(1),end),data(aliveind(end),end)];
        end
    end

end
