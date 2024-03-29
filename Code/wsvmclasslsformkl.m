function [xsup,w,b,pos,alpha,status,cost]=wsvmclassLSformkl(x,y,Rweight, c,lambda,kernel,kerneloption,verbose,span,qpsize,chunksize,alphainit)


%
% [xsup,w,b,pos,timeps,alpha,status,cost]]=svmclassLS(x,y,c,lambda,kernel,kerneloption,verbose,span,qpsize,chunksize)
%
% %
% %   large-scale classification svm
% %


%dbstop if warning
if nargin<12
    alphainit=[];
end;
if nargin < 11
    chunksize=100;
end;
if nargin<10
    qpsize=100;
end;
maxqpsize=qpsize;
if nargin < 11
    % even number
    chunksize=qpsize;
end;
if isstruct(x)
    if length(x.indice)~=length(y)
        error('Length of x and y should be equal');
    end;
end

n=size(y,1);
kkttol=1e-3;
difftol=1e-10;
notchangedmax=5;
status=1;
C=c*Rweight;

if isempty(alphainit)
    alphaold=zeros(n,1);
    alpha=zeros(n,1);
else
    alpha=alphainit;
end;

workingset=zeros(n,1);
nws=zeros(n,1);

class1=(y>=0);
class0=(y<0);
iteration=0;
bias=0;

notchanged=0;



%keyboard

while 1




    %
    %   calcul des indices des SV et non SV
    %

   % SVbound=(alpha>=c-difftol);
   % add sample weight on c;
    SVbound=(alpha>=C-difftol);

    SV=(abs(alpha)>=difftol);

    SVnonbound= (~SVbound & SV);


    %
    %    Calcul de la sortie du SVM
    %

    if iteration==0  ;
        changedSV=find(SV);
        changedAlpha=alpha(changedSV);
        s=zeros(n,1);

    else
        changedSV=find( abs(alpha-alphaold)> difftol );
        changedAlpha=alpha(changedSV)-alphaold(changedSV);
    end;

    if ~isempty(changedSV)

        chunks1=ceil(n/chunksize);
        chunks2=ceil(length(changedSV)/chunksize);

        for ch1=1:chunks1
            %fprintf('%d sur %d\n',ch1,chunks1) ;
            ind1=(1+(ch1-1)*chunksize) : min( n, ch1*chunksize);
            for ch2=1:chunks2
                ind2=(1+(ch2-1)*chunksize) : min(length(changedSV), ch2*chunksize);


                %-------------------------------------------------------
                % c'est ici qu'on calcule la matrice
                %-------------------------------------------------------

                if isfield(kerneloption,'matrix')
                    kchunk=kerneloption.matrix(ind1,changedSV(ind2));
                else
                    kchunk=sumKbetals(kerneloption,kerneloption.sigma,ind1,changedSV(ind2));

                end;



                %-----------------------------------------------------------
                %kchunk=svmkernel(x(ind1,:),kernel,kerneloption,x(changedSV(ind2),:));
                %-----------------------------------------------------------
                coeff=changedAlpha(ind2).*y(changedSV(ind2));

                s(ind1)=s(ind1)+ kchunk*coeff;
            end;
        end

    end;

    %
    %  calcul du biais du SVM que sur l'ensemble du working set et
    %  SVnonbound

    indworkingSVnonbound= find(SVnonbound& workingset);
    if ~isempty(indworkingSVnonbound)
        bias= mean( y(indworkingSVnonbound)-s(indworkingSVnonbound) );
    end;



    %
    %  KKT Conditions
    %

    kkt=(s+bias).*y - 1;
    kktviolation=   (SVnonbound & ( abs(kkt)>kkttol) )|( ~SV & (kkt < -kkttol)) | ( SVbound & (kkt > kkttol));

    if sum(kktviolation)==0
        break;   %  c'est fini tout
    end;



    %
    %   Calcul du nouveau working set
    %

    if iteration==0
        searchdir=rand(n,1);
        set1=class1;
        set2=class0;

    else
        searchdir=s-y;
        set1 = (SV |class0) & (~SVbound |class1);
        set2= (SV |class1) & (~SVbound |class0);
    end;



    oldworkingset=workingset;
    workingset=zeros(n,1);
    n1=sum(set1);
    n2=sum(set2);
    if n1+n2 <= qpsize
        aux=find( set1 |set2);
        workingset(aux)=ones(length(aux),1);
        %workingset(find( set1 |set2))=ones(n1+n2,1);
    elseif n1 <=floor(qpsize)/2

        workingset(find(set1))=ones(n1,1);
        set2= set2 &~workingset;
        n2=sum(set2);
        [aux,ind]=sort(searchdir(set2));
        from2=min(n2,qpsize-n1);
        aux=find(set2);
        workingset(aux(1:from2))=ones(from2,1);
    elseif n2 <=floor(qpsize)/2

        workingset(find(set2))=ones(n2,1);
        set1= set1 &~workingset;
        n1=sum(set1);
        [aux,ind]=sort(-searchdir(set1));
        from1=min(n1,qpsize-n2);
        aux=find(set1);
        workingset(aux(1:from1))=ones(from1,1);
    else

        set1=find(set1);
        [aux,ind]=sort(-searchdir(set1));
        from1=min(length(set1),qpsize/2);
        workingset(set1(ind(1:from1)))=ones(from1,1);
        set2=find(set2 & ~workingset);
        [aux,ind]=sort(searchdir(set2));
        from2=min(length(set2),qpsize-sum(workingset));
        workingset(set2(ind(1:from2)))=ones(from2,1);
    end;

    if all(workingset==oldworkingset)
        %  fprintf('Not changed \n');

        indpos=find(y==1);
        indneg=find(y==-1);
        RandIndpos=randperm(length(indpos));
        RandIndneg=randperm(length(indneg));
        nbpos=min(length(indpos),round(qpsize/2));
        nbneg=min(length(indneg),round(qpsize/2));
        ind=[indpos(RandIndpos(1:nbpos));indneg(RandIndneg(1:nbneg))];
        workingset(ind)=ones(length(ind),1);



    end;
    indworkingset=find(workingset);
    workingsize=length(indworkingset);
    nws=~workingset;
    indnws= find(nws);


    %
    %   Resolution du QP probleme sur le nouveau Working set
    %

    % le calcul de Qbn*alphan ne fait intervenir que les données aux alphan non nulles et les données de la working
    % set


    nwSV= (nws & SV);
    indnwSV=find(nwSV);
    Qbnalphan=0;
    if length(indnwSV)>0

        chunks=ceil(length(indnwSV)/chunksize);
        for ch=1:chunks
            ind=(1+(ch-1)*chunksize ): min( length(indnwSV), ch*chunksize);

            %-------------------------------------------------------
            % c'est ici qu'on calcule la matrice
            %-------------------------------------------------------

            % pschunk=kerneloption.matrix(indworkingset,indnwSV(ind));


            if isfield(kerneloption,'matrix')
                pschunk=kerneloption.matrix(indworkingset,indnwSV(ind));
            else


                pschunk=sumKbetals(kerneloption,kerneloption.sigma,indworkingset,indnwSV(ind));

            end;



            %-----------------------------------------------------------
            % pschunk=svmkernel(x(indworkingset,:),kernel,kerneloption,x(indnwSV(ind),:));
            %-----------------------------------------------------------



            Qbnalphan=Qbnalphan + y(indworkingset).*(pschunk*(alpha(indnwSV(ind)).*y(indnwSV(ind))));
        end;
        e= - (Qbnalphan - ones(workingsize,1));

    else
        e=ones(workingsize,1);
    end;

    %-------------------------------------------------------
    % c'est ici qu'on calcule la matrice
    %-------------------------------------------------------
    % psbb=kerneloption.matrix(indworkingset,indworkingset);

    if isfield(kerneloption,'matrix')
        psbb=kerneloption.matrix(indworkingset,indworkingset);
    else


        psbb=sumKbetals(kerneloption,kerneloption.sigma,indworkingset,indworkingset);

    end;


    yb=y(indworkingset);
    A=yb;
    if length(indnws)>0
        b=-alpha(indnws)'*y(indnws);
    else
        b=0;
    end;
    
    [alphab,lambdab,pos]=monqp(psbb.*(yb*yb'),e,A,b,C,lambda,0);%,psbb);

    alphaold=alpha;
    aux=zeros(workingsize,1);
    aux(pos)=alphab;
    alpha(indworkingset)=aux;
    iteration=iteration+1;


    if length(find( abs(alpha-alphaold)> difftol))==0
        notchanged=notchanged+1;
        if notchanged>notchangedmax
            fprintf('Optimization  not successfull\n');
            status=0;
            break;

        end;
    else
        notchanged=0;
    end;

    if verbose >0
        obj= 0.5*aux'*(psbb.*(yb*yb'))*aux- aux'*e;
        fprintf('i: %d number changedAlpha : %d  Nb KKT Violation: %d Objective Val:%f\n',iteration,length(find( abs(alpha-alphaold)> difftol)),sum(kktviolation),obj);
    end;
    if sum(kktviolation) < maxqpsize
        qpsize=maxqpsize;
        chunksize=maxqpsize;
    end;
end;

% SVbound=(alpha>=c);
% SV=(alpha ~=0);
% SVnonbound= (~SVbound & SV);

SVbound=(alpha>=C-difftol);
SV=(abs(alpha)>=difftol);
SVnonbound= (~SVbound & SV);

pos=find(alpha ~=0);


if ~isempty(x)
    if ~isfield(x,'datafile')
        xsup = x(pos,:);
    else
        xsup=x;
        xsup.indice=x.indice(pos);
    end;
else
    xsup=[];
end;
ysup = y(pos);
w = (alpha(pos).*ysup);

indworkingSVnonbound= find(SVnonbound& workingset);
if ~isempty(indworkingSVnonbound)
    bias= mean( y(indworkingSVnonbound)-s(indworkingSVnonbound) );
end;
b = bias;
alpha=alpha(pos);

% s= K*alpha(pos)

cost= -0.5*w'*s(pos) + sum(alpha);

