library(ggplot2)
library(reshape2)
library(tidyr)
library(RColorBrewer)
library(ggpubr)
if (!suppressWarnings(suppressMessages(require("optparse", character.only = TRUE, 
                                               quietly = TRUE, warn.conflicts = FALSE)))) {
  install.packages(p, repos=site)
  require("optparse",character.only=T)
}

# 解析参数-h显示帮助信息
if (TRUE){
  option_list = list(
    make_option(c("-n", "--number"), type="character", default="number.xls",
                help="number.xls of pan_roary.py output. [default %default]"),
    make_option(c("-p", "--pan"), type="character", default="pan.summary.csv",
                help="pan.summary.csv of pan_roary.py output. [default %default]"),
    make_option(c("-o", "--out"), type="character", default="Geneome_number_pan_size",
                help="Prefix of output. [default %default]"))
  opts = parse_args(OptionParser(option_list=option_list))
}
Taxonomy <- c("Kingdom","Phylum", "Class", "Order", "Family", "Genus", "Species", "Strain")

colors <- brewer.pal(8, "Set2")
number <- read.csv(opts$number,header = T,sep = "\t",quote = "")
#number <- read.csv("../pangenome/number.xls",header = T,sep = "\t",quote = "")
number_update <- number %>%  separate(col = "Species",into = Taxonomy,sep=";")

for(i in colnames(number_update)){
  for (j in c(1:nrow(number_update))){
    if (length(grep("__",number_update[j,i]))!=0){
      number_update[j,i] <- substr(number_update[j,i],4,nchar(number_update[j,i])) 
    }
    else{number_update[j,i] <- number_update[j,i]
    }
  }
}
percentage <- read.csv(opts$pan,header = TRUE,row.names=1, sep = ",",quote = "")
#percentage <- read.csv("pan.summary.csv",header = TRUE,row.names=1, sep = ",",quote = "")
percentage["pan_genome_size",] <- percentage["Total_genes",] - percentage["Cloud_genes",]
percentage["nor_pan_genome_size",] <- percentage["pan_genome_size",]/percentage["Total_genes",] * 100
number_update$nor_pan_genome_size <- t(percentage["nor_pan_genome_size",])

prefix <- opts$out
pdf <- paste0(prefix, ".pdf")
tif <- paste0(prefix, ".tiff")
color.vec <- colors[1:length(unique(number_update$Phylum))]
v=ggplot(number_update,aes(x=Number,y=nor_pan_genome_size,colour = Phylum))
v + geom_point(size = 2) + labs(title="",x="Number of genomes",
                               y="Normalized pan genome size") +
  xlim(min(number_update$Number),max(number_update$Number)) +
  stat_smooth(method = 'lm') +  # 
  stat_cor(data=number_update, method = "pearson",size = 4) + 
  scale_y_continuous(expand = c(0,0),limits = c(min(number_update$Number),1.2*max(number_update$nor_pan_genome_size))) +
  theme_bw() + #背景变为白色
  theme(axis.text.x=element_text(vjust = 1,colour="black",family="Times",size=8), #设置x轴刻度标签的字体显示倾斜角度为15度，并向下调整1(hjust = 1)，字体簇为Times大小为20
        axis.text.y=element_text(family="Times",size=8,colour="black"), #设置y轴刻度标签的字体簇，字体大小，字体样式为plain
        axis.title.x=element_text(family="Times",size = 8,colour="black"),
        axis.title.y=element_text(family="Times",size = 8,colour="black"), #设置y轴标题的字体属性
        panel.border = element_blank(),axis.line = element_line(colour = "black",size=0.5), #去除默认填充的灰色，并将x=0轴和y=0轴加粗显示(size=1)
        legend.text=element_text(family="Times", colour="black",  #设置图例的子标题的字体属性
                                 size=8),
        legend.title=element_text(family="Times", colour="black", #设置图例的总标题的字体属性
                                  size=8),
        panel.grid.major = element_blank(),   #不显示网格线
        panel.grid.minor = element_blank(),
        legend.position = c(0.85,0.9))
ggsave(pdf,width = 10,height = 10)
ggsave(tif,width = 10,height = 10)



