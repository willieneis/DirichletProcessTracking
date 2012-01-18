
function smc1_main_synth-cs4()



% load data

load('../gpudpm4mtt/tests/synth_colorsquares4/data_synth_colorsquares4_1.mat');


data = rarefy_data(data, 5000);


% params = {crp, del, #aux, tau0, v0, mu0, k0, q0, _,_,_<-#colorbins?}

% params = {1, 0.1, 15, 0.2*eye(2), 7, [0,0], 0.05, 10*ones(1,10), 1, 1, 1};

params = {1, 0.2, 15, 0.1*eye(2), 10, [0,0], 0.05, 10*ones(1,10), 1, 1, 1};


% init and infer

% state = init_1smc(data, params, ... )

state = {[], {}, zeros(size(data,1),0)};

state = smc1_infer(state, data, params, 20, './');


% viz

viz_result(data(:, [1,2,end]), state{1}, state{2}, 'fill', 'stddev');