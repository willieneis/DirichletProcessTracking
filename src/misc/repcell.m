function repdcell = repcell(obj,m,n)
repdcell = cell(m,n);
for i=1:m
    for j=1:n
        repdcell{i,j} = obj;
    end
end
