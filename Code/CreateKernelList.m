function [kernelcellaux,kerneloptioncellaux,variablecellaux]=CreateKernelList(variablecell,kernelcell,kerneloptioncell)

% for each type of data, using different kernels
%input:
% variablecell: indicate which variable is used
% dims: number of variables in each data type
% kernelcell: kernel function type (gaussian, poly)
% kerneloptioncell: parameter in kernel function

%output:
%kernelcellaux: kernel type
%kerneloptioncellaux: kernel parameters
%variablecellaux: variable type


j=1;
for i=1:length(variablecell) % length(variablecell): the number of data types
            kernelcellaux{j}=kernelcell{i};
            kerneloptioncellaux{j}=kerneloptioncell{i};
            variablecellaux{j}=variablecell{i};
            j=j+1;    
     
end;
