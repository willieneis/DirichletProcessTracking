
function smc1_sens2surf()

% call this fn once ws holding results from sensitivity analysis script is loaded
% it converts pm1, pm2, and jlp to surfaces




pm1 = evalin('caller', 'pm1');
pm2 = evalin('caller', 'pm2');
% jlp = evalin('caller', jlp);




for i = 1 : 5
    for j = 1 : 5
        linind = (((i-1)*5) + j);
        Z(i,j) = pm1(linind) + 0.05;
     end
end
Z
figure, surf(Z)


for i = 1 : 5
    for j = 1 : 5
        linind = (((i-1)*5) + j);
        Z2(i,j) = pm2(linind) + 0.05;
     end
end
Z2
figure, surf(Z2)


% for i = 1 : 5
%     for j = 1 : 5
%         linind = (((i-1)*5) + j);
%         Z3(i,j) = jlp(linind);
%      end
% end
% Z3
% surf(Z3)