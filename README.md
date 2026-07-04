# Image_extraction_2DGMM
Python and R scripts for the manuscript "A semi-automated method for data extraction and high-density 2D geometric morphometrics of archaeological and heritage artefacts"

This repository contains data and scripts used in the manuscript:

Watt, E. C.; Box, M.; Archer-Parré, C.; Pawlikowski, M.; Carey, A.-M.; Martinón-Torres, M. (Submitted) A semi-automated method for data extraction and high-density 2D geometric morphometrics of archaeological and heritage artefacts.

# Included in this repository
## Python folder
### Juypter notebook script "Image_prep_contour_extraction.ipynb" containing the following stages:
1. Standardise the DPI of the input images (if required) - can also done manually in image processing software, such as Inkscape
2. Extract single-object images from multi-object images (e.g., single letters from a page of text) - skip if your dataset is a single object per image
3. Optical Characters Recognition (OCR) sorting of individual character images into discrete folders - skip if your datasset is not text-based
4. Manual sorting using Graphic User Interface (GUI) - skip if no further sorting required, or your dataset is not text-based
5. Binarise the individual character images and fill internal holes within the contours
6. Transform the images (if required)
7. Extract the contours of the objects in the images and save the coordinates as a .csv file

### Test data to run this script:
Two folders, one with a sample photograph (unedited) and the second with manual edits as described in the manuscript, ready for input into the .ipynb script

## R folder
### R script "Rscript_2DGMM.R" containing the following stages:
1. Clean code for GPA, PCA, and disparity analysis
2. Code to reproduce Figure 3 (PCA and disparity of Baskerville RLC m)
3. Code to reproduce Figure 4 (PCA of Baskerville RLC n and RLC u)
4. Code to reproduce Figure 5 (PCA and disparity of Baskerville and Caslon ILC r)
   
### Data to reproduce Figures 3-5 and S1-S2
1. Fig 3 RLC m HbVCpSsVpHgu coords.csv (includes data for Figure S1)
2. Fig 3 RLC m HbVCpSsVpHgu size_info.csv (includes data for Figure S1)
3. Fig 4 RLC n+u V coords.csv
4. Fig 5 ILC r CaslonSs coords.csv (includes data for Figure S2)
5. Fig 5 ILC r CaslonSs size_info.csv (includes data for Figure S2)
   
# License
CC-BY 4.0
