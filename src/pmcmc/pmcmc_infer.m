function samples = pmcmc_infer(data,params,numGlobalGibbs,numParticles,numLocalGibbs,dirstring)
% inference for particle Markov chain Monte Carlo 
    
    addpath('../viz/','../misc/','../smc1/','../smc/');

    % initialize
    samples{1} = pmcmc_init();
    for g=2:numGlobalGibbs
        state = {[],{},zeros(size(data,1),0)};
        particles = repcell(state,1,numParticles-1);
        T = max(data(:,end));
        for t = 1:T
            for pInd=1:length(particles)
                state = particles{pInd};
                for s = 1:numLocalGibbs
                    state = smc1_sample(state,data,params,t,s,numLocalGibbs);
                    display_progress();
                    periodic_draw_viz();
                end
                state = clean_state(state);
                particles{pInd} = state;
            end
            condState_t = getCondState_t(samples{g-1},t);
            condParticles = particles; condParticles{end+1} = condState_t;
            newCondParticles = smc_resample(condParticles,t,data,params);
            particles = newCondParticles(1:end-1);
        end
        samples{g} = particles{randi(length(particles))};
        periodic_save()
    end

    % Auxiliary functions    
    % -------------------
    function firstState = pmcmc_init()
        % init with smc1
        firstState = {[],{},zeros(size(data,1),0)};
        firstState = smc1_infer(firstState,data,params,numLocalGibbs,dirstring);
    end

    function smallState = getCondState_t(theState,time)
        % return theState truncated to how it looked at time t
        ind_t = find(data(:,end)==time);
        end_ind_t = ind_t(end);
        smallState{1} = theState{1}(1:end_ind_t);
        maxK = max(smallState{1});
        smallState{2} = theState{2}(1:time,1:maxK);
        smallState{3} = theState{3}(1:end_ind_t,1:maxK);
        smallState{3}(end_ind_t+1:size(data,1),:) = repmat(smallState{3}(end,:),size(data,1)-end_ind_t,1);
        if time<T
            smallState{3} = performDeletionStep(smallState{3},end_ind_t+1);
        end
    end

    function oldM = performDeletionStep(oldM,next_nInd)
        for k=1:size(oldM,2)
            if oldM(next_nInd,k)>0
                numdead = binornd(oldM(next_nInd,k),params{2});
                oldM(next_nInd:end,k) = oldM(next_nInd:end,k)-numdead;
            end
        end
    end

    function periodic_draw_viz()
        if true % mod(t-t_start+1,5)==0 || t==t_start || t==t_end
            clf
            viz_smc1_result(data(1:size(state{1},2),[1,2,end]),state,'fil','stddev');
            %view(360*s/25,25) % rotating view
            view(45,25);
            zlim([1,T]);
            drawnow
        end
    end

    function display_progress()
        if s==1
            fprintf('Completed: g=%d, t=%d, l=%d, s=%d',g,t,pInd,s);
        elseif s==numLocalGibbs
            fprintf(',%d (all local samples complete)\n',s);
        else
            fprintf(',%d',s);
        end
    end

    function periodic_save()
        % save workspace periodically
        if mod(g,5)==0 || t==T, save([dirstring, 'NEW_INFER_WS.mat']); end
    end

end
