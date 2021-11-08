 function [xsup,w,w0,tps,alpha] = owl(nsample, A,y, X, kernel,kerneloption,verbose,lambda, prob, c, nfold)

 classcode=[1 -1];

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
    
     
     scoreweightapp=yapp/prob;
     
     idtest = test(partition,j);
     Xtest = X(idtest,:);
     Atest = A(idtest,:);
     ytest = y(idtest,:);
     
     scoreweightest=ytest/prob;
     
     phi = ones(size(Aapp));
     
     [xsup,w,w0,tps,alpha] = wsvmclass(Xapp,Aapp,scoreweightapp,c(i),lambda,kernel,kerneloption,verbose,phi); 
   
     ypred = svmval(Xtest,xsup,w,w0,kernel,kerneloption,ones(size(Xtest,1),1));%,framematrix,vector,dual)
     rulepred = sign(ypred);
      
   % compute the value function
     bc = [bc, mean((rulepred==Atest).*scoreweightest)];
    

   end;% end CV 
       
        
  value(i) = mean(bc);
        
 end
 
 indexcv = find(value==max(value));
 optC = c(indexcv);  
 phi = ones(size(A));
 
 % refit on training data set
[xsup,w,w0,tps,alpha] = wsvmclass(X, A, scoreweight,optC,lambda,kernel,kerneloption,verbose,phi);  

    
        