function [detectPoints,img] = detectCells(resultWsString,dataExtractWsString,imgFrameString)
% trains a tcell detector, and performs detection

    load(resultWsString,'state');
    load(dataExtractWsString,'saveParams');
    img = imread(imgFrameString);

    % assume we want results from frame=1
    start_t=1; end_t=1;
    cropRad = 15; numNegPoints = 50; testPtsPerSide = 46; % good settings for tcell experiment

    pos = getPos();
    cropCell = getCropCell();
    negCell = getNegCell();
    [data,group] = makeDataTable;
    SVMstruct = svmtrain(data,group);
    [testPoints,testPositions] = getTestData();
    testGroup = svmclassify(SVMstruct,testPoints);
    detectPoints = testPositions(find(testGroup),:);
    figure,imshow(img);
    hold on; plot(detectPoints(:,1),detectPoints(:,2),'rx','LineWidth',2,'MarkerSize',15);
    
    % Aux functions
    % -------------

    function p = getPos()
        p = [];
        for t=start_t:end_t
            for k=1:size(state{2},2)
                if length(state{2}{t,k})>0
                    p(end+1,:) = state{2}{t,k}{1};
                end
            end
        end
    end

    function cc = getCropCell()
        cc = {};
        for i=1:size(pos,1)
            centroid = pos(i,:); centroid = convertUnits(centroid);
            cropRect = [centroid(2)-cropRad,centroid(1)-cropRad,2*cropRad,2*cropRad];
            newCrop = imcrop(img,cropRect);
            if size(newCrop,1)==2*cropRad+1 && size(newCrop,2)==2*cropRad+1
                cc{end+1} = newCrop;
            else
                disp('Cropped patch was not full sized...discluding');
            end
            %if length(cc)>0, imshow(cc{end}); drawnow; pause(0.2); end
        end
    end
    
    function nc = getNegCell()  
        nc = {};
        for j=1:numNegPoints
            randPosition = [randi(floor(min(size(img)) - (2*cropRad))) + cropRad,...
                randi(floor(min(size(img)) - (2*cropRad))) + cropRad];
            isNeg = checkNearOtherCells(randPosition);
            if isNeg==1
                cropNegRect = [randPosition(1)-cropRad,randPosition(2)-cropRad,2*cropRad,2*cropRad];
                newNegCrop = imcrop(img,cropNegRect); 
                if size(newNegCrop,1)==2*cropRad+1 && size(newNegCrop,2)==2*cropRad+1
                    nc{end+1} = newNegCrop;
                else
                    disp('Cropped (neg) patch was not full sized...discluding');
                end
            else
                disp('Random (neg) position too close to actual cell...discarding.');
            end
            %if length(nc)>0, imshow(nc{end}); drawnow; pause(0.2); end
        end
    end

    function isNegativePt = checkNearOtherCells(randpos)
        isNegativePt = 1;
        normVec = [];
        for i=1:size(pos,1)
            normVec(end+1) = norm(convertUnits(pos(i,:))-randpos);
        end
        minNorm = min(normVec);
        if minNorm<10
            isNegativePt = 0;
        end
    end

    function dataPts = convertUnits(dataPts)
        dataPts(:,1) = dataPts(:,1) + saveParams(8);
        dataPts(:,2) = dataPts(:,2) + saveParams(9);
        dataPts(:,1) = (dataPts(:,1)/saveParams(5))*saveParams(6);
        dataPts(:,2) = (dataPts(:,2)/saveParams(5))*saveParams(7);
    end

    function [d,g] = makeDataTable()
        d = []; g = [];
        for i = 1:length(cropCell)
            d(end+1,:) = cropCell{i}(:);
            g(end+1) = 1;
        end
        for i = 1:length(negCell)
            d(end+1,:) = negCell{i}(:);
            g(end+1) = 0;
        end
    end

    function [tp,cropCentroids] = getTestData()
        tp = [];
        [testCropCell,cropCentroids] = getTestCropCell();
        for i=1:length(testCropCell)
            testPt = testCropCell{i}(:)';
            tp(end+1,:) = testPt;
        end
    end

    function [tcc,cropCent] = getTestCropCell()
        tcc = {}; cropCent = [];
        widthGrid = floor(linspace(1,size(img,2),testPtsPerSide));
        widthGrid([1,end]) = [];
        lengthGrid = floor(linspace(1,size(img,1),testPtsPerSide));
        lengthGrid([1,end]) = [];
        for l = 1:length(lengthGrid)
            for w = 1:length(widthGrid)
                cropTestRect = [lengthGrid(l)-cropRad,widthGrid(w)-cropRad,2*cropRad,2*cropRad];
                newTestCrop = imcrop(img,cropTestRect); 
                if size(newTestCrop,1)==2*cropRad+1 && size(newTestCrop,2)==2*cropRad+1
                    tcc{end+1} = newTestCrop;
                    cropCent(end+1,:) = [lengthGrid(l),widthGrid(w)];
                else
                    disp('Cropped (test) patch was not full sized...discluding');
                end
                %if length(tcc)>0, imshow(tcc{end}); drawnow; pause(0.5); end
            end
        end
    end

end
