function [J,lam] = cout(H,x,y,C,ind,c,A,b,lambda)
%         [J,yx] = cout(H,x,b,C,indd,c,A,b,lambda); 

 % this function does not need y, A, b, lambda
  
	[n,m] = size(H);  
	X = zeros(n,1);  
	posok = find(ind > 0);  
	posA = find(ind==0);			% liste des contriantes saturees  
	posB = find(ind==-1);			% liste des contriantes saturees  
			%			 keyboard                                                 
	X(posok) = x;  
	X(posB) = C(posB);     %% 03/01/2002 (guarantee x_i not suppress C_i, if )

	J = 0.5 *X'*H*X  - c'*X;% + lambda'*(A'*X-b); 		   
				                % 0 normalement  
 % keyboard  
    
 % lam = y'*X;  
lam = 0; %à éliminer
    
    
