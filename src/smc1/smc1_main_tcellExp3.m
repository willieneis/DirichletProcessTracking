function smc1_main_usbh()
% main smc1 script for tcellExp3 data

    addpath('~/proj/ddpTracking/src/misc/', ...
            '~/proj/ddpTracking/src/viz/');

    load('~/proj/ddpTracking/data/tcell_exp3_dic.mat', 'data');
    data = rarefy_data(data,100000);

    % Format: params = {crp, del, #aux, tau0, v0, mu0, k0, q0, _,_,_<-#colorbins?}
    params = {6, 0.7, 10, 0.3*eye(2), 100, [0,0], 0.05, 10*ones(1,5), 1, 1, 1};

    % Format: state = {assignments, clusterParams, clusterSizes}
    state = {[],{},zeros(size(data,1),0)};
    state = smc1_infer(state,data,params,15,'~/proj/ddpTracking/results/tcell/');
