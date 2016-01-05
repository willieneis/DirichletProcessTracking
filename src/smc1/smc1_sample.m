function state = smc1_sample(state,data,params,t,s,numsamples)
% sample each (alive) cluster's parameters, each assignment,
% perform deletion step, update size matrix
    
    addpath('~/proj/ddpTracking/src/my_log_prob/',...
            '~/proj/ddpTracking/src/prob/',...
            '~/proj/ddpTracking/src/mcmc/');

    % data_t holds observations at current time t
    ind_t = find(data(:,end)==t);
    if size(ind_t,1)>0 ind_t_range = ind_t(1):ind_t(end); else ind_t_range = []; end
    data_t = data(ind_t,:);

    % final_obs is index of 'most recent' observation (from either current or a previous time)
    temp = ind_t;
    temp_t = t;
    while length(temp)==0 && temp_t>0
        fprintf('Zero observations for t = %d.\n',temp_t);
        temp_t = t-1;
        temp = find(data(:,end)==temp_t);
    end
    if temp_t>0 final_obs = temp(end); else final_obs = 0; end  %%%% will this work with the code below?..i call state{3}(final_obs, k)...

    % K is number of clusters
    K = size(state{2},2);
    K_init = K;

    % update cluster params based on assignments &/or transition kernel.
    %   (for s=1, t>1, initialize to clusters at previous time.)
    for k = 1:K
        if t>1 && s==1
            % case where s=1 and t>1,
            %   initialize cluster params to previous cluster params
            state{2}{t,k} = state{2}{t-1,k};    
        else
            if state{3}(final_obs,k)>0;
                % if cluster is alive
                if t==1
                    % case where t = 1 (and for any s)
                    data_k = data_t(find(state{1}(ind_t_range)==k),:); % get all obs (of t=1) assigned to cluster k
                    params_post = update_mvnmn_params(data_k(:,1:2),data_k(:,3:end-1),params);
                else
                    % case where s>1 && t>1
                    %   get all obs (of current t) assigned to cluster k
                    data_k = data_t(find(state{1}(ind_t_range)==k),:);    
                    if size(data_k,1)>0 && length(state{2}{t-1,k})>0
                        % if obs assigned and there exists prev cluster params
                        aux_mvn = mvnrnd(state{2}{t-1,k}{1},state{2}{t-1,k}{2},params{3});
                        aux_mn = mnrnd(params{11},state{2}{t-1,k}{3},params{3}+50);
                        params_post = update_mvnmn_params([aux_mvn;data_k(:,1:2)],[aux_mn;data_k(:,3:end-1)],params);
                    elseif length(state{2}{t-1,k}) > 0
                        % if no obs assigned (and there exists prev cluster params)
                        aux_mvn = mvnrnd(state{2}{t-1,k}{1}, state{2}{t-1,k}{2}, params{3});
                        aux_mn = mnrnd(params{11}, state{2}{t-1,k}{3}, params{3}+50);
                        params_post = update_mvnmn_params(aux_mvn,aux_mn,params);
                    else
                        % if there does not exist previous cluster params
                        %   (and there must be obs assigned since cluster is alive)
                        params_post = update_mvnmn_params(data_k(:,1:2),data_k(:,3:end-1),params);
                    end
                end
                % sample cluster params
                state{2}{t,k}{2} = iwishrnd(params_post{4},params_post{5});
                state{2}{t,k}{1} = mvnrnd(params_post{6},state{2}{t,k}{2}/params_post{7});
                state{2}{t,k}{3} = dirrnd(params_post{8},1);
            end	
        end
    end

    % sample assignment for each data_t obs and put into state{1}.
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
                %%%%
                %log_prob_obs(k) = my_log_mvnpdf(x(1:2),state{2}{t,k}{1},state{2}{t,k}{2}) + my_log_mnpdf(x(3:end-1), sum(x(3:end-1)), state{2}{t,k}{3});
                %log_prob_obs(k) = log(mvnpdf(x(1:2),state{2}{t,k}{1},state{2}{t,k}{2})) + log(mnpdf(x(3:end-1),state{2}{t,k}{3}));
                log_prob_obs(k) = log(mvnpdf(x(1:2),state{2}{t,k}{1},state{2}{t,k}{2}));
                %%%%
            else
                log_prob_obs(k) = -inf;
            end
        end

        %log_prob_obs(K+1) = my_log_niwdir_coefratio(x, params);  % "predictive marginal"
        log_prob_obs(K+1) = log(mvnpdf(x(1:2),[0,0],1.0000e+20*eye(2))); % approximate predictive marginal

        % prob_vec is the discrete probability vector from which an assignment is sampled
        prob_vec = prob_assig .* exp(log_prob_obs);

        if sum(prob_vec) > 0
            sample_k = randcat(prob_vec);
        else
            [del,sample_k] = max(log(prob_assig)+prob_obs);
            disp('PROBABILITY VECTOR TOO SMALL TO TAKE EXPONENT WITHOUT UNDERFLOW!')
        end
        
        % update state{1}
        state{1}(ind_t(1)-1+i) = sample_k;

        % in case where sample_k is a new cluster
        if sample_k == K+1
            K = K+1;
            state = smc1_newclust(state, params, x, t);
            %fprintf('\t%d. A new cluster was sampled.\n',K);
        end

        % update sizes ie state{3}
        if old_k ~= -1
            state{3}(ind_t(1)-1+i:end, old_k) = state{3}(ind_t(1)-1+i:end, old_k) - 1;
        end	
        state{3}(ind_t(1)-1+i:end, sample_k) = state{3}(ind_t(1)-1+i:end, sample_k) + 1;
    end

    % if s is final sample, perform deletion for the obs in each alive cluster (and update s_sample{3} a final time)
    if s==numsamples
        for k = 1:K
            if state{3}(final_obs,k) > 0
                numdead = binornd(state{3}(final_obs,k),params{2});
                state{3}(final_obs+1:end,k) = state{3}(final_obs+1:end,k)-numdead;
            end
        end
    end
