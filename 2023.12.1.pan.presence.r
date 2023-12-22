library(pheatmap)
library(RColorBrewer)
library(dplyr)
if (!suppressWarnings(suppressMessages(require("optparse", character.only = TRUE, 
                                               quietly = TRUE, warn.conflicts = FALSE)))) {
  install.packages(p, repos=site)
  require("optparse",character.only=T)
}
# 解析参数-h显示帮助信息
if (TRUE){
  option_list = list(
    make_option(c("-i", "--input"), type="character", default="gene_presence_absence.Rtab",
                help="roary output. [default %default]"),
    make_option(c("-o", "--out"), type="character", default="Gene_presence.heatmap.pdf",
                help="output. [default %default]"))
  opts = parse_args(OptionParser(option_list=option_list))
}
df<-read.csv(opts$input,row.names = 1,sep="\t")#读入数据
dim(df)#获取数据的维度信息
#colnames(df)
#colnames(df) <- c("A13334","BD","2308","2007BM1","PB150210","ZHU","M5")

colors <- brewer.pal(4, "Set2")
df2 <- df %>% filter_all(any_vars(. == 0))
write.table(df2,"diff_gene_presence_absence.Rtab",sep="\t",quote=FALSE)
 
pdf(opts$out)
pheatmap(df2,cellwidth = 7,cellheight = 1, fontsize = 1,cluster_rows = T,scale='none',cluster_cols = T,show_rownames = T,show_colnames = T,display_numbers=F,color=colorRampPalette(c("#8DA1CB","#66CC99"))(2))
dev.off()

