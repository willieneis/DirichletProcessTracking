function plotSingleObjectOvals(resultWsString,dataExtractWsString)
% for each object, plot inferred covariance ovals (centered at zero)

    load(resultWsString,'state');
    load(dataExtractWsString,'saveParams');
    for k=1:size(state{2},2)
        figure, 
        for t=1:size(state{2},1)
            if length(state{2}{t,k})>0
                covpoints = get_cov_points2(state{2}{t,k}{2},[0,0],'conf',0.9);
                covpoints = convertUnits(covpoints);
                ovalpoints_x = covpoints(:,2);
                ovalpoints_y = covpoints(:,1);
                hold on; plot(ovalpoints_x,ovalpoints_y,'-k','LineWidth',2);
            end
        end
        %xlim([80,200]); ylim([70,200]); % for synthetic video
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
