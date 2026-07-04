# Image_extraction_2DGMM
Python and R scripts for the manuscript "A semi-automated method for data extraction and high-density 2D geometric morphometrics of archaeological and heritage artefacts"

This repository contains data and scripts used in the manuscript:

Watt, E. C.; Box, M.; Archer-Parré, C.; Pawlikowski, M.; Carey, A.-M.; Martinón-Torres, M. (Submitted) A semi-automated method for data extraction and high-density 2D geometric morphometrics of archaeological and heritage artefacts.

# Included in this repository
## Python folder
1. Juypter notebook script "Image_prep_contour_extraction.ipynb" containing the following stages:
     a. Standardise the DPI of the input images (if required) - can also done manually in image processing software, such as Inkscape
     b. Extract single-object images from multi-object images (e.g., single letters from a page of text) - skip if your dataset is a single object per image
     c. Optical Characters Recognition (OCR) sorting of individual character images into discrete folders - skip if your datasset is not text-based
     d. Manual sorting using Graphic User Interface (GUI) - skip if no further sorting required, or your dataset is not text-based
     e. Binarise the individual character images and fill internal holes within the contours
     f. Transform the images (if required)
     g. Extract the contours of the objects in the images and save the coordinates as a .csv file
2. Test data to run this script, in the form of two folders, one with a sample photograph (unedited) and the second with manual edits as described in the manuscript, ready for input into the .ipynb script

## R folder
1. R script "Rscript_2DGMM.R" containing the following stages:
     a. Clean code for GPA, PCA, and disparity analysis
     b. Code to reproduce Figure 3 (PCA and disparity of Baskerville RLC m)
     c. Code to reproduce Figure 4 (PCA of Baskerville RLC n and RLC u)
     d. Code to reproduce Figure 5 (PCA and disparity of Baskerville and Caslon ILC r)
2. Data to reproduce Figures 3-5 and S1-S2
     a. Fig 3 RLC m HbVCpSsVpHgu coords.csv (includes data for Figure S1)
     b. Fig 3 RLC m HbVCpSsVpHgu size_info.csv (includes data for Figure S1)
     c. Fig 4 RLC n+u V coords.csv
     d. Fig 5 ILC r CaslonSs coords.csv (includes data for Figure S2)
     e. Fig 5 ILC r CaslonSs size_info.csv (includes data for Figure S2)
   
# License
CC-BY 4.0
