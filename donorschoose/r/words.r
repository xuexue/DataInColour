setwd('/Users/xuexue/dataincolour/donorschoose/r/')
library('ggplot2')
#words <- read.delim("../data/wc_merged.tsv", sep="\t", quote="", header=T, fill=F)
words <- read.delim("../data/wc_resourcesmerged.tsv", sep="\t", quote="", header=T, fill=F)

memphis_2011 = 2666
tampa_2011 = 4604
all_2011 = 38530

words$no_df_all = all_2011 - words$df_all
words$yes = words$df_all/all_2011
words$no = words$no_df_all/all_2011
words$no_df_tampa = tampa_2011 - words$df_tampa
words$no_df_memphis = memphis_2011 - words$df_memphis

my_chisq <- function (y, n, py, pn) {
  if (y > 0 & n > 0) {
   return(chisq.test(c(y,n),p=c(py,pn))$p.value);
  }
  return(1);
}
words$tampa_p = mapply(my_chisq, words$df_tampa, words$no_df_tampa, words$yes, words$no)
words$memphis_p = mapply(my_chisq, words$df_memphis, words$no_df_memphis, words$yes, words$no)

tampa <- words[words$tampa_p < 0.05,]
tampa$score <- tampa$df_tampa/tampa_2011
tampa$diff <- tampa$score - tampa$yes
tampa <- tampa[sort(tampa$diff,decreasing=T,index.return=T)$ix[0:100],
              c('word', 'df_tampa', 'score', 'yes', 'diff')]

memphis <- words[words$memphis_p < 0.05,]
memphis$score <- memphis$df_memphis/memphis_2011
memphis$diff <- memphis$score - memphis$yes
memphis <- memphis[sort(memphis$diff,decreasing=T,index.return=T)$ix[0:100],
              c('word', 'df_memphis', 'score', 'yes', 'diff')]
              
              write.csv(tampa, 'tampa.essays.csv')
              
              write.csv(memphis, 'memphis.essays.csv')