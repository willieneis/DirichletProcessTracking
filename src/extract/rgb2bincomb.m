function newmat = rgb2bincomb(img,numbins)
% This function converts the img (k-slices) to a 2-dim array 
%   where a pixel position has a value that specifies which 
%   combination of bins it is in (ie puts img into bin-combination
%   form).
% More precisely: img is a 'stack of slices', where each slice is 
%   a matrix carrying a given type of color information and
%   numbins is a k-dim vector (where k is the number of 'slices').

    % set each color value (in the img matrix) to between 0 and 1
    img = im2double(img);

    % compute matrix, newmat, that holds 'which bin' for each pixel
    numslices = size(img,3);

    % take size of newmat to be same as first slice
    newmat = zeros(size(img(:,:,1)));

    for k = 1 : numslices
        % make each value a positive int between 0 and numbins-1
        temp = floor(numbins(k)*(img(:,:,k))); 
            % newmat(:,:,k) = temp*(numbins^(numslices-k));
        alpha = prod(numbins)/prod(numbins(1:k));
        newmat = newmat + alpha*(temp);
    end

    % indices in newmat are from 0:num_tot_bins-1... change to from 1:num_tot_bins
    newmat = newmat + 1;
