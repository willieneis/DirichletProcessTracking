
function s_choice = smc1_resample(s_samples, s_weights)





[del, ind] = max(s_weights);

s_choice = s_samples{ind};
