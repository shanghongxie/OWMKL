
%------------------------------------------------------
% generate data: call function simulation_generate_data
%------------------------------------------------------

% generate training data set
N = 150; 
set = 1; % setting 
[X, Y, A, Res] = simulation_generate_data(N, set);

% generate validation data set
valN = 100000; set = 1;
[Xval, Yval, Aval, Resval] = simulation_generate_data(valN, set);

      
%------------------------------------------------------
% Set up OWMKL
%------------------------------------------------------


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

% specify which kernel functions are used:  first two variables are binary variables, use indicator kernel function
kernelt={'indicator' 'indicator' 'poly' 'poly' 'gaussian' 'poly' 'poly' 'gaussian' 'poly' 'poly' 'gaussian' 'poly' 'poly' 'gaussian' 'poly' 'poly' 'gaussian' 'poly' 'poly' 'gaussian' 'poly' 'gaussian'};
% specify the values of parameter in kernel function
kerneloptionvect={1 1 1 2 0.05 1 2 0.05 1 2 0.05 1 2 0.05 1 2 0.05 1 2 0.05 1 1};

% specify which variable is used for that kernel function
variablevec={1 2 (3:12) (3:12) (3:12) (13:22) (13:22) (13:22) (23:32) (23:32) (23:32) (33:42) (33:42) (33:42) (43:47) (43:47) (43:47) (48:49) (48:49) (48:49) 50 50};

   %kernel: kernel function type; kerneloptionvec: parameter in kernel
   %function; variableveccell: indicator of which variable is used
% Create kernel functions
[kernel,kerneloptionvec,variableveccell]=CreateKernelList(variablevec,kernelt,kerneloptionvect);


%------------------------------------------------------------------------
%                  Fit OWMKL: call owmkl_cv to do cross-validation
%------------------------------------------------------------------------

classcode=[1 -1];

prob=0.5;

% set the searching path of tuning parameter C
seq=(2:10);    
c=2.^seq;
nfold = 2;

% fit OWMKL on the training data set: eta: kernel weights; value: value function of using different
% tuning parameter C; optC: optimal tuning parameter C
[eta,w,b,posw,story,obj, Weight,InfoKernel, optC, value]  = owmkl(N, A,Y, X, Res, kernel, kerneloptionvec, variableveccell, option, verbose, prob, c, nfold)

  % predict on validation data set
Kt = mklkernel(Xval, InfoKernel,Weight,option,X(posw,:),eta);
  
  % estimated treatment rule
rulepred = sign(Kt*w+b);

scoreweightval = Yval/prob;
  % compute value function
vfun = mean((rulepred==Aval).*scoreweightval);

% kernel weights

eta


%------------------------------------------------------
% For comparisons: AOL call function aol_cv to do CV
%------------------------------------------------------

kernel='poly';
kerneloption=1;

lambda = 0.00001
verbose=1;

prob = 0.5;

seq=(-15:15); 
c=2.^seq;
nfold = 2;

% fit AOL on the training data set
[xsup,w,w0,tps,alpha, value, optC] = aol(N, A, Y, X, Res,kernel,kerneloption,verbose,lambda, prob, c, nfold);
   
% estimate on validation data set
ypred = svmval(Xval,xsup,w,w0,kernel,kerneloption,ones(size(Xval,1),1));
rulepred = sign(ypred);

scoreweightval = Yval/prob;
% compute the value function
vfun = mean((rulepred==Aval).*scoreweightval);



%------------------------------------------------------
% For comparisons: OWL call function owl_cv to do CV
%------------------------------------------------------

kernel='poly';
kerneloption=1;

%lambda = 1e-10;  
lambda = 0.00001
verbose=1;

prob=0.5;

% choose tuning parameter c;

seq=(-15:15);
    
c=2.^seq;

classcode=[1 -1];

nfold = 2;

% fit OWL on the training data set 
[xsup,w,w0,tps,alpha] = owl(N, A, Y, X, kernel,kerneloption,verbose,lambda, prob, c, nfold);

% predict on validation data set
ypred = svmval(Xval,xsup,w,w0,kernel,kerneloption,ones(size(Xval,1),1));%,framematrix,vector,dual)
rulepred = sign(ypred);
   
scoreweightval = Yval/prob;
      % compute the value function
vfun = mean((rulepred==Aval).*scoreweightval);


% Q-learning was implemented in R using R package DTRlearn2