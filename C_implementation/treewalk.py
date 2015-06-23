# treewalk.py
# Ronald L. Rivest
# 9/14/07
# Compute hash of sequence D[0..n-1]
# by first applying leaf_hash to each D[i]
# and then applying combine_hash(x,y) to each
# pair to reduce number of values by two, repeatedly
# until only one value is left. (Complicated way of
# saying that we are computing up a binary tree....)
# Hash of an empty subtree (no leaves) is zero by definition.

def H(i,k):
    """
    Compute level-k hash function on D[i..i+(2**k)-1]
    k = level of hash; k = 0 for leaf, parent has level = 1 + level(child)
    k = Infinity for initial call.
    Assume X(i) == True iff D[i] exists (i.e. i is not past EOF).
    In sequential implementation, X called on non-decreasing values for i.
    """
    if not X(i):
        return 0                     # empty subtree
    if k == 0:
        return leaf_hash(D[i])       # leaf
    if k != Infinity:
        # CILK spawn:
        L = H(i,k-1)                 # left subtree
        # CILK spawn:
        R = H(i+2**(k-1),k-1)        # right subtree
        # CILK sync:
        return combine_hash(L,R)     # combine them
    else:
        # determine correct level k dynamically
        k = 0
        L = H(i,k)
        while X(i+2**k):
            # now L = hash on D[i..i+2**k-1]
            R = H(i+2**k,k)
            L = combine_hash(L,R)
            k += 1
        return L

def leaf_hash(D):
    """ Dummy leaf_hash just returns input """
    return D

def combine_hash(L,R):
    """ Dummy combine_hash just returns sum of inputs """
    return L+R

# Global variable array D is input to be hashed
D = range(20)

def X(i):
    """ Test if D[i] exists """
    print "X",i
    return i<len(D)

Infinity = 1000

# Test call
print H(0,Infinity)
