function extract_ants()
% Perform data extraction on the ants datset.

    datapath = '~/proj/ddpTracking/data/hide/videoimg/ants/';
    videocell = imgfolder2videocell(datapath);
    [data,data_orig,saveParams] = extraction_new(videocell,0.1);
    clear videocell
    save('~/proj/ddpTracking/data/ants.mat');
