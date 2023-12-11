#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
double jaccard(NumericVector set1, NumericVector set2) {
    return 1.0 - (double)intersect(set1, set2).length() / (double)union_(set1, set2).length();
}

// [[Rcpp::export]]
double editDistance(List s1, List s2) {
    NumericMatrix m(s1.length() + 1, s2.length() + 1);
    
    
    for(int i = 1; i < s1.length() + 1; i++) {
        m(i, 0) = i;
    }
    
    for(int j = 1; j < s2.length() + 1; j++) {
        m(0, j) = j;
    }
    
    for(int i = 1; i < s1.length() + 1; i++) {
        for(int j = 1; j < s2.length() + 1; j++) {

            NumericVector tmp = NumericVector::create(m(i - 1, j) + 1,
                                 m(i, j - 1) + 1,
                                 m(i - 1, j - 1) + jaccard(s1[i - 1], s2[j - 1]));
            
            m(i, j) = min(tmp);
        }
        
    }
    
    return m(s1.length(), s2.length());
}

// [[Rcpp::export]]
NumericMatrix getEditDistanceMatrix(List sequences, bool verbose = true) {
    int noSequences = sequences.length();
    NumericMatrix m(noSequences);
    
    for(int i = 0; i < noSequences; i++) {
        m(i, i) = 0;
        
        if(verbose) {
            Rprintf("\rProgress: %.2f %%", (float)i / noSequences * 100.0);
        }
        
        for(int j = i + 1; j < noSequences; j++) {
            m(i, j) = editDistance(sequences[i], sequences[j]);
            m(j, i) = m(i, j);
        }
    }
    
    return m;
}


// [[Rcpp::export]]
double partialEditDistance(List s1, List s2) {
    NumericMatrix m(s1.length() + 1, s2.length() + 1);
    
    
    for(int i = 1; i < s1.length() + 1; i++) {
        m(i, 0) = 0;
    }
    
    for(int j = 1; j < s2.length() + 1; j++) {
        m(0, j) = j;
    }
    
    for(int i = 1; i < s1.length() + 1; i++) {
        for(int j = 1; j < s2.length() + 1; j++) {
            
            NumericVector tmp = NumericVector::create(m(i - 1, j),
                                                      m(i, j - 1) + 1,
                                                      m(i - 1, j - 1) + jaccard(s1[i - 1], s2[j - 1]));
            
            m(i, j) = min(tmp);
        }
        
    }
    
    return m(s1.length(), s2.length());
}

// [[Rcpp::export]]
NumericMatrix getPartialEditDistanceMatrix(List sequences, bool verbose = true) {
    int noSequences = sequences.length();
    NumericMatrix m(noSequences);
    
    for(int i = 0; i < noSequences; i++) {
        m(i, i) = 0;
        
        if(verbose) {
            Rprintf("\rProgress: %.2f %%", (float)i / noSequences * 100.0);
        }
        
        for(int j = i + 1; j < noSequences; j++) {
            double left = partialEditDistance(sequences[i], sequences[j]);
            double right = partialEditDistance(sequences[j], sequences[i]);
            m(i, j) = std::min(left, right);
            m(j, i) = m(i, j);
        }
    }
    
    return m;
}
