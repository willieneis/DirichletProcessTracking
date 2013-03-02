function params = update_mvnmn_params(obs_mvn,obs_mn,params)
% obs_mvn is a matrix of pixel positions and obs_mn is a matrix
%   of pixel color-bin vectors.

    obs1 = obs_mvn;
    obs2 = obs_mn;

    % update the 4 mvn params:
    n = size(obs1,1);
    S = (obs1(1,:)-mean(obs1))' * (obs1(1,:)-mean(obs1));
    for i = 2:size(obs1,1)
        S = S + (obs1(i,:)-mean(obs1))' * (obs1(i,:)-mean(obs1));
    end
    k_n = params{7}+n;
    v_n = params{5}+n;
    mu_n = (mean(obs1)*n/k_n) + (params{6}*params{7}/k_n);
    tau_n = params{4} + S + (params{7}*n*(params{6}-mean(obs1))*(params{6}-mean(obs1))'/k_n);

    % update the 1 mn param:
    q_n = params{8} + sum(obs2);

    % update params
    params(4:8) = {tau_n, v_n, mu_n, k_n, q_n};
