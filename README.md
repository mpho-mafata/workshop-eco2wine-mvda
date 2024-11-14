# Exploratory Multivariate Data Analysis in Wine Sciences

<img src="/figures/winemaking.jpg">

Winemaking is a long process with tandem stages that feedback and influence each other. 
As a complex chemical solution, the study of wine is in itself, complicated.
This is why it is studies as a transdiciplinary discipline.
Some of the core disciplines include: Agriculture (viticulture), Economics, Engineering (process analytical technology - PAT, biotechnology),
Natural Sciences (Chemistry, Biochemistry, Microbiology), and Social science (Consumer and Sensory science).

# Tutorial 1: Data wrangling
This tutorial uses a typical oenological dataset <a href="https://github.com/mpho-mafata/workshop-eco2wine-mvda/blob/main/datasets">found here (data_wrangling.xlsx)</a> and the full script <a href="https://github.com/mpho-mafata/workshop-eco2wine-mvda/blob/main/tutorial_scripts"> available here (data_wrangling.R)</a>..

Sometimes when we use spreadsheets to log our data we may decide to concatenate related data into one sheet then use field demarcation to indicate the different data.
The state of such data is not conducive for analysis so it will need to be processed ("wrangled") for analysis.

<img src="/figures/concatenated_data.jpg">

```
# The libraries needed for reading your data into R
install.packages("readxl") # install if not already done
library("readxl") # import once installed

# read-in the data
my_data = readxl::read_xlsx(path="/Users/~/data_wrangling.xlsx")

# install and/or import the data wrangling library
install.packages("tidyverse")
library("tidyverse")

meta_data = my_data[,1:7] # subset my data into the metadata section
colnames(meta_data) = meta_data[1,] # Set the first row as header for columns
meta_data = meta_data[-1,] # Now you can remove the first row

## One line operation for the above three steps
meta_data = my_data[,1:7]  |> `colnames<-` (my_data[1,]) |> slice(-1)
# This is the same as:
meta_data = my_data[,1:7]  %>% `colnames<-` (my_data[1,]) %>%  slice(-1)

# Have a look at the merged columns to be subset
print(colnames(my_data))

# Now we can subset the other parts of the data
fragrance = my_data[,17:136]  |> `colnames<-` (my_data[1,]) |> slice(-1)

# Library for writing back an excel document
install.packages("writexl")
library("writexl")

# Save an excel file with multiple sheets
# For sheet names with spaces, put them in inverted commas
writexl::write_xlsx(list("Meta data"= meta_data, fragrance= fragrance), "cleaned_data.xlsx")

# Now practice subseting the other data block
# Extra tast: See if you can create a unique sample ID for the data

```

# Tutorial 2: Exploratory data fusion by multiple factor analysis (MFA)

<img src="/figures/multicluster.jpg">

This tutorial uses a multimodal dataset <a href="https://github.com/mpho-mafata/workshop-eco2wine-mvda/blob/main/datasets">found here (old_vines.xlsx)</a> and the full script <a href="https://github.com/mpho-mafata/workshop-eco2wine-mvda/blob/main/tutorial_scripts"> available here (old_vines.R)</a>. We start with the analysis of individual blocks using a heatmap, pca, and mds.
</br>
</br>
<img width='30%' src="/figures/heatmap.jpg" hspace="10">
<img width='30%' src="/figures/pca_plot.jpg" hspace="10">
<img width='30%' height='200' src="/figures/mds_plot.jpg" hspace="10">
</br>

And then we look at the multiblock analysis (MFA)
