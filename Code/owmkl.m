 function [eta,w,b,posw,story,obj, Weight,InfoKernel, optC, value]  = owmkl(nsample, A,y, X, Res, kernel, kerneloptionvec, variableveccell, option, verbose, prob, c, nfold)
% bc: value function
 classcode=[1 -1];
 label = A.*sign(Res);
 Resweight = abs(Res)/prob;
 scoreweight = y/prob;


 rng('default')
 
 partition = cvpartition(nsample,'KFold',nfold);
 
 value = [];
 for i= 1:length(c)
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
     
     scoreweightest = ytest/prob;
        
  
     [Weight,InfoKernel] = UnitTraceNormalization(Xapp,kernel,kerneloptionvec,variableveccell);
     K = mklkernel(Xapp,InfoKernel,Weight,option);

     [beta,w,b,posw,~,~] = wmklsvm(K, labelapp, Resweightapp, c(i), option, verbose);
  
     Kt = mklkernel(Xtest,InfoKernel,Weight,option,Xapp(posw,:),beta);
     rulepred = sign(Kt*w+b);

    
   % compute the value function
     bc = [bc, mean((rulepred == Atest).*scoreweightest)];


   end;% end CV
 
 
   value(i)=mean(bc);
    
  end; % end of loop of tuning parameter values
  
% find the index of C value which maximizes the CV value function
indexcv = find(value==max(value));
optC = c(indexcv);
 
  
   % refit on the whole training data set to obtain parameter estimations
[Weight,InfoKernel] = UnitTraceNormalization(X, kernel, kerneloptionvec,variableveccell);
K = mklkernel(X,InfoKernel,Weight,option);
    
% eta: kernel weights
[eta,w,b,posw,story,obj] = wmklsvm(K,label, Resweight, optC, option, verbose);


  

     
    
        