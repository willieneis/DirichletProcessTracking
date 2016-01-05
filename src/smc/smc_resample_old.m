function particles = smc_resample(particles,t,data)
% This function computes the weights for each particle and
%   resamples particles with multinomial resampling.

    addpath('../my_log_prob/','../prob/','../mcmc/');
    
    data_t = data(find(data(:,end)==t),:);
    for pInd = 1:length(particles)
        weights(pInd) = compute_weights(pInd);
    end
    particles = resample_particles();

    % Aux functions
    % -------------

    function weight = compute_weights(particleIndex)
        state = particles{particleIndex};
        weightNumer = getWeightNumer();
        weightDenom = getWeightDenom();
        weight = exp(weightNumer-weightDenom);
    end

    function weightNumer = getWeightNumer()
        term1 = getJointProbTheta();
        term2 = getJointProbAssig();
        term3 = getJointProbSize();
        term4 = getJointProbData();
        weightNumer = term1+term2+term3; % functions return log-postProb
    end

    function weightDenom = getWeightDenom()
        %t1 = getPostProbTheta();
        %t2 = getPostProbAssig();
        %t3 = getPostProbSize();
        %weightDenom = t1*t2*t3;
        t1 =1; t2 =1; t3 =1;
        weightDenom = t1+t2+t3; % functions return log-postProb
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
    end

    function postProbTheta = getPostProbTheta()
        postProbTheta = 1;
    end

    function postProbSize = getPostProbSize()
        postProbSize = 1;
    end

    function jointProbTheta = getJointProbTheta()
        jointProbTheta = 1;
    end

    function jointProbAssig = getJointProbAssig()
        jointProbAssig = 1;
    end

    function jointProbSize = getJointProbSize()
        jointProbSize = 1;
    end

    function jointProbData = getJointProbData()
        jointProbData = 1;
    end

    function newparticles = resample_particles()
        newind = catrnd(weights,length(particles));
        newparticles = particles(newind);
    end

end
