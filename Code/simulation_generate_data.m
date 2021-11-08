
function [X, Y, A, Res] = simulation_generate_data(N, set)
% N: sample size
% set: which setting
%------------------------------------------------------
% generate data
%------------------------------------------------------
Sigma = eye(48, 48);

for i = 1:4
    for j = 2:5
        if i ~=j
           Sigma(i,j) = 0.3;
           Sigma(j,i) = 0.3;
        end
       
    end
end
    
Sigma(6,7) = 0.3;
Sigma(6,8) = 0.3;

Sigma(11,12) = -0.3;
Sigma(11,13) = 0.3;
Sigma(12,13) = -0.3;
Sigma(11,14) = -0.3;

Sigma(15,16) = 0.3;
Sigma(15,17) = 0.3;


for i = 31:33
    for j = 32:34
        if i ~=j
           Sigma(i,j) = 0.3;
        end
       
    end
end
  
Sigma(35,36) = 0.3;
Sigma(35,37) = 0.3;

for i = 41:43
    for j = 42:44
        if i ~=j
           Sigma(i,j) = 0.3;
        end
       
    end
end

Sigma(46,47) = 0.3;
Sigma(1,48) = 0.3;
Sigma(2,48) = 0.3;
Sigma(3,48) = 0.3;
Sigma(11,48) = 0.3;
Sigma(12,48) = 0.3;

for i = 1:47
    for j = 2:48
        if i ~=j
           Sigma(j,i) = Sigma(i,j);
        end
       
    end
end

X = [];
A = [];
Y = [];
    
% indicate which simulation setting

for i=1:N
        
        % generate binary variable, =0 with prob=0.3
        x1=rand(1);
        if x1>0.3 x1=1;
        else x1=0;
        end;   
        
        % generate binary variable, prob=0.5, 0.5
        x2=rand(1);
        x2=round(x2);
        
        
        % generate multivariate variables
        mu=zeros(48,1);
        xi=mvnrnd(mu,Sigma,1);
        
        Xi=[x1 x2 xi];
        
        X=[X;Xi];
        
        % generate treatment
      
        if i <= (N/2) Ai=1;
        else Ai=-1;
        end;
            
        A=[A;Ai];
        
        e=normrnd(0,1);
        
        if (set == 1)
            T = 1 - Xi(3) + 2*Xi(4) - Xi(13) + Xi(14) + 2*Xi(17);
        end;
        
        if (set == 2)
            T = 1+Xi(3)+2*Xi(4)+Xi(13)-Xi(14)^2+Xi(17)^2;
        end;
        
        if (set == 3)
            T = 1+Xi(3)+2*Xi(4)-Xi(5)^2+Xi(13)-Xi(14)+2*Xi(17)^2+2*Xi(18)^2;
        end;
        
        if (set == 4)
            T = 1+Xi(3)+0.5*Xi(4)-Xi(5)^2+Xi(13)-0.5*Xi(14)+0.5*Xi(17)^2;
        end;
        
        if (set == 5)
            T = 1+Xi(3)+0.5*Xi(4)-Xi(5)^2+Xi(13)-0.5*Xi(14)+0.5*Xi(17)^2;
         end;   
        
         if (set == 6)
            T = 1 - exp(Xi(3)) - Xi(4) + exp(Xi(13)) + Xi(14);
         end;  
        
        
        Yi = 1+x1+2*Xi(3)-Xi(13)+T*Ai+e;
        
        Y = [Y; Yi];

        
    end;  % end of subject;
    
[~,~,Res]=regress(Y,X);