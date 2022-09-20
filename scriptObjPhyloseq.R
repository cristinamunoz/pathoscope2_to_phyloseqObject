setwd("~/Dropbox/Doctorado_UNAB/Tesis/ObjetoPhyloseq")

# Cargo librerias que necesitaré
library("phyloseq")
library(tidyverse)
library(reshape2)

# Cargo tablas necesarias para formar objeto phyloseq
data_abundancia = read_csv("~/Dropbox/Doctorado_UNAB/Tesis/Scripts_Python_2022/Patho2Tax/all_data_df.csv")

metadata = read_tsv("~/Dropbox/Doctorado_UNAB/Tesis/Scripts_Python_2022/Patho2Tax/metadata_outpatho.txt")


filtered_data <- unite(data_abundancia, taxonomy,c(2:8),  sep = "; ", remove = TRUE) %>% 
  select(taxonomy, MuestraConFecha, MAGs_id, Final.Best.Hit.Read.Numbers) 

# OTU table a partir de los genomas(MAGs). Considerar en que debo indexar
# la comuna de MAGs_id
otu_mags_table <- filtered_data %>%
  select(-taxonomy) %>%
  dcast(MAGs_id~MuestraConFecha, fun.aggregate = sum) %>%
  remove_rownames %>%
  column_to_rownames(var="MAGs_id")

# Taxonomy table
taxa_table<- filtered_data %>% 
  select(MAGs_id, taxonomy) %>% 
  separate(taxonomy, c("Domain", "Phylum", "Class", "Order", "Family", "Genus", "Species"),
           "; ")  %>%
  unique %>%
  remove_rownames %>%
  column_to_rownames(var="MAGs_id")

OTU = otu_table(otu_mags_table, taxa_are_rows = TRUE)
TAX = tax_table(as.matrix(taxa_table))

# Creamos el objeto Phyloseq
physeq = phyloseq(OTU, TAX)
physeq

plot_bar(physeq, fill = "Phylum")


