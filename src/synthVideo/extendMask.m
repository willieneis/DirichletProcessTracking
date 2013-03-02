function [mask,oldMaskWithCrops] = extendMask(mask,position,goalHeightSize,goalWidthSize)
    
    ypos = position(1);
    xpos = position(2);
    oldMaskWithCrops = mask;
    
    % first extend the height to goalHeightSize
    height = size(mask,1);

    [height,mask] = oddEvenFix_height();

    heightRad = (height-1)/2;
    topDiff = ypos - heightRad - 1;
    if topDiff<0
        mask(1:abs(topDiff),:) = [];
        oldMaskWithCrops(1:abs(topDiff),:) = 1;
    else
        mask = logical([ones(topDiff,size(mask,2)); mask]);
    end
    botDiff = goalHeightSize - ypos - heightRad;
    if botDiff<0
        mask(end-abs(botDiff)+1:end,:) = [];
        oldMaskWithCrops(end-abs(botDiff)+2:end,:) = 1; %%%% but whyyy the +2
    else
        mask = logical([mask; ones(botDiff,size(mask,2))]);
    end

    % then extend the width to goalWidthWize
    width = size(mask,2);

    [width,mask] = oddEvenFix_width();

    widthRad = (width-1)/2;
    leftDiff = xpos - widthRad - 1;
    if leftDiff<0
        mask(:,1:abs(leftDiff)) = [];
        oldMaskWithCrops(:,1:abs(leftDiff)) = 1;
    else
        mask = logical([ones(size(mask,1),leftDiff), mask]);
    end
    rightDiff = goalWidthSize - xpos - widthRad;
    if rightDiff<0
        mask(:,end-abs(rightDiff)+1:end) = [];
        oldMaskWithCrops(:,end-abs(rightDiff)+2:end) = 1; %%%% but whyyy the +2
    else
        mask = logical([mask, ones(size(mask,1),rightDiff)]);
    end
    
    % Aux functions
    % -------------

    function [h,sMask] = oddEvenFix_height()
        if mod(height,2)==0 
            sMask = logical([mask; ones(1,size(mask,2))]);
            h = height+1;
        else
            h = height;
            sMask = mask;
        end
    end
    
    function [w,sMask] = oddEvenFix_width()
        if mod(width,2)==0 
            sMask = logical([mask, ones(size(mask,1),1)]);
            w = width+1;
        else
            w = width;
            sMask = mask;
        end
    end

end
