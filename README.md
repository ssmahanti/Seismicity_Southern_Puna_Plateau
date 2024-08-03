## Introduction:

This repository contains the codes and scripts used in the study "Seismicity and Present-Day Crustal Deformation in the Southern Puna Plateau". The primary analysis in this study is done usng codes from previous works and those codes need to be retrieved from the original studies. The references for repositories of the source codes are listed below. 

The codes and scripts included in this repository are primarily for format conversion, result analysis, and plotting figures. Each folder has its own readme file explaining the steps to reproduce the results. Due to space constraints, raw data files (mseed or SAC) are not kept in the repository.

The general workflow follows as:

1. PhaseNet --> REAL --> Velest --> magnitude --> HypoDD: Earthquake catalog with 1D velocity model (following LOC_FLOW)
2. Velest --> LOTOS: Local earthquake tomography.
3. HypoDD --> FOCMEC --> Stress_inversion: Focal mechanism and stress inversion.

## References:

1. Zhu, W., & Beroza, G. C. (2019). PhaseNet: A deep-neural-network-based seismic arrival-time picking method. Geophysical Journal International, 216(1), 261–273. https://doi.org/10.1093/gji/ggy423
2. Zhang, M., Liu, M., Feng, T., Wang, R., & Zhu, W. (2022). LOC-FLOW: An End-to-End Machine Learning-Based High-Precision Earthquake Location Workflow. Seismological Research Letters, 93(5), 2426–2438. https://doi.org/10.1785/0220220019
3. Zhang, M., Ellsworth, W. L., & Beroza, G. C. (2019). Rapid Earthquake Association and Location. Seismological Research Letters, 90(6), 2276–2284. https://doi.org/10.1785/0220190052 
4. Kissling, E., Ellsworth, W. L., Eberhart-Phillips, D., & Kradolfer, U. (1994). Initial reference models in local earthquake tomography. Journal of Geophysical Research: Solid Earth, 99(B10), 19635–19646. https://doi.org/10.1029/93JB03138
5. Waldhauser, F., & Ellsworth, W. (2000). A Double-Difference Earthquake Location Algorithm: Method and Application to the Northern Hayward Fault, California. Bulletin of the Seismological Society of America, 90(6), 1353–1368. https://doi.org/10.1785/0120000006
6. Koulakov, I. (2009). LOTOS Code for Local Earthquake Tomographic Inversion: Benchmarks for Testing Tomographic Algorithms. Bulletin of the Seismological Society of America, 99(1), 194–214. https://doi.org/10.1785/0120080013
7. Vavryčuk, V. (2014). Iterative joint inversion for stress and fault orientations from focal mechanisms. Geophysical Journal International, 199(1), 69–77. https://doi.org/10.1093/gji/ggu224
8. Snoke, J. A. (2003). 85.12 FOCMEC: FOCal MEChanism determinations (pp. 1629–1630). https://doi.org/10.1016/S0074-6142(03)80291-7

## Author:

Sankha Subhra Mahanti, The University of Arizona, ssmahanti@arizona.edu
