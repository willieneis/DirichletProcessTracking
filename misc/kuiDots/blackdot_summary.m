%Nslices = 100;

%DOTS = load_slices(fullfile(DATA_PREFIX, 'kasthuri11_dots_all.hd5'), 500, Nslices);
%DOTS = DOTS(300:400,300:400,:);

load dots.mat

thresh = .1;

% Compute frame differences
% for n = 1:(Nslices + 1)
%     DOTS(:,:,n) = DOTS(:,:,n+1) - DOTS(:,:,n);
% end

straight = DOTS(:);

disp(['Summary statistics']);
disp(['Mean:' num2str(mean(straight)) ' SD: ' num2str(std(straight)) ...
      ' Median: ' num2str(median(straight)) ' Mode: ' num2str(mode(straight))]);

figure;
hist(straight, 100);
title('Black dot feature responses of pixels');

figure;
hist(straight <= thresh, 100);
title(['Black dot feature responses <= ' num2str(thresh)]);

% Find the top 1% of points
q90 = quantile(straight, .9);

indWhite = find(DOTS > q90);
[xW yW zW] = ind2sub([100 100 100], indWhite);

figure;
scatter3(xW, yW, zW, 1);

