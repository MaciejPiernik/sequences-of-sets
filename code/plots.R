library(ggplot2)

accuracies = read.table("../results/N=500_mu_i_shift.csv", header = FALSE)
colnames(accuracies) = c("accuracy", "method", "rep", "run")

ggplot(accuracies, aes(x = run, y = accuracy, color = method)) +
    geom_point() +
    geom_smooth() +
    theme_bw() +
    xlab("absolute mean item id spread") +
    scale_color_manual(name = "accuracy", values = c("bow" = "#004488", "edit" = "#DDAA33"))
