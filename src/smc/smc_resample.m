function particles = smc_resample(particles,t,data,params)
% This function computes the weights for each particle and
%   resamples particles with multinomial resampling.

    addpath('../my_log_prob/','../prob/','../mcmc/');
    
    ind_t = find(data(:,end)==t);
    ind_t_range = []; if size(ind_t,1)>0, ind_t_range = ind_t(1):ind_t(end); end
    data_t = data(ind_t,:);
    final_obs = getFinalObs();
    K = 0;
    state = {};

    % get weights
    for pInd = 1:length(particles)
        weights(pInd) = compute_weights(pInd);
    end
    particles = resample_particles();

    % Aux functions
    % -------------

    function fo = getFinalObs()
        temp = ind_t;
        temp_t = t;
        while length(temp)==0 && temp_t>0
            fprintf('Zero observations for t = %d.\n',temp_t);
            temp_t = temp_t-1;
            temp = find(data(:,end)==temp_t);
        end
        if temp_t>0 fo = temp(end); else fo = 0; end
    end

    function weight = compute_weights(particleIndex)
        state = particles{particleIndex};
        K = size(state{2},2);
        weightNumer = getWeightNumer();
        weightDenom = getWeightDenom();
        weight = exp(weightNumer-weightDenom);
        %weightNumer
        %weightDenom
        %weight
    end

    function weightNumer = getWeightNumer()
        term1 = getJointProbTheta();
        term2 = getJointProbAssig();
        term3 = getJointProbData();
        weightNumer = term1+term2+term3; % functions return log-jointProb
    end

    function weightDenom = getWeightDenom()
        t1 = getPostProbTheta();
        t2 = getPostProbAssig();
        weightDenom = t1+t2; % functions return log-postProb
    end

    function postProbAssig = getPostProbAssig()
        % compute probability for each assignment in state{1}.
        for i = 1:size(data_t,1)
            if size(state{1},2)>=ind_t(1)-1+i, old_k = state{1}(ind_t(1)-1+i); else old_k = -1; end

            % find prob of assignment given clustersizes and alpha
            if size(state{3},2) > 0
                sizes = state{3}(final_obs,:);
            else
                sizes = [];
            end
            sizes(K+1) = params{1};
            prob_assig = sizes/sum(sizes);

            % find prob of observation given cluster parameters
            x = data_t(i,:);
            for k = 1 : K
                if sizes(k) > 0
                    log_prob_obs(k) = log(mvnpdf(x(1:2),state{2}{t,k}{1},state{2}{t,k}{2}));
                else
                    log_prob_obs(k) = -inf;
                end
            end
            log_prob_obs(K+1) = log(mvnpdf(x(1:2),[0,0],1.0000e+20*eye(2))); % approximate predictive marginal

            % prob_vec is the discrete probability vector from which an assignment is sampled
            prob_vec = prob_assig .* exp(log_prob_obs);

            % get prob of state{1}(ind_t(1)-1+i) given prob_vec 
            postProbAssig_i(i) = log(catpdf(state{1}(ind_t(1)-1+i),prob_vec));
        end
        postProbAssig = sum(postProbAssig_i);
    end

    function postProbTheta = getPostProbTheta()
        for k = 1:K
            if state{3}(final_obs,k)>0;
                % if cluster is alive
                if t==1
                    data_k = data_t(find(state{1}(ind_t_range)==k),:);
                    params_post = update_mvnmn_params(data_k(:,1:2),data_k(:,3:end-1),params);
                else
                    data_k = data_t(find(state{1}(ind_t_range)==k),:);    
                    if size(data_k,1)>0 && length(state{2}{t-1,k})>0
                        % if obs assigned and there exists prev cluster params
                        aux_mvn = mvnrnd(state{2}{t-1,k}{1},state{2}{t-1,k}{2},params{3});
                        aux_mn = mnrnd(params{11},state{2}{t-1,k}{3},params{3}+50);
                        params_post = update_mvnmn_params([aux_mvn;data_k(:,1:2)],[aux_mn;data_k(:,3:end-1)],params);
                    elseif length(state{2}{t-1,k}) > 0
                        % if no obs assigned and there exists prev cluster params
                        aux_mvn = mvnrnd(state{2}{t-1,k}{1}, state{2}{t-1,k}{2}, params{3});
                        aux_mn = mnrnd(params{11}, state{2}{t-1,k}{3}, params{3}+50);
                        params_post = update_mvnmn_params(aux_mvn,aux_mn,params);
                    else
                        % if there does not exist previous cluster params
                        % (and there must be obs assigned since cluster is alive)
                        params_post = update_mvnmn_params(data_k(:,1:2),data_k(:,3:end-1),params);
                    end
                end
                % find prob of params_post 
                postProbTheta_k(k) = log(mvnpdf(state{2}{t,k}{1},params_post{6},state{2}{t,k}{2}/params_post{7}));
            end	
        end
        postProbTheta = sum(postProbTheta_k);
    end

    function jointProbTheta = getJointProbTheta()
        for k = 1:K
            if state{3}(final_obs,k)>0;
                data_k = data_t(find(state{1}(ind_t_range)==k),:);
                if t==1
                    params_post = update_mvnmn_params(data_k(:,1:2),data_k(:,3:end-1),params);
                else
                    if length(state{2}{t-1,k}) > 0
                        aux_mvn = mvnrnd(state{2}{t-1,k}{1}, state{2}{t-1,k}{2}, params{3});
                        aux_mn = mnrnd(params{11}, state{2}{t-1,k}{3}, params{3}+50);
                        params_post = update_mvnmn_params(aux_mvn,aux_mn,params);
                    else
                        params_post = update_mvnmn_params(data_k(:,1:2),data_k(:,3:end-1),params);
                    end
                end
                % find prob of params_post 
                jointProbTheta_k(k) = mvnpdf(state{2}{t,k}{1},params_post{6},state{2}{t,k}{2}/params_post{7});
            end	
        end
        jointProbTheta = sum(jointProbTheta_k);
    end

    function jointProbAssig = getJointProbAssig()
        for i = 1:size(data_t,1)
            if size(state{1},2)>=ind_t(1)-1+i, old_k = state{1}(ind_t(1)-1+i); else old_k = -1; end

            % find prob of assignment given clustersizes and alpha
            if size(state{3},2) > 0
                sizes = state{3}(final_obs,:);
            else
                sizes = [];
            end
            sizes(K+1) = params{1};
            prob_assig = sizes/sum(sizes);

            % get prob of state{1}(ind_t(1)-1+i) given prob_assig
            jointProbAssig_i(i) = log(catpdf(state{1}(ind_t(1)-1+i),prob_assig));
        end
        jointProbAssig = sum(jointProbAssig_i);
    end

    function jointProbData = getJointProbData()
        for i = 1:size(data_t,1)
            assigVal = state{1}(ind_t(1)-1+i);
            jointProbData_i(i) = mvnpdf(data_t(i,1:2),state{2}{t,assigVal}{1},state{2}{t,assigVal}{2});
        end
        jointProbData = sum(jointProbData_i);
    end

    function newparticles = resample_particles()
        newind = catrnd(weights,length(particles));
        newparticles = particles(newind);
    end

end
