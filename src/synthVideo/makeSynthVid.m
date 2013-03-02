function videocell = makeSynthVid()
% This function constructs the synthetic video and returns it in a videocell.

    imgfile = { '~/proj/ddpTracking/data/creativeCommonsImg/cat.jpg',...
                '~/proj/ddpTracking/data/creativeCommonsImg/human.jpg',...
                '~/proj/ddpTracking/data/creativeCommonsImg/kart.jpg',...
                '~/proj/ddpTracking/data/creativeCommonsImg/beetle.jpg'};
    imgscale = [0.25,0.4,0.3,0.25];

    % Read in images
    for i=1:length(imgfile)
        img{i} = imresize(imread(imgfile{i}),imgscale(i));
        mask{i} = im2bw(img{i},0.95);
    end

    % specify scene
    sceneHeight = 800; sceneWidth = 800;
    for i=1:3, blankScene{i} = uint8(255*ones(sceneHeight,sceneWidth)); end

    % specify object tracks (must be integer positions)
    mat1(1:70,1) = 1:70;
    mat1(1:30,2) = floor(720*ones(1,30) + 7*randn(1,30));
    mat1(31:50,2) = floor(linspace(720,600,20) + 7*randn(1,20));
    mat1(51:70,2) = floor(linspace(600,400,20) + 5*randn(1,20));
    mat1(1:30,3) = floor(linspace(780,200,30) + 3*randn(1,30));
    mat1(31:50,3) = floor(linspace(200,400,20) + 3*randn(1,20));
    mat1(51:70,3) = floor(linspace(400,0,20) + 5*randn(1,20));

    mat2(1:70,1) = 1:70;
    mat2(1:20,2) = floor(linspace(300,100,20) + 3*randn(1,20));
    mat2(21:40,2) = floor(linspace(100,150,20) + 8*randn(1,20));
    mat2(41:50,2) = floor(linspace(150,250,10) + 3*randn(1,10));
    mat2(51:70,2) = floor(linspace(250,650,20) + 4*randn(1,20));
    mat2(1:30,3) = floor(linspace(800,600,30) + 5*randn(1,30));
    mat2(31:50,3) = floor(linspace(600,700,20) + 5*randn(1,20));
    mat2(51:70,3) = floor(linspace(700,100,20) + 5*randn(1,20));

    mat3(1:70,1) = 1:70;
    mat3(1:30,2) = floor(linspace(550,300,30) + 1*randn(1,30));
    mat3(31:50,2) = floor(linspace(300,320,20) + 1*randn(1,20));
    mat3(51:70,2) = floor(linspace(320,0,20) + 1*randn(1,20));
    mat3(1:30,3) = floor(linspace(800,500,30) + 1*randn(1,30));
    mat3(31:50,3) = floor(linspace(500,200,20) + 1*randn(1,20));
    mat3(51:70,3) = floor(linspace(200,300,20) + 1*randn(1,20));
    
    mat4(1:70,1) = 1:70;
    mat4(1:30,2) = floor(linspace(0,550,30) + 1*randn(1,30));
    mat4(31:50,2) = floor(linspace(550,570,20) + 1*randn(1,20));
    mat4(51:70,2) = floor(linspace(570,520,20) + 1*randn(1,20));
    mat4(1:30,3) = floor(linspace(40,40,30) + 1*randn(1,30));
    mat4(31:50,3) = floor(linspace(40,650,20) + 1*randn(1,20));
    mat4(51:70,3) = floor(linspace(650,600,20) + 1*randn(1,20));

    trackMats{1} = mat1; 
    trackMats{2} = mat2;
    trackMats{3} = mat3;
    trackMats{4} = mat4;

    % fixed object order throughout video
    objOrder = [2,3,4,1];

    % construct videocell
    startframe = 1; endframe = 70;
    videocell = makeVideoCell(startframe,endframe)

    % Aux functions
    % -------------

    function vc = makeVideoCell(sf,ef)
        vc = {};
        for t = sf:ef 
            posCell = {};
            for k = 1:length(trackMats)
                tInd = find(trackMats{k}(:,1)==t);
                if length(tInd>0)
                    posCell{end+1} = trackMats{k}(tInd,2:3);
                else
                    posCell{end+1} = [];
                end
            end
            nextimg = makeScene(posCell,objOrder);
            vc{end+1} = imresize(nextimg,0.35); %%%% This value was set fairly arbitrarily at the end
            imshow(vc{end}); drawnow; pause(0.05);
        end
    end

    function newscene = makeScene(positionCell,imgOrderVec)
        scenecell = blankScene;
        for orderInd = 1:length(imgOrderVec)
            whichImg = imgOrderVec(orderInd);
            imgPos = positionCell{whichImg};
            if length(imgPos)>0 
                smallMask = mask{whichImg};
                [bigMask,newSmallMask] = extendMask(smallMask,imgPos,sceneHeight,sceneWidth);
                for j=1:3
                    imgSliceToCrop = img{whichImg}(:,:,j);
                    scenecell{j}(not(bigMask)) = imgSliceToCrop(not(newSmallMask));
                    %% The follow can be used to inspect errors
                    %try
                        %scenecell{j}(not(bigMask)) = imgSliceToCrop(not(newSmallMask));
                    %catch
                        %fprintf('ERROR ==> first size: [%d,%d], second size: [%d,%d]\n',...
                            %size(scenecell{j}(not(bigMask))), size(imgSliceToCrop(not(newSmallMask))));
                    %end
                end
            end
        end
        newscene(:,:,1) = scenecell{1};
        newscene(:,:,2) = scenecell{2};
        newscene(:,:,3) = scenecell{3};
    end

end
