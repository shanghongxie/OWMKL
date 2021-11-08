function [stdx] = standardize(x)

% USAGE
% normalize inputs and output mean and standard deviation to 0 and 1
%
% 
tol=1e-5;

meanx=mean(x);
sdx=std(x);

nbsuppress=0;
nbx=size(x,1);
indzero=find(abs(sdx)<tol);
%keyboard
if ~isempty(indzero)

    sdx(indzero)=1;

end;
nbvar=size(x,2);

stdx= (x - ones(nbx,1)*meanx)./ (ones(nbx,1)*sdx) ;
