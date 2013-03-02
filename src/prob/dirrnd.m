function sample = dirrnd(params,numsamples)
% Sample from a Dirichlet distribution.

    sample = gamrnd(repmat(params, numsamples, 1), 1, numsamples, length(params));
    sample = sample(:, 1:end-1) ./ repmat(sum(sample,2), 1, length(params)-1);
    sample(:, end+1) = ones(numsamples, 1) - sum(sample, 2);
