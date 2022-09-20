library("tidyverse")
library("reshape2")
library("dplyr")
library("fs")
library("ggplot2")
library("paletteer")
library("wesanderson")
library("RColorBrewer")
library(pals)



setwd("~/Dropbox/Doctorado_UNAB/Tesis/Scripts_Python_2022/Patho2Tax")

read_csv_filename <- function(filename){
  ret <- read.csv(filename, header = T)
  filename <- path_file(filename)
  ret$Source <- filename #EDIT
  ret
}

files <- list.files(path = ".", pattern = "*.tsv.txt", full.names = T, recursive = F)
res <- lapply(files, read_csv_filename)

metadata <- read.csv("metadata_outpatho.txt", sep = "\t", header = T)

final_df <- do.call("rbind", res) %>%
  separate(Genome, c("Domain", "Phylum", "Class", "Order", "Family", "Genus","Species"), sep = ";")

write_csv(merge_metadata, file = "all_data_df.csv")

merge_metadata <- merge(final_df,
                        metadata,
                        by.x = "Source",
                        by.y = "OutputScriptName")

p <- ggplot(merge_metadata, aes(x=MuestraConFecha, y=Final.Best.Hit, fill=Phylum)) +
  geom_col() + facet_grid(~depth_m)

#+ facet_wrap(~Estacion)
p

select_top20_data <- merge_metadata  %>%
  select(MuestraConFecha, Phylum, Final.Best.Hit, Estacion) %>%
  group_by(Estacion, Phylum) %>%
  summarize(Sum_fam = sum(Final.Best.Hit)) %>%
  filter(Sum_fam < 0.0001) %>%
  top_n(10, Sum_fam) 

ggplot(select_top20_data, aes(x = Estacion, y =Sum_fam, fill= Phylum)) + 
geom_bar(stat = "identity", color = "black") +
theme(legend.text = element_text(size=6), axis.text = element_text(size = 8)) +
labs(x = "Estacion",y = "Abundancia relativa") +
scale_fill_manual(values=as.vector(cols25(26)))

select_top20_data
  
ggsave(
  "newtop10_phylum_rare_estacion.tiff",
  plot = last_plot(),
  device = NULL,
  path = NULL,
  scale = 1,
  width = NA,
  height = NA,
  units = c("in", "cm", "mm", "px"),
  dpi = 300,
  
)







select_rare_data <- merge_metadata  %>% 
  select(MuestraConFecha, Phylum, Final.Best.Hit) %>%
  filter(Final.Best.Hit < 0.0001 ) %>% 
  ggplot(aes(x = MuestraConFecha, y =Final.Best.Hit, fill= Phylum)) + geom_col()

select_rare_data

ggsave(
  "top_rare.tiff",
  plot = last_plot(),
  device = NULL,
  path = NULL,
  scale = 1,
  width = NA,
  height = NA,
  units = c("in", "cm", "mm", "px"),
  dpi = 100,
  
)



melt_data <- melt(merge_metadata, id.vars=c("Final.Best.Hit","MuestraConFecha"))


ggplot(subset_merge_data, aes(x = MuestraConFecha, y =Final.Best.Hit), group = value) + #para que se pinte lo que yo quiero debe ser indicado en esta fila!!!!
  geom_area()





# create data
time <- as.numeric(rep(seq(1,7),each=7))  # x Axis
value <- runif(49, 10, 100)               # y Axis
group <- rep(LETTERS[1:7],times=7)        # group, one shape per group
data <- data.frame(time, value, group)

# stacked area chart
ggplot(data, aes(x=time, y=value, fill=group)) + 
  geom_area()



