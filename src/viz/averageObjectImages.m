function cropCell = averageObjectImages(resultWsString,dataExtractWsString,videocellWsString)
% returns an "average image" (constructed from video images)
% for each object.

    load(videocellWsString,'videocell');
    load(dataExtractWsString,'saveParams');
    load(resultWsString,'state');
    cropCell = getCropCell();
    makeAverageImages(cropCell);

    % Aux functions
    % -------------

    function cc = getCropCell()
        cc  = {};
        for k=1:size(state{2},2)
            cc{k} = {};
            for t=1:size(state{2},1)
                if length(state{2}{t,k})>0 %%%% change to only t where object exists
                    covpoints = get_cov_points2(state{2}{t,k}{2},state{2}{t,k}{1},'conf',0.9);
                    covpoints = convertUnits(covpoints);
                    ovalpts_x = covpoints(:,2); ovalpts_y = covpoints(:,1);
                    %cropRect = [min(ovalpts_x)-10,min(ovalpts_y)-20,max(ovalpts_x)-min(ovalpts_x)+1-10,max(ovalpts_y)-min(ovalpts_y)+1-20];
                    cropRect = [min(ovalpts_x)-10,min(ovalpts_y)-10,max(ovalpts_x)-min(ovalpts_x)+1,max(ovalpts_y)-min(ovalpts_y)+1];
                    cc{k}{end+1} = imcrop(videocell{t+1},cropRect);
                    %imshow(cc{k}{end}); drawnow; pause(0.1);
                end
            end
        end
    end

    function makeAverageImages(cc)
        for k=1:length(cc)
            for t=1:length(cc{k})
                lenVec(t) = length(cc{k}{t});
            end
            background = uint8(255*ones(max(lenVec),max(lenVec),3));
            imsum = double(background);
            counter = 0;
            for t=1:length(cc{k})
                newim = background;
                colorRatio = length(find(cc{k}{t}(:)>245))/length(cc{k}{t}(:));
                if colorRatio<0.6
                    newim(1:size(cc{k}{t},1),1:size(cc{k}{t},2),:) = cc{k}{t};
                    imsum = double(imsum)+double(newim);
                    counter = counter+1;
                end
            end
            imsum = imsum - double(background);
            counter
            figure, imshow(uint8(imsum/counter));
        end
    end

    function dataPts = convertUnits(dataPts)
        dataPts(:,1) = dataPts(:,1) + saveParams(8);
        dataPts(:,2) = dataPts(:,2) + saveParams(9);
        dataPts(:,1) = (dataPts(:,1)/saveParams(5))*saveParams(6);
        dataPts(:,2) = (dataPts(:,2)/saveParams(5))*saveParams(7);
    end

end
