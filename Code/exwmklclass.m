% Example of how to use the mklsvm for  classification
%
%

clear all
close all
addpath('../toollp');


nbiter=1;
ratio=0.5;
data='ionosphere'
c=[100]; % tuning parameter
verbose=1;

option.algo='svmclass'; % Choice of algorithm in mklsvm can be either
                         % 'svmclass' or 'svmreg'
%------------------------------------------------------
% choosing the stopping criterion
%------------------------------------------------------
option.stopvariation=0; % use variation of weights for stopping criterion 
option.stopKKT=0;       % set to 1 if you use KKTcondition for stopping criterion    
option.stopdualitygap=1; % set to 1 for using duality gap for stopping criterion

%------------------------------------------------------
% choosing the stopping criterion value
%------------------------------------------------------
option.seuildiffsigma=1e-2;        % stopping criterion for weight variation 
option.seuildiffconstraint=0.1;    % stopping criterion for KKT
option.seuildualitygap=0.01;       % stopping criterion for duality gap

%------------------------------------------------------
% Setting some numerical parameters 
%------------------------------------------------------
option.goldensearch_deltmax=1e-1; % initial precision of golden section search
option.numericalprecision=1e-8;   % numerical precision weights below this value
                                   % are set to zero 
option.lambdareg = 1e-8;          % ridge added to kernel matrix 

%------------------------------------------------------
% some algorithms paramaters
%------------------------------------------------------
option.firstbasevariable='first'; % tie breaking method for choosing the base 
                                   % variable in the reduced gradient method 
option.nbitermax=500;             % maximal number of iteration  
option.seuil=0;                   % forcing to zero weights lower than this 
option.seuilitermax=10;           % value, for iterations lower than this one 

option.miniter=0;                 % minimal number of iterations 
option.verbosesvm=0;              % verbosity of inner svm algorithm 
%option.efficientkernel=1;         % use efficient storage of kernels 
option.efficientkernel=0;


%option.sumbeta must be set to either 'storefullsum' or 'onthefly'
% depending if you want to store the full gram matrix or compute in
% on the fly
option.sumbeta='storefullsum';
%------------------------------------------------------------------------
%                   Building the kernels parameters
%------------------------------------------------------------------------
kernelt={'gaussian' 'gaussian' 'poly' 'poly' };
kerneloptionvect={[0.5 1 2 5 7 10 12 15 17 20] [0.5 1 2 5 7 10 12 15 17 20] [1 2 3] [1 2 3]};
variablevec={'all' 'single' 'all' 'single'};




classcode=[1 -1];
load([data ]);
[nbdata,dim]=size(x);
% create outcome R (a nbdata*1 vector)
R=[0.1:0.1:5 5:-0.1:0.1 0.1:0.1:5 5:-0.1:0.1 0.1:0.1:5 5:-0.1:0.1 0.1:0.1:5 1]';
prob=[0.4*ones(1,100) 0.6*ones(1,100) 0.4*ones(1,75) 0.6*ones(1,76)]';
Rweight=R./prob;


nbtrain=floor(nbdata*ratio);
rand('state',0);

for i=1: nbiter
    i
    [xapp,yapp,xtest,ytest,Rweightapp, Rweightest,indice]=CreateDataAppTest(x, y, Rweight, nbtrain,classcode);
    [xapp,xtest]=normalizemeanstd(xapp,xtest);
    [kernel,kerneloptionvec,variableveccell]=CreateKernelListWithVariable(variablevec,dim,kernelt,kerneloptionvect);
    [Weight,InfoKernel]=UnitTraceNormalization(xapp,kernel,kerneloptionvec,variableveccell);
    K=mklkernel(xapp,InfoKernel,Weight,option);


    
    %------------------------------------------------------------------
    % 
    %  K is a 3-D matrix, where K(:,:,i)= i-th Gram matrix 
    %
    %------------------------------------------------------------------
    % or K can be a structure with uses a more efficient way of storing
    % the gram matrices
    %
    % K = build_efficientK(K);
    
    tic
    [beta,w,b,posw,story(i),obj(i)] = wmklsvm(K,yapp,Rweightapp,c,option,verbose);
    timelasso(i)=toc

    Kt=mklkernel(xtest,InfoKernel,Weight,option,xapp(posw,:),beta);
    ypred=Kt*w+b;

    bc(i)=mean(sign(ypred)==ytest)

end;%



