function plotSingleObjectTracks(resultWsString,dataExtractWsString)
% for each object, plot inferred covariance ovals (centered at zero)

    load(resultWsString,'state');
    load(dataExtractWsString,'saveParams');
    for k=1:size(state{2},2)
        track = [];
        for t=1:size(state{2},1)
            if length(state{2}{t,k})>0
                centroid = state{2}{t,k}{1};
                centroid = convertUnits(centroid);
                track(end+1,:) = [centroid(2),centroid(1)];
            end
        end
        figure, plot(track(:,1),track(:,2),'-k','LineWidth',2);
        xlim([20,280]); ylim([20,280]); % for synthetic video
        axis equal; box;
    end

    % Aux functions
    % -------------

    function dataPts = convertUnits(dataPts)
        dataPts(:,1) = dataPts(:,1) + saveParams(8);
        dataPts(:,2) = dataPts(:,2) + saveParams(9);
        dataPts(:,1) = (dataPts(:,1)/saveParams(5))*saveParams(6);
        dataPts(:,2) = (dataPts(:,2)/saveParams(5))*saveParams(7);
    end

end
