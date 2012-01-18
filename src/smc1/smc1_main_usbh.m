
function smc1_main_usbh()



% load data

load('../gpudpm4mtt/tests/usbh/data_ws_usbh_combdist0L_10bins_noresize_1.mat', 'data');

data = rarefy_data(data, 10000);


% params = {crp, del, #aux, tau0, v0, mu0, k0, q0, _,_,_<-#colorbins?}

params = {1, 0.1, 15, 0.2*eye(2), 7, [0,0], 0.05, 10*ones(1,10), 1, 1, 1};


% init and infer

% state = init_1smc(data, params, ... )

state = {[], {}, zeros(size(data,1),0)};

state = smc1_infer(state, data, params, 20, './');


% viz

viz_result(data(:, [1,2,end]), state{1}, state{2}, 'fill', 'stddev');