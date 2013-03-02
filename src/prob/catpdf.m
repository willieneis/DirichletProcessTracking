function pdfVal = catpdf(ind,p)
% compute pdf of ind from categorical dist with param vector p
p = p/sum(p);
pdfVal = p(ind);
