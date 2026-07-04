################################################################################
###Code for: "A semi-automated method for data extraction and high-density 2D 
###           geometric morphometrics of archaeological and heritage artefacts"
###Written by: Emily C. Watt
###Date last modified: July 2026
###Written in R version: 4.5.2
################################################################################

###In this script:
###     1. Clean code for GPA, PCA, and disparity analysis
###     2. Code to reproduce Figure 3 (PCA and disparity of Baskerville RLC m)
###     3. Code to reproduce Figure 4 (PCA of Baskerville RLC n and RLC u)
###     4. Code to reproduce Figure 5 (PCA and disparity of Baskerville and Caslon ILC r)

#Note that in an effort to ensure this script is useable by those with no prior coding
#knowledge, for the avoidance of doubt, if an example is being used that in normal text would be
#placed in "", we have placed in {} here, as "" are often found in the same lines of code

#GPA = Generalised Procrustes Analysis
#PCA = Principal Component Analysis

################################################################################

### 1. Clean code for GPA, PCA, and disparity analysis

#load packages
library(tidyverse)
library(geomorph)
library(plotly)
library(dispRity)

#set working directory
setwd("C:/working/directory/filepath") #amend here by pasting in the full file path where your data files are located

#initiate random number generation
set.seed(123)

#load dataset (generated using Python script)
#NB: {./} means "look in the working directory folder" for the named file
data <- read.csv("./coords.csv", header = TRUE) #amend {data.csv} to the name of your data csv file

#load the metadata
#Note that if there is no extra information (e.g., point size), follow the * to make the necessary amendments
# *if no metadata, skip this step
size_info <- read.csv("./size_info.csv", stringsAsFactors = FALSE) #amend {size_info} to the name of your metadata csv file

#merge size info into main data by filename
# *if no metadata, skip this step
data <- data %>% #this will overwrite the data object
  left_join(size_info, by = "filename")

#count per column variable to get n=
#change {source} to any other variable from metadata, e.g., point_size
data |>
  count(source)

#prepare data for GPA
#create coodinate matrix, removing everything but the coordinates
#amend {%in% c("filename", "source", "point_size")} to include any other named columns other than the coordinates
coords <- as.matrix(data[ , !(names(data) %in% c("filename", "source", "point_size")) ])
#add back in the filenames as rownames
rownames(coords) <- data$filename

#define the number of landmarks
n_landmarks <- ncol(coords) / 2

#define which landmarks are sliding, here all but the first landmark
sliders <- rbind(define.sliders(c(1:n_landmarks, 1), write.file = FALSE))

#convert to geomorph array
coords_array <- geomorph::arrayspecs(coords, p = n_landmarks, k = 2) #k is the number of dimensions, this is a 2D analysis so k=2

#run GPA
gpa <- geomorph::gpagen(coords_array, curves = sliders, ProcD = FALSE, print.progress = TRUE)

#save R environment (helpful if GPA took a long time to run)
#(remove the # to run the line of code, this changes it from a comment to an executable line of code)
#save.image(file="./GPA.RData")
#reload at a later date with:
#load("./GPA.RData")

#run PCA
pca <- geomorph::gm.prcomp(gpa$coords)

#save R environment
#save.image(file="./PCA.RData")
#reload at a later date with:
#load("./PCA.RData")

#create PCA dataframe with metadata
# *if no (or different) metadata, amend this step
# *in the line {left_join}, change {select()} to only include values present in the data and metadata files
# *e.g., {select(filename), by = "filename")} if no source or point_size information
pca_scores <- as.data.frame(pca$x) %>% 
  rownames_to_column("filename") %>%
  left_join(data %>% select(filename, source, point_size), by = "filename") #add metadata columns from original data object, joined by filename

#find the variance explained by each PCA axis
prop_var <- pca$sdev^2 / sum(pca$sdev^2)

#plotting PCA
#set colours for plotting
#example of list structure below, colours can be named (e.g., "blue") or defined by hex value (e.g., "#CD9600")
cols <- c("Specimen sheets"="#FF61CC", 
          "Virgil proposal"="#00BE67", 
          "Virgil"="#00BFC4", 
          "Book of Common Prayer"="#00A9FF", 
          "Holy Bible"="#A58AFF", 
          "Hunter Gravid Uterus"="#CD9600") 

#graph parameters
flatplot <- ggplot(pca_scores, aes(x = Comp1, y = Comp2, text=filename)) + #change the PCA axes being plotted by changing x and y
  geom_point(alpha = 1, cex=7, pch = 21, aes(fill=source)) + #fill by a variable, e.g. source or point_size
  scale_fill_manual(values = c(cols)) +
  theme_minimal() +
  #facet_wrap(~source) + #this splits the plot by the specified variable
  labs(#title = "PCA", #add title if desired
    #add the PCA axis labels
    #here the number of decimal places is set to 1, this could be increased if desired
    x = paste0("PC1 (", round(prop_var[1] * 100, 1), "%)"), #if plotting axes other than 1&2, here change prop_var[] to match
    y = paste0("PC2 (", round(prop_var[2] * 100, 1), "%)"))
#plot the PCA
flatplot

#make the plot interactive such that hovering over each point will display information on it
#the information is controlled by the {text=} in the above plotting parameters
#e.g. {text=filename} will display the filename of each point when hovered over, whereas
#{text=point_size} will display the point size
interactive_plot <- plotly::ggplotly(flatplot)
#plot the interactive PCA
interactive_plot

#prepare for disparity per group analysis
#create a list of the grouping variables
#below is an example of the source being used as the grouping variable
list_source <- list("Specimen sheets"=which(grepl("Specimen", pca_scores$source)),
                           "1754_Virgil_proposal" = which(grepl("proposal", pca_scores$source)),
                           "1757_Virgil" = which(grepl("Virgil", pca_scores$source)),
                           "1762_Book of Common Prayer" = which(grepl("Prayer", pca_scores$source)),
                           "1763_Holy Bible" = which(grepl("Bible", pca_scores$source)),
                           "1774_Hunter_Gravid_Uterus" = which(grepl("Hunter", pca_scores$source)))

#create matrix of PCA output
output_res <- as.matrix(pca$x)

#run disparity per group
groups_disparity <- dispRity::dispRity.per.group(output_res, list_source)

#summarise disparity per group
summary(groups_disparity)
#plot disparity
plot(groups_disparity, col=cols) #cols are same as for the PCA


################################################################################

###     2. Code to reproduce Figure 3 (PCA and disparity of Baskerville RLC m)

#Note that this code will produce both Figure 3 from the main text and Supplementary Figure 1
#To create the supplementary figure, code alterations are noted with ***

library(tidyverse)
library(geomorph)
library(plotly)
library(dispRity)
library(ggforce)

setwd("C:/")
set.seed(123)
data_2 <- read.csv("./Fig 3 RLC m HbVCpSsVpHgu coords.csv", header = TRUE)
size_info_2 <- read.csv("./Fig 3 RLC m HbVCpSsVpHgu size_info.csv", stringsAsFactors = FALSE)
data_2 <- data_2 %>% 
  left_join(size_info_2, by = "filename")
data_2 |>
  count(source)

coords_2 <- as.matrix(data_2[ , !(names(data_2) %in% c("filename", "source", "point_size")) ])
rownames(coords_2) <- data_2$filename
n_landmarks_2 <- ncol(coords_2) / 2
sliders_2 <- rbind(define.sliders(c(1:n_landmarks_2, 1), write.file = FALSE))
coords_array_2 <- geomorph::arrayspecs(coords_2, p = n_landmarks_2, k = 2)

gpa_2 <- geomorph::gpagen(coords_array_2, curves = sliders_2, ProcD = FALSE, print.progress = TRUE)
pca_2 <- geomorph::gm.prcomp(gpa_2$coords)

pca_scores_2 <- as.data.frame(pca_2$x) %>% 
  rownames_to_column("filename") %>%
  left_join(data_2 %>% select(filename, source, point_size), by = "filename")

prop_var_2 <- pca_2$sdev^2 / sum(pca_2$sdev^2)

cols_2 <- c("Specimen sheets"="#c6d5b1", #date range: 1757-1775
          "Virgil proposal"="#5fc0a4", #date:1754
          "Virgil"="#efc35a", #date:1757
          "Book of Common Prayer"="#570407", #date:1762
          "Holy Bible"="#fc951d", #date:1763
          "Hunter Gravid Uterus"="#1e798a") #date:1774

# ***
#Note: to create Supplementary Figure 1, change x and y to PC3 and PC4 (x = Comp3, y = Comp4) and prop_var_2[] to match (prop_var_2[3] and prop_var_2[4])
# ***

full_plot_2 <- ggplot(pca_scores_2, aes(x = Comp1, y = Comp2, text=filename)) +
  geom_point(data = filter(pca_scores_2, source == "Hunter Gravid Uterus"), alpha = 1, cex=7, pch = 21, aes(fill=source)) +
  geom_point(data = filter(pca_scores_2, source == "Virgil"), alpha = 1, cex=7, pch = 21, aes(fill=source)) +
  geom_point(data = filter(pca_scores_2, source == "Holy Bible"), alpha = 1, cex=7, pch = 21, aes(fill=source)) +
  geom_point(data = filter(pca_scores_2, source == "Book of Common Prayer"), alpha = 1, cex=7, pch = 21, aes(fill=source)) +
  geom_point(data = filter(pca_scores_2, source == "Specimen sheets"), alpha = 1, cex=7, pch = 21, aes(fill=source)) +
  geom_point(data = filter(pca_scores_2, source == "Virgil proposal"), alpha = 1, cex=7, pch = 21, aes(fill=source)) +
  scale_fill_manual(values = c(cols_2)) +
theme_minimal() +
  labs(
    x = paste0("PC1 (", round(prop_var_2[1] * 100, 1), "%)"),
    y = paste0("PC2 (", round(prop_var_2[2] * 100, 1), "%)"))
full_plot_2

# ***
#Note: to create Supplementary Figure 1, change x and y to PC3 and PC4 (x = Comp3, y = Comp4) and prop_var_2[] to match (prop_var_2[3] and prop_var_2[4])
# ***

split_plot_2 <- ggplot(pca_scores_2, aes(x = Comp1, y = Comp2, text=filename)) +
  geom_point(alpha = 1, cex=7, pch = 21, aes(fill=source)) +
  scale_fill_manual(values = c(cols_2)) +
theme_minimal() +
  facet_wrap(~source, ncol=2) +
  labs(
    x = paste0("PC1 (", round(prop_var_2[1] * 100, 1), "%)"),
    y = paste0("PC2 (", round(prop_var_2[2] * 100, 1), "%)"))
split_plot_2

# ***
#Note: to create Supplementary Figure 1, change x and y to PC3 and PC4 (x = Comp3, y = Comp4) and prop_var_2[] to match (prop_var_2[3] and prop_var_2[4])
# ***

individual_plot_2 <- ggplot(pca_scores_2, aes(x = Comp1, y = Comp2, text=filename)) +
  geom_point(alpha = 1, cex=7, pch = 21, aes(fill=source)) +
  scale_fill_manual(values = c(cols_2)) +
  theme_minimal() +
  ggforce::facet_wrap_paginate(~source, nrow=1, ncol=1, page=6)+ #change {page=} to change the source plotted (here n=6)
  labs(
    x = paste0("PC1 (", round(prop_var_2[1] * 100, 1), "%)"),
    y = paste0("PC2 (", round(prop_var_2[2] * 100, 1), "%)"))
individual_plot_2

list_source_2 <- list("Type specimen sheets"=which(grepl("Specimen", pca_scores_2$source)),
                           "1754_Virgil_proposal" = which(grepl("proposal", pca_scores_2$source)),
                           "1757_Virgil" = which(grepl("Virgil", pca_scores_2$source)),
                           "1762_Book of Common Prayer" = which(grepl("Prayer", pca_scores_2$source)),
                           "1763_Holy Bible" = which(grepl("Bible", pca_scores_2$source)),
                           "1774_Hunter_Gravid_Uterus" = which(grepl("Hunter", pca_scores_2$source)))
output_res_2 <- as.matrix(pca_2$x)

groups_disparity_2 <- dispRity.per.group(output_res_2, list_source_2)
plot(groups_disparity_2, col=cols_2)

################################################################################

###     3. Code to reproduce Figure 4 (PCA of Baskerville RLC n and RLC u)

#Note that you need to ensure that you transform one folder of images prior to extracting the coordinates
#this is because the first coordinate in the coordinate string is used as the anchor for GPA
#and is the only pseudolandmark that doesn't slide, so the input images first must be in the same orientation. 
#Use the 'transform.py' before running the 'extract_coordinates.py'

#Here I rotated the RLC u images 180 degrees, but the transformation could be applied to either character.

library(tidyverse)
library(geomorph)

setwd("C:/")
set.seed(123)
data_3 <- read.csv("./Fig 4 RLC n+u V coords.csv", header = TRUE)

coords_3 <- as.matrix(data_3[ , !(names(data_3) %in% c("filename")) ])
rownames(coords_3) <- data_3$filename
n_landmarks_3 <- ncol(coords_3) / 2
sliders_3 <- rbind(define.sliders(c(1:n_landmarks_3, 1), write.file = FALSE))
coords_array_3 <- geomorph::arrayspecs(coords_3, p = n_landmarks_3, k = 2)

gpa_3 <- geomorph::gpagen(coords_array_3, curves = sliders_3, ProcD = FALSE, print.progress = TRUE)
pca_3 <- geomorph::gm.prcomp(gpa_3$coords)

#here add in an extra column to distinguish RLC n and RLC u characters
pca_scores_3 <- as.data.frame(pca_3$x) %>% 
  rownames_to_column("filename") %>%
  mutate(letter = case_when(
    str_detect(filename, "RLC n") ~ "RLC n",
    str_detect(filename, "RLC_n") ~ "RLC n",
    str_detect(filename, "RLC u") ~ "RLC u",
    str_detect(filename, "RLC_u") ~ "RLC u",
    TRUE ~ NA_character_
  )) %>%
  left_join(data_3 %>% select(filename), by = "filename")

prop_var_3 <- pca_3$sdev^2 / sum(pca_3$sdev^2)

cols_3 <- c("RLC n"="#efc35a",
          "RLC u"="#1e798a")
full_plot_3 <- ggplot(pca_scores_3, aes(x = Comp1, y = Comp2, text=filename)) +
  geom_point(alpha = 1, cex=7, pch = 21, aes(fill=letter)) + #colour by letter character
  scale_fill_manual(values = c(cols_3)) +
  theme_minimal() +
  labs(
    x = paste0("PC1 (", round(prop_var_3[1] * 100, 1), "%)"),
    y = paste0("PC2 (", round(prop_var_3[2] * 100, 1), "%)"))
full_plot_3

################################################################################

###     4. Code to reproduce Figure 5 (PCA and disparity of Baskerville and Caslon ILC r)

#Note that this code will produce both Figure 5 from the main text and Supplementary Figure 2
#To run the code for the supplementary figure, remove the # from the code with the *** above and below

library(tidyverse)
library(geomorph)
library(dispRity)

setwd("C:/")
set.seed(123)
data_4 <- read.csv("./Fig 5 ILC r CaslonSs coords.csv", header = TRUE)
size_info_4 <- read.csv("./Fig 5 ILC r CaslonSs size_info.csv", stringsAsFactors = FALSE)
data_4 <- data_4 %>% 
  left_join(size_info_4, by = "filename")

# ***
#add in this section to recreate Supplementary Figure 2
#note that this code will produce slightly different graphs every time, as the subset is drawn randomly

#subset the data, so that both Baskerville and Caslon image datasets are the same size
#based on which point sizes each dataset share, and therefore the maximum sampling within that
#save a version of the clean data
clean_data <- data_4
#identify the common point sizes between Baskerville and Caslon
shared_point_sizes <- data_4 %>%
  filter(source %in% c("Baskerville", "Caslon")) %>% 
  distinct(source, point_size) %>% 
  count(point_size) %>%
  filter(n == 2) %>% 
  pull(point_size)
#check how many shared point sizes there are between Baskerville and Caslon image sets
shared_point_sizes
#subset the data
#size of subset is controlled by slice_sample, which will only ever return the highest shared values
#here, n=6 is the highest number of images found within the shared point sizes
data_subset <- data_4 %>%
  filter(
    source %in% c("Baskerville", "Caslon"),
    point_size %in% shared_point_sizes
  ) %>%
  group_by(source, point_size) %>%
  slice_sample(n = 6)
#rename subset to data to keep code continuity
data_4 <- data_subset

# ***

coords_4 <- as.matrix(data_4[ , !(names(data_4) %in% c("filename", "source", "point_size")) ])
rownames(coords_4) <- data_4$filename
n_landmarks_4 <- ncol(coords_4) / 2
sliders_4 <- rbind(define.sliders(c(1:n_landmarks_4, 1), write.file = FALSE))
coords_array_4 <- geomorph::arrayspecs(coords_4, p = n_landmarks_4, k = 2)

gpa_4 <- geomorph::gpagen(coords_array_4, curves = sliders_4, ProcD = FALSE, print.progress = TRUE)
pca_4 <- geomorph::gm.prcomp(gpa_4$coords)

pca_scores_4 <- as.data.frame(pca_4$x) %>% 
  rownames_to_column("filename") %>%
  left_join(data_4 %>% select(filename, source, point_size), by = "filename")

prop_var_4 <- pca_4$sdev^2 / sum(pca_4$sdev^2)

cols_4 <- c("Baskerville"="#fc951d", #Baskerville specimen sheets, n=5, date range:1757-1775
          "Caslon"="#c6d5b1") #Caslon specimen sheet, n=1, date range: 1764
          
full_plot_4 <- ggplot(pca_scores_4, aes(x = Comp1, y = Comp2, text=filename)) +
  geom_point(alpha = 1, cex=7, pch = 21, aes(fill=source)) +
  scale_fill_manual(values = c(cols)) +
  theme_minimal() +
  labs(
    x = paste0("PC1 (", round(prop_var[1] * 100, 1), "%)"),
    y = paste0("PC2 (", round(prop_var[2] * 100, 1), "%)"))
full_plot_4

list_source_4 <- list("Baskerville_1757-1775"=which(grepl("Baskerville", pca_scores_4$source)),
                    "Caslon_1764" = which(grepl("Caslon", pca_scores_4$source)))
output_res_4 <- as.matrix(pca_4$x)

groups_disparity_4 <- dispRity.per.group(output_res_4, list_source_4)
plot(groups_disparity_4, col=cols_4)

################################################################################
#FIN