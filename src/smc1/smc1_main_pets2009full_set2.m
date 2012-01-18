
function smc1_main_pets2009full_set2()



% load data

load('../gpudpm4mtt/tests/pets2009full/ws_data_pets2009full_set2.mat', 'data');

data = rarefy_data(data, 80000);


% params = {crp, del, #aux, tau0, v0, mu0, k0, q0, _,_,_<-#colorbins?}

params = {0.1, 0.6, 20, eye(2), 6, [0,0], 0.05, 5*ones(1,10), 1, 1, 1};


% init and infer

% state = init_1smc(data, params, ... )

state = {[], {}, zeros(size(data,1),0)};

state = smc1_infer(state, data, params, 50, './');


% viz

viz_result(data(:, [1,2,end]), state{1}, state{2}, 'fill', 'stddev');