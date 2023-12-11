The file contact-high-school-seqs.txt file is a list of sequences.

Each line of the file is a sequence with the following form:
size1,size2,…,sizeN;elmt1,elmt2,…,elmtM

- size1,size2,…,sizeN are the number of elements in the N sets in the sequence.

- elmt1,elmt2,…,elmtM are the M elements (given as integer identifiers) in the N
  sets in order. The first size1 elements are in the first set, the next size2
  elements are in the second set, and so on. For each sequence,
  size1 + size2 + … + sizeN = M.

This dataset is a collection of sequences of sets. The sets are constructed from
interactions recorded by wearable sensors in a high school. The sensors record
proximity-based contacts every 20 seconds. There is one sequence of sets per
person, and we consider the set of individuals that a person comes into contact
within each 20 second interval to be a set (only nonempty sets are considered;
some intervals contain no interactions). All sequences contain at least 10 sets,
and only sets of size at most 5 are considered.

