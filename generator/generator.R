
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

generateSet_CRU = function(setLength, max_i, mu_i, sd_i, currSeq, decay) {
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

generateSequence = function(len, max_s, max_i, mu_s, sd_s, mu_i, sd_i, isMultiset = FALSE, decay = 0.7, mu_i_shift = 0) {
    result = list()
    
    for(j in 0:(len - 1)) {
        # pick random number of items in current set (normal distribution)
        curr_s = round(rnorm(1, max_s * mu_s, max_s * sd_s))
        
        curr_mu_i = mu_i - mu_i_shift / 2 + mu_i_shift * j / (len - 1)
        
        if(dplyr::between(curr_s, 0, max_s + 1)) {
            currItems = c()
            
            if(decay != 0) {
                currItems = generateSet_CRU(curr_s, max_i, curr_mu_i, sd_i, result, decay)
            } else {
                currItems = generateSet(curr_s, max_i, curr_mu_i, sd_i, isMultiset)
            }
            
            currItems = Filter(function(x) { dplyr::between(x, 0, max_i + 1) }, currItems)
            
            result = rlist::list.append(result, currItems)
        }
    }
    
    result
}

generateSequences = function(noSequences, max_l, max_s, max_i, mu_l, sd_l, mu_s, sd_s, mu_i, sd_i, isMultiset = FALSE, decay = 0.7, mu_i_shift = 0) {
    sequences = list()
    
    for(i in 1:noSequences) {
        curr_l = round(rnorm(1, max_l * mu_l, max_l * sd_l))
        
        if(dplyr::between(curr_l, 0, max_l + 1)) {
            currSeq = generateSequence(curr_l, max_s, max_i, mu_s, sd_s, mu_i, sd_i, isMultiset, decay, mu_i_shift)
            
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

plotRecency = function(sequences) {
    listScores = lapply(sequences, function(s) {
        singleScores = rep(0, 10)
        for(i in 1:min(10, length(s) - 1)) {
            singleScores[i] = 1 - jaccard(s[[length(s)]], s[[length(s) - i]])
        }
        
        singleScores
    })
    
    scores = data.frame(matrix(unlist(listScores), ncol = 10, byrow = TRUE))
    
    p = ggplot() +
        geom_line(data = data.frame(k=1:10, score = apply(scores, 2, mean)), mapping = aes(x=k, y=score)) +
        ylab("relative Jaccard coefficient") +
        scale_color_distiller(palette = "Blues") +
        scale_x_continuous(breaks = 1:10) +
        theme_bw()
        
    p
}

jaccard = function(set1, set2) {
    1 - (length(intersect(set1, set2)) / length(union(set1, set2)))
}
