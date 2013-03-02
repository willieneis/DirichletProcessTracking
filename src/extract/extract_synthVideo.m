function extract_synthVideo()
% Perform data extraction on the synthetic images.
    addpath('~/proj/ddpTracking/src/synthVideo/');
    videocell = makeSynthVid();
    [data,data_orig,saveParams] = extraction_new(videocell,0.4);
    save('~/proj/ddpTracking/data/creativeCommonsImg/videocell_synthVideo.mat','videocell');
    clear videocell
    save('~/proj/ddpTracking/data/synthVideo.mat');
