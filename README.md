# Matlab toolbox for Outcome Weighted Multiple Kernel Learning (OWMKL)

<img src="https://img.shields.io/badge/Study%20Status-Results%20Available-yellow.svg" alt="Study Status: Results Available"> 

Individualized treatment rules (ITRs) recommend treatments that are tailored specifically according to each patient’s own characteristics. It can be challenging to estimate optimal ITRs when there are many features, especially when these features have arisen from multiple data domains (e.g., demographics, clinical measurements, neuroimaging modalities). Considering data from complementary domains and using multiple similarity measures to capture the potential complex relationship between features and treatment can potentially improve the accuracy of assigning treatments. Outcome weighted learning (OWL) methods that are based on support vector machines using a predetermined single kernel function have previously been developed to estimate optimal ITRs. In this article, we propose an approach to estimate optimal ITRs by exploiting multiple kernel functions to describe the similarity of features between subjects both within and across data domains within the OWL framework, as opposed to preselecting a single kernel function to be used for all features for all domains. Our method takes into account the heterogeneity of each data domain and combines multiple data domains optimally. Our learning process estimates optimal ITRs and also identifies the data domains that are most important for determining ITRs. This approach can thus be used to prioritize the collection of data from multiple domains, potentially reducing cost without sacrificing accuracy. The comparative advantage of our method is demonstrated by simulation studies and by an application to a randomized clinical trial for major depressive disorder that collected features from multiple data domains. 


- Authors: **Shanghong Xie<sup>a,b</sup> (sx2168@columbia.edu), Thaddeus Tarpey <sup>c</sup>, Eva Petkova <sup>c</sup>, and R. Todd Ogden <sup>b</sup>**
- Affiliations:
  + 1. **School of Statistics, Southwestern University of Finance and Economics, Chengdu**
  + 2. **Department of Biostatistics, Mailman School of Public Health, Columbia University, New York**
  + 3. **Division of Biostatistics, Department of Population Health, New York University, New York**
       
- Manuscript: Xie S, Tarpey T, Petkova E and Ogden RT (2022). [Multiple Domain and Multiple Kernel Outcome-Weighted Learning for Estimating Individualized Treatment Regimes.](https://github.com/shanghongxie/INL) Jounral of Computational and Graphical Statistics 31(4), 1375-1383.   
  
## Setup Requirements
- Matlab 
- Download all the Matlab scripts (.m) in Code folder and put them in the same directory. 
- Some scripts were modified based on SimpleMKL Toolbox (http://asi.insa-rouen.fr/enseignants/~arakoto/code/mklindex.html)

## Code Instructions

### Main scripts

- **owmkl.m**: function to implement OWMKL , tuning parameters are chosen by n-fold cross-validation

- **simulation_vignette.m**: examples of conducting simulation studies using OWMKL, AOL, and OWL.

- **simulation_generate_data.m**: function to generate simulated data sets

### Comparison methods
- **aol.m**: function to implement AOL, tuning parameters are chosen by n-fold cross-validation

- **owl.m**: function to implement OWL, tuning parameters are chosen by n-fold cross-validation

