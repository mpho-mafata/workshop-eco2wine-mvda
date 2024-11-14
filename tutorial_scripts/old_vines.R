#clear the environment to save on driver space and run faster
rm(list = ls())
# set the directory to save your files
setwd("/Users/~/my_folder")

# import the necessary libraries
my_packages <- c("readxl", # to read an excel file
                 "tidyverse", # to wrangle data frames
                 "glue", # turn numeric or object data as string equivalents
                 "ggplot2", # to plot the spectra
                 "scales", # for formating numerical data in plots
                 "FactoMineR", # maiin library for the analysis
                 "factoextra", # provides additional plotting
                 "factoextra", # provides additional plotting
                 "pheatmap", # for heatmap generation
                 "writexl" # to write back an excel file
)

# check if a library is already installed, then import
for(p in my_packages){
  if(!require(p,character.only = TRUE)) install.packages(p)
  library(p,character.only = TRUE)
}

# function for reading each sheet in the file
read_excel_allsheets <- function(filename, tibble = FALSE) {
    sheets <- readxl::excel_sheets(filename)
    x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
    if(!tibble) x <- lapply(x, as.data.frame)
    names(x) <- sheets
    x
}

# now we retrieve each sheet and name it according to the sheet name.
my_github_file = "https://raw.github.com/mpho-mafata/workshop-eco2wine-mvda/main/datasets/old_vines.xlsx"
download.file(my_github_file, destfile = "old_vines.xlsx")
mysheets <- read_excel_allsheets(filename="old_vines.xlsx")
my_datasets <- names(mysheets)
print(my_datasets)

# extract data tables
nmr <- as.data.frame(mysheets$nmr)[,-(1:5)]
hrms_pos <- as.data.frame(mysheets$hrms_pos)[,-(1:5)]
hrms_neg <- as.data.frame(mysheets$hrms_neg)[,-(1:5)]
uv_vis <- as.data.frame(mysheets$uv_vis)[,-(1:5)]
infra_red <- as.data.frame(mysheets$infra_red)[,-(1:5)]
oeno_params <- as.data.frame(mysheets$oeno_params)[,-(1:5)]
oeno_params <- replace(oeno_params, oeno_params=='-', 0)
sensory_sorting_1 <- as.data.frame(mysheets$sensory_sorting_1)[,-(1:5)]
sensory_sorting_2 <- as.data.frame(mysheets$sensory_sorting_2)[,-(1:5)]

# ANALYSE AND VISUALIZE DATA
# Sensory analysis additional analysis/visualization
# multidimensional scaling of sorting analysis
mds_data <- as.data.frame(mysheets$sensory_sorting_2)[,-(1:5)] %>% column_to_rownames(., var = 'primary_id')
distance_matrix <- dist(mds_data)
fit <- cmdscale(distance_matrix, eig = TRUE,
                k=5 # The number of dimensions to fit
)
# MDS scree plot
mds_scree <- as.data.frame(fit$eig)
mds_scree$variance <- (mds_scree$`fit$eig`/sum(mds_scree$`fit$eig`))*100
ggplot(data = mds_scree,aes(x = as.numeric(row.names(mds_scree)),y = variance)
) + geom_bar(stat="identity", fill="maroon")+
  geom_text(aes(label=round(x=variance,digits = 1)), vjust=1.6, color="white")+
  xlab("Eigenvalue")+ylab("Dimension")+
  theme_minimal()

#extract the coordinates of the first two dimensions to plot
x <- fit$points[,1]
y <- fit$points[,2]

#create scatter plot using ggplot2
my_mds = ggplot(data = data.frame(fit$points),
                  aes(x = x, y = y)
) + geom_point()+ geom_text(aes(label=row.names(mds_data), vjust=1.6))+
  geom_hline(yintercept=0.0,linetype=2)+
  geom_vline(xintercept=0.0,linetype=2)+
  xlab(glue("D1 ({round(mds_scree$variance[1], digits=2)}%)"))+
  ylab(glue("D2 ({round(mds_scree$variance[2], digits=2)}%)"))+
  theme_minimal()
ggsave(
  filename = "mds_plot.jpg", # <---- set plot name here!
  plot = my_mds, # <---- insert plot here!
  width = 30, height = 15, units = 'cm', # <---- set the plot dimensions here!
  dpi = 300 # <---- set the picture quality here!
)

# Heat maps and cluster dendrograms
sensory = t(data.frame(mysheets$sensory_sorting_1)[,-(1:5)]%>% column_to_rownames(., var = 'primary_id'))
class_designation = data.frame(mysheets$sensory_sorting_1)[,(5:6)]%>% column_to_rownames(., var = 'primary_id')
my_heatmap =  pheatmap(sensory, scale="row", annotation_col=class_designation)
ggsave(
  filename = "heatmap.jpg", # <---- set plot name here!
  plot = my_heatmap, # <---- insert plot here!
  width = 30, height = 20, units = 'cm', # <---- set the plot dimensions here!
  dpi = 300 # <---- set the picture quality here!
)

# PCA of oenological/physicochemical parameters
pca_data <- oeno_params %>% column_to_rownames(., var = 'primary_id')
pca_data[] <- lapply(pca_data, as.numeric)
my_pca <- PCA(pca_data, ncp=10, graph = FALSE)
pca_plot = fviz_pca_biplot(my_pca,
                addEllipses = TRUE, ellipse.level=0.95, ellipse.type = "norm",
                col.ind = "black", col.var = 'red', palette = "Dark2")
ggsave(
  filename = "pca_plot.jpg", # <---- set plot name here!
  plot = pca_plot, # <---- insert plot here!
  width = 30, height = 20, units = 'cm', # <---- set the plot dimensions here!
  dpi = 300 # <---- set the picture quality here!
)

# DATA FUSION WITH MULTIPLE FACTOR ANALYSIS (MFA)
merged_dataset <- merge(nmr,hrms_pos,
                   by = "primary_id")
for (data_block in my_datasets[3:8]) {
  print(glue("merging {data_block}"))
  merged_dataset <- merge(merged_dataset,
                     get(data_block),
                     by = "primary_id")
}
View(merged_dataset)
merged_dataset <- merged_dataset %>% column_to_rownames(., var = 'primary_id')
merged_dataset <- mutate_all(merged_dataset, function(x) as.numeric(as.character(x)))
# run the MFAs
mfa_plot <- MFA(
  merged_dataset,
  group = c(length(nmr)-1, length(hrms_pos)-1, length(hrms_neg)-1, length(uv_vis)-1, length(infra_red)-1,
            length(oeno_params)-1, length(sensory_sorting_1)-1, length(sensory_sorting_2)-1),
  type = c(rep("s", 6), rep("f", 2)),
  ncp = length(merged_dataset),
  name.group = c(my_datasets),
  graph = FALSE
)
# Explained variance: scree plot variant
explained_variance <- as.data.frame(mfa_plot$global.pca$eig)
ggplot(data = explained_variance,
                  aes(x = factor(row.names(explained_variance), levels = row.names(explained_variance)),
                      y = explained_variance[,3]
                  )
) + geom_bar(stat="identity", fill="maroon")+
  geom_text(aes(label=round(x=explained_variance[,3],digits = 0)), vjust=1.6, color="white", size=3.5)+
  xlab("Dimension")+ylab("Cumulative explained variance (%)")+
  theme_minimal()
plot.MFA(mfa_plot, choix = "ind") # samples/ individuals plot
plot.MFA(mfa_plot, choix = "axes") # plot the first two dimensions from each group
ggsave(
  filename = "mfa_axes.jpg", # <---- set plot name here!
  plot = plot.MFA(mfa_plot, choix = "axes"), # <---- insert plot here!
  width = 30, height = 15, units = 'cm', # <---- set the plot dimensions here!
  dpi = 300 # <---- set the picture quality here!
)

plot.MFA(mfa_plot, choix = "group") # visualize groups
ggsave(
  filename = "mfa_groups.jpg", # <---- set plot name here!
  plot = plot.MFA(mfa_plot, choix = "group"), # <---- insert plot here!
  width = 30, height = 15, units = 'cm', # <---- set the plot dimensions here!
  dpi = 300 # <---- set the picture quality here!
)

plot.MFA(mfa_plot, choix = "var") # visualize variables
plot.MFA(mfa_plot, choix = "freq") # visualize sensory qualitative variables

# Additional plotting library: FactoExtra
# https://rpkgs.datanovia.com/factoextra/reference/fviz_mfa.html
fviz_screeplot(mfa_plot) # scree plot
fviz_mfa_ind(mfa_plot, repel = TRUE) # plot the samples
fviz_mfa_var(mfa_plot) # mfa groups
fviz_mfa_var(mfa_plot, "quanti.var", palette = "jco", # plot the variables
  col.var.sup = "violet", repel = TRUE)
fviz_mfa_ind(mfa_plot, partial = "all") #overlay samples and partial axes of groups
fviz_mfa_axes(mfa_plot) # plot just the axes of each group

# saving the plots
ggsave(
  filename = "mfa_axes.jpg", # <---- set plot name here!
  plot = plot.MFA(mfa_plot, choix = "axes"), # <---- insert plot here!
  width = 30, height = 15, units = 'cm', # <---- set the plot dimensions here!
  dpi = 300 # <---- set the picture quality here!
)
