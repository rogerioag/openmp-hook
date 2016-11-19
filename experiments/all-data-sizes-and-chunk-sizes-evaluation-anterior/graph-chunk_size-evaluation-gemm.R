library(plyr)
library(ggplot2)
library(scales) # to access break formatting functions
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

# Insert rows in data frame.
# Usage: 
# r <- nrow(existingDF) + 1
# newrow <- c(2,3,4,5)
# insertRow(existingDF, newrow, r)
# insertRow(existingDF, c(9,6,3,1), 1)
insertRow <- function(existingDF, newrow, r) {
  existingDF[seq(r+1,nrow(existingDF)+1),] <- existingDF[seq(r,nrow(existingDF)),]
  existingDF[r,] <- newrow
  existingDF
}

setwd("/dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/experiments/chunk_size_evaluation_EXTRALARGE/graph/");

# Load data about OMP, CUDA, OMP_OFF.
data = read.csv("/dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/experiments/chunk_size_evaluation_EXTRALARGE/graph/gemm-21-07-2016-14-33-21-and-28-07-2016-16-49-24-joined-processed-final.csv");
View(data)

cdata <- ddply(data, c("exp", "version", "schedule", "chunk_size" , "num_threads" , "size_of_data" , "NI" , "NJ" , "NK"), summarise,
                   N    = length(chunk_size),
                   mean_orig = mean(ORIG),
                   mean_omp = mean(OMP),
                   mean_omp_off = mean(OMP_OFF),
                   mean_cuda_kernel_1 = mean(CUDA_KERNEL1),
                   mean_cuda_kernel_2 = mean(CUDA_KERNEL2),
                   mean_cuda_kernel_3 = mean(CUDA_KERNEL3),
                   mean_cuda = mean_cuda_kernel_1 + mean_cuda_kernel_2 + mean_cuda_kernel_3,
                   mean_dt_h2d = mean(DT_H2D),
                   mean_dt_d2h = mean(DT_D2H),
                   
                   sd_orig = 2 * sd(ORIG),
                   sd_omp = 2 * sd(OMP),
                   sd_omp_off = 2 * sd(OMP_OFF),
                   sd_cuda_kernel_1 = 2 * sd(CUDA_KERNEL1),
                   sd_cuda_kernel_2 = 2 * sd(CUDA_KERNEL2),
                   sd_cuda_kernel_3 = 2 * sd(CUDA_KERNEL3),
                   sd_cuda = sd_cuda_kernel_1 + sd_cuda_kernel_2 + sd_cuda_kernel_3,
                   sd_dt_h2d = 2 * sd(DT_H2D),
                   sd_dt_d2h = 2 * sd(DT_D2H),
                   
                   se_orig = sd_orig / sqrt(N),
                   se_omp = sd_omp / sqrt(N),
                   se_omp_off = sd_omp_off / sqrt(N),
                   se_cuda_kernel_1 = sd_cuda_kernel_1 / sqrt(N),
                   se_cuda_kernel_2 = sd_cuda_kernel_2 / sqrt(N),
                   se_cuda_kernel_3 = sd_cuda_kernel_3 / sqrt(N),
                   se_cuda = se_cuda_kernel_1 + se_cuda_kernel_2 + se_cuda_kernel_3,
                   se_dt_h2d = sd_dt_h2d / sqrt(N),
                   se_dt_d2h = sd_dt_d2h / sqrt(N),
                   
                   mean_plot_value = 0.0,
                   se_plot_value = 0.0,
                   sd_plot_value = 0.0,
                   sum_work_finish_before_offload_decision = sum(WORK_FINISHED_BEFORE_OFFLOAD_DECISION),
                   sum_reach_offload_decision_point = sum(REACH_OFFLOAD_DECISION_POINT),
                   sum_decided_by_offloading = sum(DECIDED_BY_OFFLOADING),
                   sum_made_the_offloading = sum(MADE_THE_OFFLOADING)
)

View(cdata)

# Prepare column to plot.
cdata$mean_plot_value  <- ifelse(cdata$version == "OMP", cdata$mean_omp, ifelse(cdata$version == "OMP+OFF", cdata$mean_omp_off, cdata$mean_cuda))
cdata$sd_plot_value  <- ifelse(cdata$version == "OMP", cdata$sd_omp, ifelse(cdata$version == "OMP+OFF", cdata$sd_omp_off, cdata$sd_cuda))
cdata$se_plot_value  <- ifelse(cdata$version == "OMP", cdata$se_omp, ifelse(cdata$version == "OMP+OFF", cdata$se_omp_off, cdata$se_cuda))

test <-subset(cdata, version == "OMP+OFF")
write.csv(test, file = "gemm-execucoes-nao-alcancaram-ponto-decisao.csv")

#    exp     size_of_data   NI   NJ   NK  N  mean_orig mean_cuda      sd_orig    sd_cuda      se_orig
df_data = data.frame(x=cdata$num_threads, y=cdata$chunk_size, z=cdata$mean_orig, z_se=cdata$se_orig, z_sd=cdata$sd_orig, t=cdata$mean_plot_value, t_se=cdata$se_plot_value, t_sd=cdata$sd_plot_value, cat=cdata$version)
df_data$x = as.factor(df_data$x)
df_data$y = as.factor(df_data$y)

View(df_data)
# Chunk size 16.
# Chunk size 0 is CUDA version.
# df_plot_16 <- subset(df_data, y== 16 | y == 0)
df_plot_16 <- subset(df_data, y== 16)

View(df_plot_16)

# write.csv(df_plot, file = "chunk_size_evaluation_df_plot.csv")

# df_plot = read.csv("/dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/experiments/chunk_size_evaluation/graph/chunk_size_evaluation_df_plot.csv");
# View(df_plot)

pdf(filename="evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-16.pdf", width=1200, height=800);

p1 <- ggplot(df_plot_16, aes(x=x, y=t, fill=cat)) + 
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
                size=.5,    # Thinner lines
                width=.4,
                position=position_dodge(.9)) + 
  xlab("Number of Threads") +
  ylab("Time(ms)") +
  #scale_fill_manual(name="Experiment", # Legend label, use darker colors
  #           breaks=c("OMP+OFF", "OMP"),
  #           labels=c("OMP+OFF", "OMP"), values=c("#494949", "#927080", "#B6B6B6")) +
  ggtitle("Offloading Analysis for gemm (Number of Threads with chunk_size = 16)\n") +
  # scale_y_continuous(trans='log') +
  scale_y_continuous() +
  # scale_y_log10() +
  theme_bw() +
  #theme(legend.position=c(0.89,0.70), legend.title=element_blank())
  theme(legend.position=c(0.9,0.89), legend.title=element_blank(), plot.title = element_text(size=20))

(p1 = p1 + scale_fill_grey(start = 0.9, end = 0.2))

multiplot(p1, cols=1)
dev.copy2pdf(file = "evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-16.pdf");
# dev.off ();

# Chunk size 32.
#df_plot_32 <- subset(df_data, y== 32 | y == 0)
df_plot_32 <- subset(df_data, y== 32)

View(df_plot_32)

# write.csv(df_plot, file = "chunk_size_evaluation_df_plot.csv")

# df_plot = read.csv("/dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/experiments/chunk_size_evaluation/graph/chunk_size_evaluation_df_plot.csv");
# View(df_plot)

pdf(filename="evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-32.pdf", width=1200, height=800);

p2 <- ggplot(df_plot_32, aes(x=x, y=t, fill=cat)) + 
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
                size=.5,    # Thinner lines
                width=.4,
                position=position_dodge(.9)) + 
  xlab("Number of Threads") +
  ylab("Time(ms)") +
  #scale_fill_manual(name="Experiment", # Legend label, use darker colors
  #           breaks=c("OMP+OFF", "OMP"),
  #           labels=c("OMP+OFF", "OMP"), values=c("#494949", "#927080", "#B6B6B6")) +
  ggtitle("Offloading Analysis for gemm (Number of Threads with chunk_size = 32)\n") +
  # scale_y_continuous(trans='log') +
  scale_y_continuous() +
  # scale_y_log10() +
  theme_bw() +
  #theme(legend.position=c(0.89,0.70), legend.title=element_blank())
  theme(legend.position=c(0.9,0.89), legend.title=element_blank(), plot.title = element_text(size=20))

(p2 = p2 + scale_fill_grey(start = 0.9, end = 0.2))

multiplot(p2, cols=1)
dev.copy2pdf(file = "evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-32.pdf");
# dev.off ();

# Chunk size 64.
# df_plot_64 <- subset(df_data, y== 64 | y == 0)
df_plot_64 <- subset(df_data, y== 64)

View(df_plot_64)

# write.csv(df_plot, file = "chunk_size_evaluation_df_plot.csv")

# df_plot = read.csv("/dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/experiments/chunk_size_evaluation/graph/chunk_size_evaluation_df_plot.csv");
# View(df_plot)

pdf(filename="evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-32.pdf", width=1200, height=800);

p3 <- ggplot(df_plot_64, aes(x=x, y=t, fill=cat)) + 
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
                size=.5,    # Thinner lines
                width=.4,
                position=position_dodge(.9)) + 
  xlab("Number of Threads") +
  ylab("Time(ms)") +
  #scale_fill_manual(name="Experiment", # Legend label, use darker colors
  #           breaks=c("OMP+OFF", "OMP"),
  #           labels=c("OMP+OFF", "OMP"), values=c("#494949", "#927080", "#B6B6B6")) +
  ggtitle("Offloading Analysis for gemm (Number of Threads with chunk_size = 64)\n") +
  # scale_y_continuous(trans='log') +
  scale_y_continuous() +
  # scale_y_log10() +
  theme_bw() +
  #theme(legend.position=c(0.89,0.70), legend.title=element_blank())
  theme(legend.position=c(0.9,0.89), legend.title=element_blank(), plot.title = element_text(size=20))

(p3 = p3 + scale_fill_grey(start = 0.9, end = 0.2))

multiplot(p3, cols=1)
dev.copy2pdf(file = "evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-64.pdf");
# dev.off ();

# Chunk size 128.
#df_plot_128 <- subset(df_data, y== 128 | y == 0)
df_plot_128 <- subset(df_data, y== 128)

View(df_plot_128)

# write.csv(df_plot, file = "chunk_size_evaluation_df_plot.csv")

# df_plot = read.csv("/dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/experiments/chunk_size_evaluation/graph/chunk_size_evaluation_df_plot.csv");
# View(df_plot)

pdf(filename="evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-128.pdf", width=1200, height=800);

p4 <- ggplot(df_plot_128, aes(x=x, y=t, fill=cat)) + 
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
                size=.5,    # Thinner lines
                width=.4,
                position=position_dodge(.9)) + 
  xlab("Number of Threads") +
  ylab("Time(ms)") +
  #scale_fill_manual(name="Experiment", # Legend label, use darker colors
  #           breaks=c("OMP+OFF", "OMP"),
  #           labels=c("OMP+OFF", "OMP"), values=c("#494949", "#927080", "#B6B6B6")) +
  ggtitle("Offloading Analysis for gemm (Number of Threads with chunk_size = 128)\n") +
  # scale_y_continuous(trans='log') +
  scale_y_continuous() +
  # scale_y_log10() +
  theme_bw() +
  #theme(legend.position=c(0.89,0.70), legend.title=element_blank())
  theme(legend.position=c(0.9,0.89), legend.title=element_blank(), plot.title = element_text(size=20))

(p4 = p4 + scale_fill_grey(start = 0.9, end = 0.2))

multiplot(p4, cols=1)
dev.copy2pdf(file = "evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-128.pdf");
# dev.off ();

# Chunk size 256.
# df_plot_256 <- subset(df_data, y== 256 | y == 0)
df_plot_256 <- subset(df_data, y== 256)

View(df_plot_256)

# write.csv(df_plot, file = "chunk_size_evaluation_df_plot.csv")

# df_plot = read.csv("/dados/rogerio/USP/doutorado/prova-de-conceito/testes-prova-conceito/openmp-hook/experiments/chunk_size_evaluation/graph/chunk_size_evaluation_df_plot.csv");
# View(df_plot)

pdf(filename="evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-256.pdf", width=1200, height=800);

p5 <- ggplot(df_plot_256, aes(x=x, y=t, fill=cat)) + 
  geom_bar(stat="identity", position="dodge") +
  geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
                size=.5,    # Thinner lines
                width=.4,
                position=position_dodge(.9)) + 
  xlab("Number of Threads") +
  ylab("Time(ms)") +
  #scale_fill_manual(name="Experiment", # Legend label, use darker colors
  #           breaks=c("OMP+OFF", "OMP"),
  #           labels=c("OMP+OFF", "OMP"), values=c("#494949", "#927080", "#B6B6B6")) +
  ggtitle("Offloading Analysis for gemm (Number of Threads with chunk_size = 256)\n") +
  # scale_y_continuous(trans='log') +
  scale_y_continuous() +
  # scale_y_log10() +
  theme_bw() +
  #theme(legend.position=c(0.89,0.70), legend.title=element_blank())
  theme(legend.position=c(0.9,0.89), legend.title=element_blank(), plot.title = element_text(size=20))

(p5 = p5 + scale_fill_grey(start = 0.9, end = 0.2))

multiplot(p5, cols=1)
dev.copy2pdf(file = "evaluating-chunk_size-benchmark-gemm-data-extralarge_dataset-num_threads-1-a-24-dynamic-chunk_size-256.pdf");
# dev.off ();


# # "exp" , "execution" , "benchmark" , "size_of_data" , "schedule" , "chunk_size" , "num_threads" , "version" , "num_threads" , "NI" , "NJ" , "NK" , "ORIG" , "OMP_OFF" , "OMP" , "CUDA_KERNEL1" , "CUDA_KERNEL2" , "CUDA_KERNEL3" , "DT_H2D" , "DT_D2H" , "WORK_FINISHED_BEFORE_OFFLOAD_DECISION" , "REACH_OFFLOAD_DECISION_POINT" , "DECIDED_BY_OFFLOADING" , "MADE_THE_OFFLOADING"
# 
# # Create data subsets for versions of code (OMP, OMP+OFF, CUDA).
# data_omp <- subset(data, version == "OMP")
# View(data_omp)
# 
# data_omp_off <- subset(data, version == "OMP+OFF")
# View(data_omp_off)
# 
# data_cuda <- subset(data, version == "CUDA")
# View(data_cuda)
# 
# # OMP
# cdata_omp <- ddply(data_omp, c("exp", "version", "schedule", "chunk_size" , "num_threads" , "size_of_data" , "NI" , "NJ" , "NK"), summarise,
#                N    = length(chunk_size),
#                mean_orig = mean(ORIG),
#                mean_omp = mean(OMP),
#                mean_omp_off = mean(OMP_OFF),
#                mean_cuda_kernel_1 = mean(CUDA_KERNEL1),
#                mean_cuda_kernel_2 = mean(CUDA_KERNEL2),
#                mean_cuda_kernel_3 = mean(CUDA_KERNEL3),
#                mean_cuda = mean_cuda_kernel_1 + mean_cuda_kernel_2 + mean_cuda_kernel_3,
#                mean_dt_h2d = mean(DT_H2D),
#                mean_dt_d2h = mean(DT_D2H),
#                
#                sd_orig = 2 * sd(ORIG),
#                sd_omp = 2 * sd(OMP),
#                sd_omp_off = 2 * sd(OMP_OFF),
#                sd_cuda_kernel_1 = 2 * sd(CUDA_KERNEL1),
#                sd_cuda_kernel_2 = 2 * sd(CUDA_KERNEL2),
#                sd_cuda_kernel_3 = 2 * sd(CUDA_KERNEL3),
#                sd_dt_h2d = 2 * sd(DT_H2D),
#                sd_dt_d2h = 2 * sd(DT_D2H),
#                
#                se_orig = sd_orig / sqrt(N),
#                se_omp = sd_omp / sqrt(N),
#                se_omp_off = sd_omp_off / sqrt(N),
#                se_cuda_kernel_1 = sd_cuda_kernel_1 / sqrt(N),
#                se_cuda_kernel_2 = sd_cuda_kernel_2 / sqrt(N),
#                se_cuda_kernel_3 = sd_cuda_kernel_3 / sqrt(N),
#                se_dt_h2d = sd_dt_h2d / sqrt(N),
#                se_dt_d2h = sd_dt_d2h / sqrt(N)
# )
# 
# View(cdata_omp)
# write.csv(cdata_omp, file = "chunk_size_evaluation_omp_final.csv")
# 
# # OMP_OFF
# cdata_omp_off <- ddply(data_omp_off, c("exp", "version", "schedule", "chunk_size" , "num_threads" , "size_of_data" , "NI" , "NJ" , "NK"), summarise,
#                    N    = length(chunk_size),
#                    mean_orig = mean(ORIG),
#                    mean_omp = mean(OMP),
#                    mean_omp_off = mean(OMP_OFF),
#                    mean_cuda_kernel_1 = mean(CUDA_KERNEL1),
#                    mean_cuda_kernel_2 = mean(CUDA_KERNEL2),
#                    mean_cuda_kernel_3 = mean(CUDA_KERNEL3),
#                    mean_cuda = mean_cuda_kernel_1 + mean_cuda_kernel_2 + mean_cuda_kernel_3,
#                    mean_dt_h2d = mean(DT_H2D),
#                    mean_dt_d2h = mean(DT_D2H),
#                    
#                    sd_orig = 2 * sd(ORIG),
#                    sd_omp = 2 * sd(OMP),
#                    sd_omp_off = 2 * sd(OMP_OFF),
#                    sd_cuda_kernel_1 = 2 * sd(CUDA_KERNEL1),
#                    sd_cuda_kernel_2 = 2 * sd(CUDA_KERNEL2),
#                    sd_cuda_kernel_3 = 2 * sd(CUDA_KERNEL3),
#                    sd_dt_h2d = 2 * sd(DT_H2D),
#                    sd_dt_d2h = 2 * sd(DT_D2H),
#                    
#                    se_orig = sd_orig / sqrt(N),
#                    se_omp = sd_omp / sqrt(N),
#                    se_omp_off = sd_omp_off / sqrt(N),
#                    se_cuda_kernel_1 = sd_cuda_kernel_1 / sqrt(N),
#                    se_cuda_kernel_2 = sd_cuda_kernel_2 / sqrt(N),
#                    se_cuda_kernel_3 = sd_cuda_kernel_3 / sqrt(N),
#                    se_dt_h2d = sd_dt_h2d / sqrt(N),
#                    se_dt_d2h = sd_dt_d2h / sqrt(N)
# )
# 
# View(cdata_omp_off)
# write.csv(cdata_omp_off, file = "chunk_size_evaluation_omp_off_final.csv")
# 
# # CUDA.
# cdata_cuda <- ddply(data_cuda, c("exp", "version", "schedule", "chunk_size" , "num_threads" , "size_of_data" , "NI" , "NJ" , "NK"), summarise,
#                        N    = length(chunk_size),
#                        mean_orig = mean(ORIG),
#                        mean_omp = mean(OMP),
#                        mean_omp_off = mean(OMP_OFF),
#                        mean_cuda_kernel_1 = mean(CUDA_KERNEL1),
#                        mean_cuda_kernel_2 = mean(CUDA_KERNEL2),
#                        mean_cuda_kernel_3 = mean(CUDA_KERNEL3),
#                        mean_cuda = mean_cuda_kernel_1 + mean_cuda_kernel_2 + mean_cuda_kernel_3,
#                        mean_dt_h2d = mean(DT_H2D),
#                        mean_dt_d2h = mean(DT_D2H),
#                        
#                        sd_orig = 2 * sd(ORIG),
#                        sd_omp = 2 * sd(OMP),
#                        sd_omp_off = 2 * sd(OMP_OFF),
#                        sd_cuda_kernel_1 = 2 * sd(CUDA_KERNEL1),
#                        sd_cuda_kernel_2 = 2 * sd(CUDA_KERNEL2),
#                        sd_cuda_kernel_3 = 2 * sd(CUDA_KERNEL3),
#                        sd_cuda = sd_cuda_kernel_1 + sd_cuda_kernel_2 + sd_cuda_kernel_3,
#                        sd_dt_h2d = 2 * sd(DT_H2D),
#                        sd_dt_d2h = 2 * sd(DT_D2H),
#                        
#                        se_orig = sd_orig / sqrt(N),
#                        se_omp = sd_omp / sqrt(N),
#                        se_omp_off = sd_omp_off / sqrt(N),
#                        se_cuda_kernel_1 = sd_cuda_kernel_1 / sqrt(N),
#                        se_cuda_kernel_2 = sd_cuda_kernel_2 / sqrt(N),
#                        se_cuda_kernel_3 = sd_cuda_kernel_3 / sqrt(N),
#                        se_cuda = se_cuda_kernel_1 + se_cuda_kernel_2 + se_cuda_kernel_3,
#                        se_dt_h2d = sd_dt_h2d / sqrt(N),
#                        se_dt_d2h = sd_dt_d2h / sqrt(N)
# )
# 
# View(cdata_cuda)
# write.csv(cdata_cuda, file = "chunk_size_evaluation_cuda_final.csv")
# 
# ## AQUI.
# 
# 
# #    exp     size_of_data   NI   NJ   NK  N  mean_orig mean_cuda      sd_orig    sd_cuda      se_orig
# df_cuda = data.frame(x=cdata_cuda$num_threads, y=cdata_cuda$NI, z=cdata_cuda$mean_orig, z_se=cdata_cuda$se_orig, z_sd=cdata_cuda$sd_orig, t=cdata_cuda$mean_cuda, t_se=cdata_cuda$se_cuda, t_sd=cdata_cuda$sd_cuda, cat=cdata_cuda$version)
# df_cuda$x = as.factor(df_cuda$x)
# df_cuda$y = as.factor(df_cuda$y)
# 
# df_cuda
# 
# # size_of_data schedule chunk_size exp num_threads  N mean_orig mean_omp   sd_orig    sd_omp   se_orig se_omp
# 
# 
# df_omp = data.frame(x=cdata_omp$num_threads, y=cdata_omp$chunk_size, z=cdata_omp$mean_orig, z_se=cdata_omp$se_orig, z_sd=cdata_omp$sd_orig, t=cdata_omp$mean_omp, t_se=cdata_omp$se_omp, t_sd=cdata_omp$sd_omp, s=cdata_omp$num_threads, cat=cdata_omp$version)
# df_omp$x = as.factor(cdata_omp$x)
# df_omp$y = as.factor(cdata_omp$y)
# 
# df_omp
# 
# # num_threads: 1 and chunk_size: 64
# subset_omp <- subset(df_omp, x==1 & y==64)
# subset_omp
# 
# cuda_omp <- rbind(df_cuda, subset_omp)
# 
# cuda_omp
# 
# df1 = data.frame(x=cdata1$num_threads, y=cdata1$chunk_size, z=cdata1$mean_orig, z_se=cdata1$se_orig, z_sd=cdata1$sd_orig, t=cdata1$mean_omp, t_se=cdata1$se_omp, t_sd=cdata1$sd_omp, cat=cdata1$exp)
# df1$x = as.factor(df1$x)
# df1$y = as.factor(df1$y)
# 
# df2 = data.frame(x=cdata2$num_threads, y=cdata2$chunk_size, z=cdata2$mean_orig, z_se=cdata2$se_orig, z_sd=cdata2$sd_orig, t=cdata2$mean_omp, t_se=cdata2$se_omp, t_sd=cdata2$sd_omp, cat=cdata2$exp)
# df2$x = as.factor(df2$x)
# df2$y = as.factor(df2$y)
# 
# p1_cuda <- ggplot(df_cuda, aes(x=x, y=t, fill=cat)) + 
#   geom_bar(stat="identity", position="dodge") +
#   geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
#                 size=.5,    # Thinner lines
#                 width=.4,
#                 position=position_dodge(.9)) + 
#   xlab("Number of Threads") +
#   ylab("Time(s)") +
#   #scale_fill_manual(name="Experiment", # Legend label, use darker colors
#   #           breaks=c("OMP+OFF", "OMP"),
#   #           labels=c("OMP+OFF", "OMP"), values=c("#494949", "#927080", "#B6B6B6")) +
#   ggtitle("No Offloading (force use of CPU), chunk_size: 16\n") +
#   scale_y_continuous(breaks=0:100*10) + 
#   theme_bw() +
#   #theme(legend.position=c(0.89,0.70), legend.title=element_blank())
#   theme(legend.position=c(0.9,0.9), legend.title=element_blank(), plot.title = element_text(size=25))
# 
# (p1_cuda = p1_cuda + scale_fill_grey(start = 0.2, end = 0.9))
# 
# # chunk size 16. Selecionar somente os chunks 16.
# # df_chunk_size_16 <- df1[grep(16, df1$y),]
# # chunk size: 16
# 
# p1 <- ggplot(subset(df_omp, y==16), aes(x=x, y=t, fill=cat)) + 
#         geom_bar(stat="identity", position="dodge") +
#         geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
#                   size=.5,    # Thinner lines
#                   width=.4,
#                   position=position_dodge(.9)) + 
#         xlab("Number of Threads") +
#         ylab("Time(s)") +
#         #scale_fill_manual(name="Experiment", # Legend label, use darker colors
#         #           breaks=c("OMP+OFF", "OMP"),
#         #           labels=c("OMP+OFF", "OMP"), values=c("#494949", "#927080", "#B6B6B6")) +
#         ggtitle("No Offloading (force use of CPU), chunk_size: 16\n") +
# #        scale_y_continuous(breaks=0:100*10) + 
#         theme_bw() +
#         #theme(legend.position=c(0.89,0.70), legend.title=element_blank())
#         theme(legend.position=c(0.9,0.9), legend.title=element_blank(), plot.title = element_text(size=25))
# 
# (p1 = p1 + scale_fill_grey(start = 0.2, end = 0.9))
# 
# # chunk size: 32
# p2 <- ggplot(subset(df1, y==32), aes(x=x, y=t, fill=cat)) + 
#         geom_bar(stat="identity", position="dodge") +
#         geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
#                   size=.3,    # Thinner lines
#                   width=.2,
#                   position=position_dodge(.9)) + 
#         xlab("Number of Threads") +
#         ylab("Time(s)") +
#         #scale_fill_manual(name="Experiment", # Legend label, use darker colors
#         #           breaks=c("OMP+OFF", "OMP"),
#         #           labels=c("OMP+OFF", "OMP"), values=c("#494949", "#927080", "#B6B6B6")) +
#         ggtitle("No Offloading (force use of CPU), chunk_size: 32\n") +
#         scale_y_continuous(breaks=0:100*10) + 
#         theme_bw() +
#         #theme(legend.position=c(0.89,0.70), legend.title=element_blank())
#         theme(legend.position=c(0.9,0.9), legend.title=element_blank(), plot.title = element_text(size=25))
# 
# (p2 = p2 + scale_fill_grey(start = 0.2, end = 0.9))
# 
# # chunk size: 64
# p3 <- ggplot(subset(df1, y==64), aes(x=x, y=t, fill=cat)) + 
#     geom_bar(stat="identity", position="dodge") +
#     geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
#                   size=.3,    # Thinner lines
#                   width=.2,
#                   position=position_dodge(.9)) + 
#     xlab("Number of Threads") +
#     ylab("Time(s)") +
#     ggtitle("No Offloading (force use of CPU), chunk_size: 64\n") +
#     scale_y_continuous(breaks=0:100*10) +
#     scale_colour_grey(start = 0, end = .9) +
#     theme_bw() +
#     #theme(legend.position=c(0.89,0.70), legend.title=element_blank())
#     theme(legend.position=c(0.9,0.9), legend.title=element_blank(), plot.title = element_text(size=25))
# 
# (p3 = p3 + scale_fill_grey(start = 0.2, end = 0.9))
# 
# # Offloading.
# p4 <- ggplot(subset(df2, y==16), aes(x=x, y=t, fill=cat)) + 
#         geom_bar(stat="identity", position="dodge") +
#         geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
#                   size=.3,    # Thinner lines
#                   width=.2,
#                   position=position_dodge(.9)) + 
#         xlab("Number of Threads") +
#         ylab("Time(s)") +
#         #scale_fill_manual(name="Experiment", # Legend label, use darker colors
#         #           breaks=c("OMP+OFF", "OMP"),
#         #           labels=c("OMP+OFF", "OMP"), values=c("#494949", "#927080", "#B6B6B6")) +
#         ggtitle("Offloading to GPU, chunk_size: 16\n") +
#         scale_y_continuous(breaks=0:100*10) + 
#         theme_bw() +
#         #theme(legend.position=c(0.89,0.70), legend.title=element_blank())
#         theme(legend.position=c(0.9,0.9), legend.title=element_blank(), plot.title = element_text(size=25))
# 
# (p4 = p4 + scale_fill_grey(start = 0.2, end = 0.9))
# 
# 
# # chunk size: 32
# p5 <- ggplot(subset(df2, y==32), aes(x=x, y=t, fill=cat)) + 
#         geom_bar(stat="identity", position="dodge") +
#         geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
#                   size=.3,    # Thinner lines
#                   width=.2,
#                   position=position_dodge(.9)) + 
#         xlab("Number of Threads") +
#         ylab("Time(s)") +
#         #scale_fill_manual(name="Experiment", # Legend label, use darker colors
#         #           breaks=c("OMP+OFF", "OMP"),
#         #           labels=c("OMP+OFF", "OMP"), values=c("#494949", "#927080", "#B6B6B6")) +
#         ggtitle("Offloading to GPU, chunk_size: 32\n") +
#         scale_y_continuous(breaks=0:100*10) + 
#         theme_bw() +
#         #theme(legend.position=c(0.89,0.70), legend.title=element_blank())
#         theme(legend.position=c(0.9,0.9), legend.title=element_blank(), plot.title = element_text(size=25))
# 
# (p5 = p5 + scale_fill_grey(start = 0.2, end = 0.9))
# 
# # chunk size: 64
# p6 <- ggplot(subset(df2, y==64), aes(x=x, y=t, fill=cat)) + 
#     geom_bar(stat="identity", position="dodge") +
#     geom_errorbar(aes(ymin=t-t_sd, ymax=t+t_sd),
#                   size=.3,    # Thinner lines
#                   width=.2,
#                   position=position_dodge(.9)) + 
#     xlab("Number of Threads") +
#     ylab("Time(s)") +
#     ggtitle("Offloading to GPU, chunk_size: 64\n") +
#     scale_y_continuous(breaks=0:100*10) +
#     scale_colour_grey(start = 0, end = .9) +
#     theme_bw() +
#     #theme(legend.position=c(0.89,0.70), legend.title=element_blank())
#     theme(legend.position=c(0.9,0.9), legend.title=element_blank(), plot.title = element_text(size=25))
# 
# (p6 = p6 + scale_fill_grey(start = 0.2, end = 0.9)) 
# 
# 
# 
# 
# # multiplot(p1, p2, p3, p4, p5, p6, cols=2)
# pdf(file="no-offloading-chunk-size-16.pdf",family="Helvetica", pointsize=18, width=15,height=10)
# multiplot(p1, cols=1)
# dev.off()
# 
# pdf(file="no-offloading-chunk-size-32.pdf",family="Helvetica", pointsize=18, width=15,height=10)
# multiplot(p2, cols=1)
# dev.off()
# 
# pdf(file="no-offloading-chunk-size-64.pdf",family="Helvetica", pointsize=18, width=15,height=10)
# multiplot(p3, cols=1)
# dev.off()
# 
# pdf(file="offloading-chunk-size-16.pdf",family="Helvetica", pointsize=18, width=15,height=10)
# multiplot(p4, cols=1)
# dev.off()
# 
# pdf(file="offloading-chunk-size-32.pdf",family="Helvetica", pointsize=18, width=15,height=10)
# multiplot(p5, cols=1)
# dev.off()
# 
# pdf(file="offloading-chunk-size-64.pdf",family="Helvetica", pointsize=18, width=15,height=10)
# multiplot(p6, cols=1)
# dev.off()
# 
# 
# 
# # dev.print(pdf,filename="data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-final.pdf");
# 
# # dev.copy2pdf(file = "data-large_dataset-num_threads-1-a-12-dynamic-chunk_size-16-a-64-final.pdf");
# # dev.off ();
# 
