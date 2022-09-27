# Data-Driven Global Sensitivity Analysis for Distribution System With PVs

**`Under Development`**

Code for the paper: [A Data-Driven Global Sensitivity Analysis Framework for Three-Phase Distribution System With PVs](https://ieeexplore.ieee.org/document/9387134)  


## Requriements

[OpenDSS](https://www.epri.com/pages/sa/opendss#:~:text=What%20is%20OpenDSS%3F,grid%20integration%20and%20grid%20modernization.)  

[UQLab](https://www.uqlab.com/)

## References

[ANOVA-kernels](https://github.com/NicolasDurrande/ANOVA-kernels)  

[1] Durrande, N., Ginsbourger, D., Roustant, O. and Carraro, L., 2013. ANOVA kernels and RKHS of zero mean functions for model-based sensitivity analysis. Journal of Multivariate Analysis, 115, pp.57-67.


## Case IEEE-37
System: IEEE-37 bus with PVs  
X: loads at nodes 731b,733a,735c & PVs at nodes 731b, 733a, 735c  
Y: total Sobol indices  
Model: Monte Carlo, polynomial chaos expansion, Gaussian process regression (Kriging)


### Demo

<div align=center>
<img src="./plot/V731a.jpg" alt="V731a" width="250">
<img src="./plot/V731b.jpg" alt="V731b" width="250">
<img src="./plot/V731c.jpg" alt="V731c" width="250">
</div>

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;


