function smc1_main_usbh()
% main smc1 script for tcellExp1 data

    addpath('~/proj/ddpTracking/src/misc/', ...
            '~/proj/ddpTracking/src/viz/');

    load('~/proj/ddpTracking/data/tcell_exp1_fluor_bwseg.mat','data');
    data = rarefy_data(data,50000);

    % Format: params = {crp, del, #aux, tau0, v0, mu0, k0, q0, _,_,_<-#colorbins?}
    params = {100000, 0.9, 10, 0.5*eye(2), 100, [0,0], 0.05, 10*ones(1,5), 1, 1, 1};

    % Format: state = {assignments, clusterParams, clusterSizes}
    state = {[],{},zeros(size(data,1),0)};
    state = smc1_infer(state,data,params,20,'~/proj/ddpTracking/results/tcell/');
