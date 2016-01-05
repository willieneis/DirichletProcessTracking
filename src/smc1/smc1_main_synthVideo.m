function smc1_main_synthVideo()
% main smc1 script for synthetic video data 

    addpath('~/proj/ddpTracking/src/misc/', ...
            '~/proj/ddpTracking/src/viz/');

    load('~/proj/ddpTracking/data/synthVideo_small.mat','data');
    data = rarefy_data(data, 15000);

    % Format: params = {crp, del, #aux, tau0, v0, mu0, k0, q0, _,_,_<-#colorbins?}
    params = {0.1, 0.32, 10, 5*eye(2), 60, [0,0], 0.05, 10*ones(1,5), 1, 1, 1};

    % Format: state = {assignments, clusterParams, clusterSizes}
    state = {[],{},zeros(size(data,1),0)};
    state = smc1_infer(state,data,params,10,'~/proj/ddpTracking/results/synthVideo/');
