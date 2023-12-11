library(apcluster)
library(Rcpp)
library(dplyr)
sourceCpp('editDistance.cpp')

readSequences = function(fileName) {
    raw = read.delim(fileName, header=FALSE, sep=";", stringsAsFactors = FALSE)
    
    all.lengths = sapply(raw$V1, function(x){ sapply(strsplit(x, ","), as.numeric)})
    all.sets = sapply(raw$V2, function(x){ sapply(strsplit(x, ","), as.numeric)})
    
    sequences = list()
    
    for(seqNo in 1:nrow(raw)) {
        sequence = list()
        lengths = all.lengths[[seqNo]]
        sets = all.sets[[seqNo]]
        
        position = 1
        
        for(setNo in 1:length(lengths)) {
            set = c()
            
            for(reads in 1:lengths[[setNo]]) {
                set = append(set, sets[position])
                position = position + 1
            }
            
            sequence[[setNo]] = set
        }
        
        sequences[[seqNo]] = sequence
    }
    
    sequences
}

pasteSequence = function(s) {
    paste(sapply(s, function(set) { paste0("(", paste(set, collapse = " "), ")") }), collapse = " ")
}

readTags = function(fileName) {
    tags = read.csv(fileName, header = FALSE, sep = " ", col.names = c("id", "tag"))
    
    tags
}

getTopExchangeSequences = function (overflow.sequences, exchange.sequences, overflow.tags, exchange.tags) {
    for(seqNum in 1:length(overflow.sequences)) {
        for(setNum in 1:length(overflow.sequences[[seqNum]])) {
            overflow.sequences[[seqNum]][[setNum]] = overflow.tags[overflow.sequences[[seqNum]][[setNum]], 'tag']
        }
    }
    
    for(seqNum in 1:length(exchange.sequences)) {
        for(setNum in 1:length(exchange.sequences[[seqNum]])) {
            exchange.sequences[[seqNum]][[setNum]] = exchange.tags[exchange.sequences[[seqNum]][[setNum]], 'tag']
        }
    }
    
    all.tags = union(exchange.tags$tag, overflow.tags$tag)
    tags.mapping = data.frame(id=1:length(all.tags), tag=all.tags)
    
    for(seqNum in 1:length(overflow.sequences)) {
        for(setNum in 1:length(overflow.sequences[[seqNum]])) {
            overflow.sequences[[seqNum]][[setNum]] = tags.mapping[tags.mapping$tag %in% overflow.sequences[[seqNum]][[setNum]], 'id']
        }
    }
    
    for(seqNum in 1:length(exchange.sequences)) {
        for(setNum in 1:length(exchange.sequences[[seqNum]])) {
            exchange.sequences[[seqNum]][[setNum]] = tags.mapping[tags.mapping$tag %in% exchange.sequences[[seqNum]][[setNum]], 'id']
        }
    }
    
    top.exchange.sequences = balanceClasses(overflow.sequences, exchange.sequences)
    
    top.exchange.sequences
}

balanceClasses = function(overflow.sequences, exchange.sequences) {
    overflow.new.tags = unique(unlist(overflow.sequences))
    
    overflow_exchange.similarity = data.frame(id = 1:length(exchange.sequences), similarity = sapply(exchange.sequences, function(s) {
        length(intersect(unique(unlist(s)), overflow.new.tags)) / length(unique(unlist(s)))
    }))
    
    top.exchange.ids = overflow_exchange.similarity %>%
        arrange(-similarity) %>%
        top_n(length(overflow.sequences)) %>%
        head(length(overflow.sequences))
    
    top.exchange.sequences = exchange.sequences[top.exchange.ids$id]
    
    top.exchange.sequences
}

getBOWRepresentation = function(dataset.sequences) {
    dataset.tags = sort(unique(unlist(dataset.sequences)))
    
    bow.list = lapply(dataset.sequences, function(s) { dataset.tags %in% unique(unlist(s))*1 })
    
    result = as.data.frame(do.call(rbind, bow.list))
    
    result
}

generateSet = function(setLength, max_i, mu_i, sd_i, isMultiset = FALSE) {
    # pick random items (normal distribution)
    result = round(rnorm(setLength, max_i * mu_i, max_i * sd_i))
    
    if(!isMultiset) {
        result = unique(result)
        
        while(length(result) != setLength) {
            missingItems = round(rnorm(setLength - length(result), max_i * mu_i, max_i * sd_i))
            
            result = unique(append(result, missingItems))
        }
    }
    
    result
}

generateSet_CRU = function(setLength, max_i, mu_i, sd_i, currSeq) {
    result = setdiff(round(rnorm(setLength, max_i * mu_i, max_i * sd_i)), unique(unlist(currSeq)))
    
    if(length(currSeq) > 0) {
        while(length(result) < setLength) {
            cumulatedDecay = 1
            currOldItems = c()
            for(k in length(currSeq):1) {
                currNoOldItems = ceiling(length(currSeq[[k]]) * cumulatedDecay)
                
                currOldItems = union(currOldItems, sample(currSeq[[k]], currNoOldItems))
                
                cumulatedDecay = cumulatedDecay * decay
            }
            
            result = union(result, sample(currOldItems, min(setLength - length(result),
                                                                  length(currOldItems))))
        }
    }
    
    result
}

generateSequence = function(len, max_s, max_i, mu_s, sd_s, mu_i, sd_i, isMultiset = FALSE, isCRU = FALSE, decay = 0.7, mu_i_shift = 0) {
    result = list()
    
    for(j in 0:(len - 1)) {
        # pick random number of items in current set (normal distribution)
        curr_s = round(rnorm(1, max_s * mu_s, max_s * sd_s))
        
        curr_mu_i = mu_i - mu_i_shift / 2 + mu_i_shift * j / (len - 1)
        
        if(dplyr::between(curr_s, 0, max_s + 1)) {
            currItems = c()
            
            if(isCRU) {
                currItems = generateSet_CRU(curr_s, max_i, curr_mu_i, sd_i, result)
            } else {
                currItems = generateSet(curr_s, max_i, curr_mu_i, sd_i, isMultiset)
            }
            
            currItems = Filter(function(x) { dplyr::between(x, 0, max_i + 1) }, currItems)
            
            result = rlist::list.append(result, currItems)
        }
    }
    
    result
}

generateSequences = function(noSequences, max_l, max_s, max_i, mu_l, sd_l, mu_s, sd_s, mu_i, sd_i, isMultiset = FALSE, isCRU = FALSE, decay = 0.7, mu_i_shift = 0) {
    sequences = list()
    
    for(i in 1:noSequences) {
        curr_l = round(rnorm(1, max_l * mu_l, max_l * sd_l))
        
        if(dplyr::between(curr_l, 0, max_l + 1)) {
            currSeq = generateSequence(curr_l, max_s, max_i, mu_s, sd_s, mu_i, sd_i, isMultiset, isCRU, decay, mu_i_shift)
            
            sequences = rlist::list.append(sequences, currSeq)
        }
    }
    
    sequences
}

generateDataset = function(noSequencesPerClass,
                           c1_max_l, c2_max_l,
                           c1_max_s, c2_max_s,
                           c1_max_i, c2_max_i,
                           c1_mu_l, c2_mu_l, c1_sd_l, c2_sd_l,
                           c1_mu_s, c2_mu_s, c1_sd_s, c2_sd_s,
                           c1_mu_i, c2_mu_i, c1_sd_i, c2_sd_i,
                           isMultiset = FALSE, isCRU = FALSE,
                           c1_decay = 0.7, c2_decay = 0.7, mu_i_shift = 0) {
    
    class1Sequences = generateSequences(noSequencesPerClass, c1_max_l, c1_max_s, c1_max_i, c1_mu_l, c1_sd_l, c1_mu_s, c1_sd_s, c1_mu_i, c1_sd_i, isMultiset, isCRU, c1_decay, mu_i_shift)
    class2Sequences = generateSequences(noSequencesPerClass, c2_max_l, c2_max_s, c2_max_i, c2_mu_l, c2_sd_l, c2_mu_s, c2_sd_s, c2_mu_i, c2_sd_i, isMultiset, isCRU, c2_decay, -mu_i_shift)
    
    dataset = list(sequences = append(class1Sequences, class2Sequences),
                   classes = as.factor(c(rep(0, length(class1Sequences)), rep(1, length(class2Sequences)))))
    
    dataset
}

runComparativeKnnExperiment = function(dataset, k, repeats, run) {
    
    accuracies = data.frame(accuracy=c(), method=c(), rep=c(), run=c())

    dataset.bow = getBOWRepresentation(dataset$sequences)
    
    M.bow = as.matrix(dist(dataset.bow, method = "binary", upper = TRUE, diag = TRUE))
    
    M.edit = getEditDistanceMatrix(dataset$sequences, verbose = FALSE)
    
    #M.pedit = getPartialEditDistanceMatrix(dataset$sequences, verbose = FALSE)

    knn.bow.accuracies = c()
    knn.edit.accuracies = c()
    #knn.pedit.accuracies = c()
    
    for(iteration in 1:repeats) {
        index = createDataPartition(dataset$classes, p=0.7, list=FALSE)
        
        knn.bow = knn(k, M.bow, index, dataset$classes)
        knn.bow.accuracies = append(knn.bow.accuracies, knn.bow$accuracy)
        
        knn.edit = knn(k, M.edit, index, dataset$classes)
        knn.edit.accuracies = append(knn.edit.accuracies, knn.edit$accuracy)
        
        #knn.pedit = knn(k, M.pedit, index, dataset$classes)
        #knn.pedit.accuracies = append(knn.pedit.accuracies, knn.pedit$accuracy)
    }
    
    accuracies = rbind(accuracies, data.frame(accuracy=knn.bow.accuracies, method="bow", rep=1:repeats, run=run))
    
    accuracies = rbind(accuracies, data.frame(accuracy=knn.edit.accuracies, method="edit", rep=1:repeats, run=run))
    
    #accuracies = rbind(accuracies, data.frame(accuracy=knn.pedit.accuracies, method="pedit", rep=1:repeats, run=run))
    
    accuracies
}

runComparativeClusteringExperiment = function(dataset, rep, run) {
    
    results = data.frame(accuracy=c(), method=c(), rep=c(), run=c())
    
    dataset.bow = getBOWRepresentation(dataset$sequences)
    
    M.bow = as.matrix(dist(dataset.bow, method = "binary", upper = TRUE, diag = TRUE))
    
    M.edit = getEditDistanceMatrix(dataset$sequences, verbose = FALSE)
    
    bow.results = c()
    edit.results = c()
    
    #result.bow = fastkmed(M.bow, 2, 50)
    #bow$ari = aricode::ARI(dataset$classes, result.bow$cluster-1)
    result.bow = apclusterK(-M.bow, K = 2)
    bow.ari = aricode::ARI(dataset$classes, result.bow@idx)
    bow.results = append(bow.results, bow.ari)
    
    #result.edit = fastkmed(M.edit, 2, 50)
    #edit.ari = aricode::ARI(dataset$classes, result.edit$cluster-1)
    result.edit = apclusterK(-M.edit, K = 2)
    edit.ari = aricode::ARI(dataset$classes, result.edit@idx)
    edit.results = append(edit.results, edit.ari)
    
    results = rbind(results, data.frame(ari=bow.results, method="bow", rep=rep, run=run))
    
    results = rbind(results, data.frame(ari=edit.results, method="edit", rep=rep, run=run))
    
    results
}
