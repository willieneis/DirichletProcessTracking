function smc_main_usbh()
% main smc script for usbh (ants) data

    addpath('../misc/','../viz/');

    load('~/proj/ddpTracking/data/data_usbh_combdist0L_10bins_noresize_1.mat','data');
    data = rarefy_data(data, 10000);

    % Format: params = {crp, del, #aux, tau0, v0, mu0, k0, q0, _,_,_<-#colorbins?}
    params = {0.1, 0.7, 10, 3*eye(2), 60, [0,0], 0.05, 10*ones(1,10), 1, 1, 1};

    % Format: state = {assignments, clusterParams, clusterSizes}
    state = {[],{},zeros(size(data,1),0)};
    particles = repcell(state,1,5);
    state = smc_infer(particles,data,params,5,'~/proj/ddpTracking/results/ants/pmcmc/');
