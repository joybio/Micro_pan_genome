rm(list=ls())
library(ggplot2)
library(tidyr)
library(RColorBrewer)
colors <- brewer.pal(3, "Set2")
if (!suppressWarnings(suppressMessages(require("optparse", character.only = TRUE, 
                                               quietly = TRUE, warn.conflicts = FALSE)))) {
  install.packages(p, repos=site)
  require("optparse",character.only=T)
}
# 解析参数-h显示帮助信息
if (TRUE){
  option_list = list(
    make_option(c("-n", "--number"), type="character", default="number.xls",
                help="number.xls of roary_split output. [default %default]"),
    make_option(c("-p", "--pan"), type="character", default="pan.summary.csv",
                help="pan.summary.csv of roary_split output. [default %default]"),
    make_option(c("-o", "--out"), type="character", default="pangenome",
                help="Prefix of output. [default %default]"))
  opts = parse_args(OptionParser(option_list=option_list))
}
Taxonomy <- c("Kingdom","Phylum","Class","Order","Family","Genus","Species")
number <- read.csv(opts$number,header = T,sep = "\t",quote = "")
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
# colnames(number) <- c("Species","Number","Phylum")
number_update$Species <- factor(number_update$Species,levels = number_update$Species)
prefix <- opts$out
number_pdf <- paste0(prefix, ".number.pdf")
number_tif <- paste0(prefix, ".number.tiff")
p <- ggplot(data = number_update,aes(x=Species,y=Number,fill=Phylum))
p + geom_bar(stat='identity',position=position_dodge(0.6),width = 0.8) + 
  theme_minimal() + scale_y_continuous(expand = c(0,0),limits = c(0,60))+ 
  theme(plot.margin = unit(rep(4,4),"lines"),
  axis.text.x=element_text(angle=45,vjust = 0.5,colour="black",family="Times",size=8), 
  axis.text.y=element_text(family="Times",size=8,face="plain"), 
  axis.title.y=element_text(family="Times",size = 8,face="plain"),
  panel.border = element_blank(),axis.line = element_line(colour = "black",size=0.5), 
  legend.position = "top"
  )
ggsave(number_pdf)
ggsave(number_tif)

library(reshape2)
percentage <- read.csv(opts$pan,header = TRUE,row.names=1, sep = ",",quote = "")
#percentage[1,1] <- c("Species")
#colnames(percentage) <- percentage[1,]
#percentage <- percentage[-1,]
percentage_sum <- apply(percentage, 2, sum)
for(m in 1:ncol(percentage))
{
  for(n in 1:nrow(percentage)){
    percentage[n,m]=percentage[n,m]/percentage_sum[m]
    # [每个样本的每个物种的丰度] / [该样本物种总丰度] = 相对丰度
  }
}
percentage$Species <- factor(row.names(percentage),levels = rev(row.names(percentage)))
percentage2 <- melt(percentage,id.vars = c('Species'))
percentage_pdf <- paste0(prefix, ".percentage.pdf")
percentage_tif <- paste0(prefix, ".percentage.tiff")
p <- ggplot(data = percentage2,aes(x=variable,y=value,fill=Species))
p + geom_bar(position = "fill",stat = 'identity',width = 0.8) + 
  xlab("")+
  ylab("Percentage")+
  theme_minimal() + scale_y_continuous(expand = c(0,0))+ 
  theme(plot.margin = unit(rep(4,4),"lines"),
        axis.text.x=element_text(angle=45,vjust = 0.5,colour="black",family="Times",size=8), 
        axis.text.y=element_text(family="Times",size=8,face="plain"), 
        axis.title.y=element_text(family="Times",size = 8,face="plain"),
        panel.border = element_blank(),axis.line = element_line(colour = "black",size=0.5), 
        legend.position = "top"
  )
ggsave(percentage_pdf)
ggsave(percentage_tif)
