 function [xsup,w,w0,tps,alpha, value, optC] = aol(nsample, A,y, X, Res,kernel,kerneloption,verbose,lambda, prob, c, nfold)

 classcode=[1 -1];
 label = A.*sign(Res);
 Resweight = abs(Res)/prob;
 scoreweight = y/prob;

 
 rng('default')
 
 partition = cvpartition(nsample,'KFold',nfold);
 
 value=[];
     
for i=1:length(c)
   i   
        
   bc = [];
   for j=1:nfold
     
     idtrain = training(partition,j);
     Xapp = X(idtrain,:);
     Aapp = A(idtrain,:);
     yapp = y(idtrain,:);
     Resapp = Res(idtrain,:);
  
     % class label
     
     labelapp = Aapp.*sign(Resapp);
     Resweightapp = abs(Resapp)/prob;
     
     scoreweightapp = yapp/prob;
     
     idtest = test(partition,j);
     Xtest = X(idtest,:);
     Atest = A(idtest,:);
     ytest = y(idtest,:);
     Restest = Res(idtest,:);
     
     
     labeltest = Atest.*sign(Restest);
     Resweightest = abs(Restest)/prob;
     
     scoreweightest=ytest/prob;
     
     phi = ones(size(labelapp));
     
     [xsup,w,w0,tps,alpha] = wsvmclass(Xapp,labelapp,Resweightapp,c(i),lambda,kernel,kerneloption,verbose,phi); 
   
     ypred = svmval(Xtest,xsup,w,w0,kernel,kerneloption,ones(size(Xtest,1),1));%,framematrix,vector,dual)
     rulepred = sign(ypred);
      
   % compute the value function
     bc = [bc, mean((rulepred==Atest).*scoreweightest)];

    end;% end CV
    
    value(i) = mean(bc);
   
end

indexcv = find(value==max(value));

optC = c(indexcv);

phi = ones(size(label));
  
% refit on whole training data set
[xsup,w,w0,tps,alpha] = wsvmclass(X,label, Resweight,optC,lambda,kernel,kerneloption,verbose,phi);  
  
     
    
        