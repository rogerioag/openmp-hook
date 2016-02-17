library(plyr)
library(ggplot2)
library(pdf)

# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)

  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)

  numPlots = length(plots)

  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                    ncol = cols, nrow = ceiling(numPlots/cols))
  }

 if (numPlots==1) {
    print(plots[[1]])

  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))

    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))

      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

setwd("/dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/tests/polybench-acc/openmp-offloading/linear-algebra/kernels/gemm/output/");

pdf(filename="/home/rogerio/data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-final.pdf", width=1200, height=800);
# data
mydata1 = read.csv("/dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/tests/polybench-acc/openmp-offloading/linear-algebra/kernels/gemm/output/data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-final.csv");

mydata1

#          dataset schedule chunk_size threads      exp num_threads   NI   NJ   NK ORIG       OMP
#1   LARGE_DATASET  DYNAMIC         16       1  OMP+OFF           1 2000 2000 2000   NA 79.229023

View (mydata1)

# Run the functions length, mean, and sd on the value.
cdata <- ddply(mydata1, c("dataset", "schedule", "chunk_size", "exp", "num_threads"), summarise,
               N    = length(num_threads),
               mean_orig = mean(ORIG),
               mean_omp = mean(OMP),
               sd_orig   = 2 * sd(ORIG),
               sd_omp   = 2 * sd(OMP),
               se_orig   = sd_orig / sqrt(N),
               se_omp   = sd_omp / sqrt(N)
)
cdata

#          dataset schedule chunk_size      exp num_threads  N mean_orig  mean_omp sd_orig     sd_omp se_orig     se_omp
# 1  LARGE_DATASET  DYNAMIC         16  OMP+OFF           1 10        NA 79.818392      NA 0.54822371      NA 0.17336356

df1 = data.frame(x=cdata$num_threads, y=cdata$chunk_size, z=cdata$mean_orig, z_se=cdata$se_orig, z_sd=cdata$sd_orig, t=cdata$mean_omp, t_se=cdata$se_omp, t_sd=cdata$sd_omp, cat=cdata$exp)
df1$x = as.factor(df1$x)
df1$y = as.factor(df1$y)

# chunk size 16. Selecionar somente os chunks 16.
# df_chunk_size_16 <- df1[grep(16, df1$y),]
# chunk size: 16
p1 <- ggplot(subset(df1, y==16), aes(x=x, y=t, fill=cat)) + 
        geom_bar(stat="identity", position="dodge") +
        geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
                  size=.3,    # Thinner lines
                  width=.2,
                  position=position_dodge(.9)) + 
        xlab("Number of Threads") +
        ylab("Time(s)") +
        #scale_fill_manual(name="Experiment", # Legend label, use darker colors
        #           breaks=c("OMP+OFF", "OMP"),
        #           labels=c("OMP+OFF", "OMP"), values=c("#494949", "#927080", "#B6B6B6")) +
        ggtitle("chunk_size: 16") +
        scale_y_continuous(breaks=0:80*5) + 
        theme_bw() +
        theme(legend.position=c(0.85,0.79), legend.title=element_blank())

(p1 = p1 + scale_fill_grey(start = 0.2, end = 0.9))


# chunk size: 32
p2 <- ggplot(subset(df1, y==32), aes(x=x, y=t, fill=cat)) + 
        geom_bar(stat="identity", position="dodge") +
        geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
                  size=.3,    # Thinner lines
                  width=.2,
                  position=position_dodge(.9)) + 
        xlab("Number of Threads") +
        ylab("Time(s)") +
        #scale_fill_manual(name="Experiment", # Legend label, use darker colors
        #           breaks=c("OMP+OFF", "OMP"),
        #           labels=c("OMP+OFF", "OMP"), values=c("#494949", "#927080", "#B6B6B6")) +
        ggtitle("chunk_size: 32") +
        scale_y_continuous(breaks=0:80*5) + 
        theme_bw() +
        theme(legend.position=c(0.85,0.79), legend.title=element_blank())

(p2 = p2 + scale_fill_grey(start = 0.2, end = 0.9))

# chunk size: 64
p3 <- ggplot(subset(df1, y==64), aes(x=x, y=t, fill=cat)) + 
    geom_bar(stat="identity", position="dodge") +
    geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
                  size=.3,    # Thinner lines
                  width=.2,
                  position=position_dodge(.9)) + 
    xlab("Number of Threads") +
    ylab("Time(s)") +
    ggtitle("chunk_size: 64") +
    scale_y_continuous(breaks=0:80*5) +
    scale_colour_grey(start = 0, end = .9) +
    theme_bw() +
    theme(legend.position=c(0.85,0.79), legend.title=element_blank())

(p3 = p3 + scale_fill_grey(start = 0.2, end = 0.9))

multiplot(p1, p2, p3, cols=2)

# dev.print(pdf,filename="data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-final.pdf");

dev.copy2pdf(file = "data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-final.pdf");
# dev.off ();