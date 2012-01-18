
function smc1_main_synth-cs1()



% load data

load('../gpudpm4mtt/tests/synth_colorsquares/data_synth_colorsquares_1.mat');

% load('../gpudpm4mtt/tests/synth_colorsquaresreverse/data_synth_colorsquaresreverse_1.mat');


data = rarefy_data(data, 5000);


% params = {crp, del, #aux, tau0, v0, mu0, k0, q0, _,_,_<-#colorbins?}

params = {10, 0.1, 5, eye(2), 5, [0,0], 0.05, 5*ones(1,10), 1, 1, 1};


% init and infer

% state = init_1smc(data, params, ... )

state = {[], {}, zeros(size(data,1),0)};

state = smc1_infer(state, data, params, 20, './');


% viz

viz_result(data(:, [1,2,end]), state{1}, state{2}, 'fill', 'stddev');