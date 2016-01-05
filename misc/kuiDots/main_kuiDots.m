
    addpath(genpath('~/proj/ddpTracking/src/')) % path to ddp code
    load data.mat % path to data matrix output from makeData.m

    % Format: params = {crp, del, #aux, tau0, v0, mu0, k0, q0, _,_,_<-#colorbins?}
    params = {10, 0.3, 10, 0.5*eye(2), 100, [0,0], 0.05, 10*ones(1,5), 1, 1, 1};

    % Format: state = {assignments, clusterParams, clusterSizes}
    state = {[],{},zeros(size(data,1),0)};
    state = smc1_infer(state,data,params,5,'./');
