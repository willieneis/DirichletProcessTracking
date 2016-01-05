function extract_tcell()
% Perform data extraction on the T cell datset.

    datapath = '~/Downloads/ddpTrackingStuff/tcell_exp1_fluor/';
    videocell = imgfolder2videocell(datapath);
    [data,data_orig,saveParams] = extraction_new(videocell,0.1);
    clear videocell
    save('~/proj/ddpTracking/data/tcell_exp1_fluor.mat');
