library(Rcpp)
library(doParallel)
library(foreach)

source("util.R")
source("classification.util.R")
sourceCpp('editDistance.cpp')

N = 500

max_l = 40
mu_l = 0.5
sd_l = 0.1

max_s = 40
mu_s = 0.5
sd_s = 0.1

max_i = 500
mu_i = 0.5
sd_i = 0.1

decay = 0.5
isCRU = FALSE
isMultiset = FALSE
mu_i_shift = 0

repeats = 20
k = 3

accuracies = data.frame()

cores = detectCores()
cl <- makeCluster(cores[1]-1)
registerDoParallel(cl)

accuracies <- foreach(i=21:30, .combine=rbind, .packages=c("Rcpp", "caret"), .noexport = "getEditDistanceMatrix") %dopar% {
    sourceCpp('editDistance.cpp')
    
    delta <- i * 0.01
    
    dataset = generateDataset(N, max_l, max_l, max_s, max_s, max_i, max_i,
                              mu_l, mu_l, sd_l, sd_l, mu_s - delta, mu_s + delta, sd_s, sd_s,
                              mu_i, mu_i, sd_i, sd_i, isMultiset, isCRU, decay, decay, mu_i_shift)
    
    run.accuracies = runComparativeKnnExperiment(dataset, k, repeats, delta)
    
    write.table(run.accuracies, paste0("../results/N=", N, "_mu_s_diff=", delta, ".csv"), append = TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE)
    
    run.accuracies
}

stopCluster(cl)

write.table(accuracies, paste0("../results/N=", N, "_mu_s", ".csv"), append = TRUE, quote = FALSE, row.names = FALSE, col.names = FALSE)
