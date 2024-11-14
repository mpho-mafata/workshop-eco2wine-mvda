# set the directory to save our data
setwd("/Users/~/my_folder")

# The libraries needed for reading your data into R
if(!require("readxl",character.only = TRUE)) install.packages("readxl") #install if not already done
 library("readxl",character.only = TRUE)  #import library

# read-in the data
my_github_file = "https://raw.github.com/mpho-mafata/workshop-eco2wine-mvda/main/datasets/data_wrangling.xlsx"
download.file(my_github_file, destfile = "data_wrangling_example.xlsx")
my_data = readxl::read_xlsx("data_wrangling_example.xlsx")

View(my_data) # look at my data

# install and import the data wrangling library
if(!require("tidyverse",character.only = TRUE)) install.packages("tidyverse") #install if not already done
 library("tidyverse",character.only = TRUE) #import library

# subset my data into the metadata section
# We view the document in-between to see the transformation
meta_data = my_data[,1:7]
View(meta_data)
# Set the first row as header for columns
colnames(meta_data) = meta_data[1,]
View(meta_data)
# Now you can remove the first row
meta_data = meta_data[-1,]
View(meta_data)

# One line operation for the above steps
meta_data = my_data[,1:7]  |> `colnames<-` (my_data[1,]) |> slice(-1)
# This is the same as:
meta_data = my_data[,1:7]  %>% `colnames<-` (my_data[1,]) %>%  slice(-1)

# Have a look at the merged columns to be subset
print(colnames(my_data))

# Now we can subset the other parts of the data
# We view the document in-between to see the transformation
fragrance = my_data[,17:136]
View(fragrance)
colnames(fragrance) = fragrance[1,]
fragrance = fragrance[-1,]
View(fragrance)

# OR USE THE ONE LINE
fragrance = my_data[,17:136]  |> `colnames<-` (my_data[1,]) |> slice(-1)

# Library for writing back an excel document
if(!require("writexl",character.only = TRUE)) install.packages("writexl") #install if not already done
 library("writexl",character.only = TRUE) #import library

# Save an excel file with multiple sheets
# For sheet names with spaces, put them in inverted commas
writexl::write_xlsx(list("Meta data"= meta_data, fragrance= fragrance), "wrangled_data.xlsx")
