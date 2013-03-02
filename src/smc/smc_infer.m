function particles = smc_infer(particles,data,params,numsamples,dirstring)
% inference for sequential monte carlo with L particles 
    
    addpath('../viz/','../misc/','../smc1/');

    t_start = size(particles{1}{2},1)+1;
    t_end = max(data(:,end));
    for t = t_start:t_end
        for pInd=1:length(particles)
            state = particles{pInd};
            for s = 1:numsamples
                % Sample from proposal
                state = smc1_sample(state,data,params,t,s,numsamples);
                display_progress();
                periodic_draw_viz();
            end
            state = clean_state(state);
            particles{pInd} = state;
        end
        particles = smc_resample(particles,t,data);
        periodic_save()
    end

    % Auxiliary functions    
    % -------------------
    function periodic_draw_viz()
        %state = particles{1}; %%%% just to test it
        if true % mod(t-t_start+1,5)==0 || t==t_start || t==t_end
            clf
            viz_smc1_result(data(1:size(state{1},2),[1,2,end]),state,'fil','stddev');
            %view(360*s/25,25) % rotating view
            view(45,25);
            zlim([1, t_end]);
            drawnow
        end
    end

    function display_progress()
        if s==1
            fprintf('Completed: t=%d, sample=%d',t,s);
        elseif s==numsamples
            fprintf(',%d (all samples complete)\n',s);
        else
            fprintf(',%d',s);
        end
    end

    function periodic_save()
        % save workspace periodically
        if mod(t-t_start+1,5)==0 || t==t_end, save([dirstring, 'NEW_INFER_WS.mat']); end
    end

end
