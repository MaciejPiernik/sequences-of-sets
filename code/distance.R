
editDistance = function(s1, s2) {
    M = matrix(nrow = length(s1) + 1, ncol = length(s2) + 1)
    
    M[1, 1] = 0
    
    for(i in 2:(length(s1) + 1)) {
        M[i, 1] = i - 1
    }
    
    for(j in 2:(length(s2) + 1)) {
        M[1, j] = j - 1
    }
    
    for(i in 2:(length(s1) + 1)) {
        for(j in 2:(length(s2) + 1)) {
            
            M[i, j] = min(M[i - 1, j] + 1,
                          M[i, j - 1] + 1,
                          M[i - 1, j - 1] + jaccard(s1[[i - 1]], s2[[j - 1]]))
        }
            
    }
        
    M[length(s1) + 1, length(s2) + 1]
}

jaccard = function(set1, set2) {
    1 - (length(intersect(set1, set2)) / length(union(set1, set2)))
}