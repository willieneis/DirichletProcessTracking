
function choice = randcat(probvec)


% this function samples from a categorical distribution (ie from a discrete distribution)

% the only input to this function is probvec, a vector where each term is the probability of a category





% normalize probvec

probvec = probvec / sum(probvec);


% in case where everything is zero (should not happen?)

if sum(probvec) > 0
	
	% sample from categorical distribution
	
	rnd = rand;
	
	choice = -1;
	
	partialsum = 0;
	
	i = 1;
	
	while choice == -1
		
		partialsum = partialsum + probvec(i);
		
		if rnd < partialsum
			
			choice = i;
			
		end
		
		i = i + 1;
		
	end
	
else
	
	disp('probability vector in randcat sums to nonpositive');
	
	disp('sum of probability vector:');
	
	disp(sum(probvec));
	
	disp('ASSIGNED TO FIRST CLUSTER IN PROB VEC !!!');
	
	choice = 1;
	
	pause

end



%