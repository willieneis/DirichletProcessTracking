function pmcmc_main_usbh()
% main mcmc script for usbh (ants) data

    addpath('../misc/','../viz/');

    load('../../data/usbh.mat','data');
    data = rarefy_data(data, 10000);

    % Format: params = {crp, del, #aux, tau0, v0, mu0, k0, q0, _,_,_<-#colorbins?}
    params = {0.1, 0.7, 10, 3*eye(2), 60, [0,0], 0.05, 10*ones(1,10), 1, 1, 1};

    % PMCMC
    numGlobalGibbs = 5; numParticles = 5; numLocalGibbs = 5;
    samples = pmcmc_infer(data,params,numGlobalGibbs,numParticles,numLocalGibbs,'~/proj/ddpTracking/results/ants/pmcmc/');
