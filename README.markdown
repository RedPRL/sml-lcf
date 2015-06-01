### A general-purpose library for LCF refiners

The standard mode of use of this library is to implement the `LCF` signature by
specifying two things:

1. A data-structure for goals.
2. A data structure for evidence.

With the structure that you have implemented, the standard LCF tacticals may be
deployed off the shelf using the `Tacticals` structure.

In case the `evidence` type is non-trivial, then this constitues an
implementation of "LCF with validations"; in case the `evidence` type is
subsingleton, then this is plain LCF.
