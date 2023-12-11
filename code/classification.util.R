library(caret)
source("https://raw.githubusercontent.com/ggrothendieck/gsubfn/master/R/list.R")

splitDataset <- function(dataset, splitRatio) {
    index = createDataPartition(dataset$Class, p=splitRatio, list=FALSE)
    trainSet = dataset[ index,]
    testSet = dataset[-index,]
    
    list(train=trainSet, test=testSet)
}

trainClassifier <- function(dataset, classifier, folds, repeats) {
    fitControl = trainControl(method = "repeatedcv",
                              number = folds,
                              repeats = repeats)
    
    capture.output(
        if(classifier == "multinom") {
            fit = train(x = dataset[!names(dataset) %in% "Class"],
                        y = dataset[, "Class"],
                        method = classifier,
                        MaxNWts = 10000000,
                        trControl = fitControl,
                        tuneLength = 10)
        } else {
            fit = train(x = dataset[!names(dataset) %in% "Class"],
                        y = dataset[, "Class"],
                        method = classifier,
                        trControl = fitControl,
                        tuneLength = 10)
            
        }
    )
    
    fit
}

evaluateClassifier <- function(fit, testSet) {
    predictions = predict.train(object=fit, testSet[!names(testSet) %in% "Class"], type="raw")
    
    confusionMatrix(predictions, testSet[, "Class"])
}

knn <- function(k, M, inTraining, classes) {
    result = list()
    
    result$predictions = as.numeric(apply(M[-inTraining, inTraining], 1, function(d) {
        top.k.dist = sort(d)[2:(k+1)]
        top.k.idx = which(d %in% top.k.dist)
        names(which.max((table(classes[inTraining][top.k.idx]))))
    }))
    
    result$accuracy = sum((result$predictions == classes[-inTraining])*1) / length(classes[-inTraining])
    
    result
}
