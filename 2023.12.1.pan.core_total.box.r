library(ggplot2)
library(reshape2)
library(RColorBrewer)
if (!suppressWarnings(suppressMessages(require("optparse", character.only = TRUE, 
                                               quietly = TRUE, warn.conflicts = FALSE)))) {
  install.packages(p, repos=site)
  require("optparse",character.only=T)
}
# 解析参数-h显示帮助信息
if (TRUE){
  option_list = list(
    make_option(c("-c", "--core"), type="character", default="number_of_conserved_genes.Rtab",
                help="number_of_conserved_genes.Rtab of roary output. [default %default]"),
    make_option(c("-t", "--total"), type="character", default="number_of_genes_in_pan_genome.Rtab",
                help="number_of_genes_in_pan_genome.Rtab of roary output. [default %default]"),
    make_option(c("-o", "--out"), type="character", default="Box_of_genomes_and_genes",
                help="Prefix of output. [default %default]"))
  opts = parse_args(OptionParser(option_list=option_list))
}

colors <- brewer.pal(4, "Set2")
core_genes = read.table(opts$core)
genes = read.table(opts$total)
long_core_genes <- melt(core_genes)
long_core_genes$type <- rep("Core genes")
long_pan_genes <- melt(genes)
long_pan_genes$type <- rep("Pan genes")
merge <- rbind(long_core_genes,long_pan_genes)

merge$number <- factor(substr(merge$variable,2,length(merge$variable)),levels =unique(substr(merge$variable,2,length(merge$variable))))

prefix <- opts$out
pdf <- paste0(prefix, ".pdf")
tif <- paste0(prefix, ".tiff")
p <- ggplot(merge, aes(x = number,value,fill=type)) + 
  labs(title="",x="Number of genomes", y="Number of genes")

p + geom_boxplot(width=0.5,position=position_dodge(0.6)) + # xlim(c(1,max(merge$number))) +
  scale_fill_manual(values=colors) +
  scale_y_continuous(limits = c(0,1.1*max(merge$value)),expand = c(0,0)) +
  scale_x_discrete(breaks=seq(1,max(as.numeric(merge$number)),max(as.numeric(merge$number))/5),
                   labels=as.character(seq(1,max(as.numeric(merge$number)),max(as.numeric(merge$number))/5))) +
  theme_bw()+ #背景变为白色
  theme(axis.text.x=element_text(vjust = 1,colour="black",family="Times",size=10), #设置x轴刻度标签的字体显示倾斜角度为15度，并向下调整1(hjust = 1)，字体簇为Times大小为20
        axis.text.y=element_text(family="Times",size=10,colour="black"), #设置y轴刻度标签的字体簇，字体大小，字体样式为plain
        axis.title.y=element_text(family="Times",size = 10,colour="black"), #设置y轴标题的字体属性
        panel.border = element_blank(),axis.line = element_line(colour = "black",size=0.5), #去除默认填充的灰色，并将x=0轴和y=0轴加粗显示(size=1)
        panel.grid.major = element_blank(),   #不显示网格线
        panel.grid.minor = element_blank(),
        legend.title = element_blank(),
        legend.position="top")
ggsave(pdf,width = 10,height = 10)
ggsave(tif,width = 10,height = 10)



