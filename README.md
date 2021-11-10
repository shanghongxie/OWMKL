# Matlab toolbox for Outcome Weighted Multiple Kernel Learning (OWMKL)

<img src="https://img.shields.io/badge/Study%20Status-Results%20Available-yellow.svg" alt="Study Status: Results Available"> 

- Authors: **Shanghong Xie<sup>a</sup> (sx2168@columbia.edu), Thaddeus Tarpey <sup>b</sup>, Eva Petkova <sup>b</sup>, and R. Todd Ogden <sup>a</sup>**
- Affiliations: 
  + 1. **Department of Biostatistics, Mailman School of Public Health, Columbia University, New York**
  + 2. **Division of Biostatistics, Department of Population Health, New York University, New York**
  
  
## Setup Requirements
- Matlab 
- Download all the Matlab scripts (.m) in Code folder and put them in the same directory. 
- Some scripts were modified based on SimpleMKL Toolbox (http://asi.insa-rouen.fr/enseignants/~arakoto/code/mklindex.html)

## Code Instructions

Main scripts:

simulation_vignette.m: examples of conducting simulation studies using OWMKL, AOL, and OWL.

simulation_generate_data.m: function to generate simulated data sets

owmkl.m: function to implement OWMKL , tuning parameters are chosen by n-fold cross-validation

aol.m: function to implement AOL, tuning parameters are chosen by n-fold cross-validation

owl.m: function to implement OWL, tuning parameters are chosen by n-fold cross-validation

