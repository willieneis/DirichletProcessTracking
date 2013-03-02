function videocell = imgfolder2videocell(dirstring,startimg,cyclesize,numimgs)
% This function takes a folder of images and converts them into a videocell
%   data structure. 
% Eg: videocell = imgfolder2videocell('datapath'); 
%   (note that this assumes every file in folder is an image file).

    % load into struct array
    imgfiles = dir(dirstring);

    % Defaults
    if nargin<2 startimg = 1; end  % default startimg
    if nargin<3 cyclesize = 1; end  % default cyclesize
    if nargin<4 endimg = size(imgfiles,1); end % default endimg
    if nargin>=4 endimg = numimgs*cyclesize+2; end

    % to handle the files . & .. in folder
    startimg = startimg + 2;

    % convert to cell, sort by name, then convert back to struct array (to ensure correct order)
    % ------------------------------------------------------------------------------------------

    % convert into cell
    fields = fieldnames(imgfiles);
    imgcell = struct2cell(imgfiles);
    sz = size(imgcell);

    % sort rows in cell form
    imgcell = reshape(imgcell, sz(1), []);
    imgcell = imgcell';
    imgcell = sortrows(imgcell, 1);

    % convert back into original structure array
    imgcell = reshape(imgcell', sz);
    imgsorted = cell2struct(imgcell, fields, 1);
    %for id = 1:length(imgsorted)
        %fprintf('%d\n',id)
        %disp(imgsorted(id))
    %end

    % make imgs into videocell
    % ------------------------

    % load each image
    videocell = {};
    for k = startimg : cyclesize : endimg
        videocell{end+1} = imread([dirstring, '/', imgfiles(k).name]);
    end
