The file tags-mathoverflow-seqs.txt file is a list of sequences.

Each line of the file is a sequence with the following form:
size1,size2,…,sizeN;elmt1,elmt2,…,elmtM

- size1,size2,…,sizeN are the number of elements in the N sets in the sequence.

- elmt1,elmt2,…,elmtM are the M elements (given as integer identifiers) in the N
  sets in order. The first size1 elements are in the first set, the next size2
  elements are in the second set, and so on. For each sequence,
  size1 + size2 + … + sizeN = M.

The file tags-mathoverflow-element-labels.txt contain labels for the elements.

This dataset is a collection of sequences of sets. Stack exchange is a
collection of question-and-answer web sites. Users post questions and annotate
them with up to 5 tags. In this dataset, each sequence is the time-ordered set
of tags applied to questions asked by a user on MathOverflow. All sequences
contain at least 10 sets, and only sets of size at most 5 are considered.
