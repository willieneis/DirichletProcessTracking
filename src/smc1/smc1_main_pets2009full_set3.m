
function smc1_main_pets2009full_set3()



% load data

load('../gpudpm4mtt/tests/pets2009full/ws_data_pets2009full_set3.mat', 'data');

data = rarefy_data(data, 80000);

data = lessen_colorcounts_cont(data, 2);

% params = {crp, del, #aux, tau0, v0, mu0, k0, q0, _,_,_<-#colorbins?}  % dir-coef-ratio is -1

params = {0.1, 0.3, 30, eye(2), 5, [0,0], 0.05, 1*ones(1,30), 1, 1, 1};


% init and infer

state = {[], {}, zeros(size(data,1),0)};

state = smc1_infer(state, data, params, 50, './');


% viz

viz_result(data(:, [1,2,end]), state{1}, state{2}, 'fill', 'stddev');