;; needed variables (registers) for gc

;; register values that must be predefined
;; set these when testing gc standalone in emulator
(defreg gc-maxblocks #x70) 	;; total memory size
(defreg gc-spaces #x71)		;; number of spaces we'll divide the memory in
(defreg gc-startofmem #x76)	;; start of variable address space

;; registers set by evaluator before invoking gc
;; set these when testing gc standalone in emulator
(defreg gc-rootptr #x78)	;; pointer to topmost object! hopefully
				;; there will be only one

;; registers set by init, keep these throughout
(defreg gc-spacesize #x72) 	;; size of each space: maxblocks / spaces
(defreg gc-sup #x73) 		;; first address beyond legal space:
				;; spaces * spacesize (NB: can be lower than
				;; maxblocks)
(defreg gc-gcspace #x74)	;; start of gc exclusize space, sup - spacesize

;; registers used by everyone
(defreg gc-firstfree #x75)	;; first free memory block
				;; (might exist already in other microcode)

;; scratch registers, can be used when gc is not running (but gc will
;; destroy them)

(defreg gc-1 #x80)		;; temp
(defreg gc-vi #x83)
(defreg gc-t #x84)		;; ptr-rev
(defreg gc-x #x85)		;; ptr-rev
(defreg gc-y #x86)		;; ptr-rev
(defreg gc-v #x87)		;; ptr-rev
(defreg gc-followp #x88)	;; ptr-rev
(defreg gc-cannext #x89)	;; ptr-rev
(defreg gc-canprev #x8a)	;; ptr-rev

(defreg gc-temp #x8b)
(defreg gc-mem #x8c)
(defreg gc-from #x84)		;; at this stage we're no longer using
(defreg gc-to #x85)		;; some of the above variables
(defreg gc-val #x86)
(defreg gc-temp2 #x87)

;;(def-gc free #x00)		;; eirik must do eirik-magic to make
;;(def-gc used #x01)		;; these work as i want to
(defparameter +gc-free+ #x00)
(defparameter +gc-used+ #x01)

;; initialization of gc
;; call this before evaluator is run for the first time

(defun write-microprogram (&key (output-format :simulator))
  (with-assembly ("/tmp/microcode" :output-format output-format)
    :gc-init

;; for testing, delete later
    (%set-datum-imm $one 1)
    (%set-type-imm $one +type-int+)
    (%set-datum-imm $zero 0)
    (%set-type-imm $zero +type-int+)

;; temporarily commented out for testing, as this is set via register file
    ;; MAGIC CONSTANTS, define max memory size here
;;    (%set-datum-imm $gc-maxblocks (* 1048576 2))
;;    (%set-type-imm $gc-maxblocks +type-int+)

    ;; number of spaces
;;    (%set-datum-imm $gc-spaces 10)
;;    (%set-type-imm $gc-spaces +type-int+)

    ;; set start of gcspace (allowed heap space)
;;    (%set-datum-imm $gc-firstfree 123) ;; TODO replace with proper number
;;    (%set-type-imm $gc-firstfree +type-int+)



    ;; calculate spacesize
    (%div* $gc-spacesize $gc-maxblocks $gc-spaces)

    ;; find maximal address + 1 (sup)
    (%mul* $gc-sup $gc-spaces $gc-spacesize)

    ;; find start of gcspace
    (%sub* $gc-gcspace $gc-sup $gc-spacesize)


;; do not want to ret while testing
;;    (ret)

    ;; garbagecollect - the entry point

    :gc-garbagecollect
    ;; mark everything as free
    (%cpy $gc-vi $gc-startofmem)


    :gc-loop1
    ;; load the contents of memory address (contained in gc-vi)
    ;; into register gc-1)
    ;; loop tested in emu: OK
    (%load $gc-1 $gc-vi 0)
    (%set-gc-imm $gc-1 +gc-free+)
    (%store $gc-1 $gc-vi 0)
    (%add $gc-vi $one)
    (%cmp-datum $gc-vi $gc-gcspace)
    (branchimm-false :gc-loop1)

    ;; pointer reversal! skrekk og gru
    ;; algorithm based on tiger book

    ;; start of pointer reversal
    ;; the algorithm is able to "slide" sideways without reversing
    ;; underlying pointers within the following structures
    ;; CONS - SNOC
    ;; ARRAY - PTR - ... - PTR - SNOC

    ;; CONS/ARRAY are identified as start of structure
    ;; SNOC is identified as end of structure

    (%set-type-imm $gc-t +type-int+)
    (%set-datum-imm $gc-t 0)
    (%cpy $gc-x $gc-rootptr)


    :gc-mainreverseloop

    ;; visit current block
    ;; gc-x holds current memory address
    ;; gc-y will hold the contents of the address
    ;; address 0x14
    (%load $gc-y $gc-x 0)
    (%set-gc-imm $gc-y +gc-used+)
    (%store $gc-y $gc-x 0)

    (%cpy $gc-followp $zero)
    (%cpy $gc-cannext $zero)
    (%cpy $gc-canprev $zero)

    ;; if memory address x contains a pointer, and it points to
    ;; a memory address marked as gc-free (ie. unvisited so far)
    ;; set followp to true (1)
    ;; the following types have pointers: CONS PTR SNOC
    ;; tested OK for case: cell is pointer, cell pointed to is unvisited
    (%cmp-type-imm $gc-y +type-cons+)
    (branchimm :gc-setfollowp)
    (%cmp-type-imm $gc-y +type-snoc+)
    (branchimm :gc-setfollowp)
    (%cmp-type-imm $gc-y +type-ptr+)
    (branchimm :gc-setfollowp)
    ;; if any other types contain pointers, add them here!
    (jump-imm :gc-afterfollowp)

    :gc-setfollowp

    ; copy from memory location $gc-y, into $gc-v
    (%load $gc-v $gc-y 0)
    (%cmp-gc-imm $gc-v +gc-used+)
    (branchimm :gc-afterfollowp)
    (%cpy $gc-followp $one)

    :gc-afterfollowp

    ;; if we aren't at the last position of a memory structure spanning
    ;; several addresses and the next adress is free, set cannext=1
    ;; currently, these types can occur at the non-end: CONS, ARRAY, PTR
    ;; tested OK for case: cell is not end of structure, next cell is unvisited
    (%cmp-type-imm $gc-y +type-cons+)
    (branchimm :gc-setcannext)
    (%cmp-type-imm $gc-y +type-array+)
    (branchimm :gc-setcannext)
    (%cmp-type-imm $gc-y +type-ptr+)
    (branchimm :gc-setcannext)
    (jump-imm :gc-aftercannext)	
    :gc-setcannext
    (%cpy $gc-1 $gc-x) ;; check is address x+1 is unvisited
    (%add $gc-1 $one)
    (%load $gc-1 $gc-1 0) ;; lykkebo says this is safe
    (%cmp-gc-imm $gc-1 +gc-used+)
    (branchimm :gc-aftercannext)
    (%cpy $gc-cannext $one)

    :gc-aftercannext

    ;; if we aren't at the first position of a memory structure spanning
    ;; several addresses, set canprev=1
    ;; the following types can occur at the non-start: SNOC PTR
    ;; tested OK for case: cell is not end of structure
    (%cmp-type-imm $gc-y +type-snoc+)
    (branchimm :gc-setcanprev)
    (%cmp-type-imm $gc-y +type-ptr+)
    (branchimm :gc-setcanprev)
    (jump-imm :gc-aftercanprev)
    :gc-setcanprev	
    (%cpy $gc-canprev $one)

    :gc-aftercanprev

    ;; do stuff based on followp, cannext, canprev
    ;; follow the pointer we're at, and reverse the pointer
    ;; =====> addr 0x39 <======
    (%cmp-datum $gc-followp $one)
    (branchimm-false :gc-afterfollowedp)
    (%cpy $gc-temp $gc-x)
    (%load $gc-mem $gc-temp 0)
    (%set-datum $gc-mem $gc-t)
    (%store $gc-mem $gc-temp 0)
    (%cpy $gc-t $gc-temp)
    (%set-datum $gc-x $gc-y)
    (jump-imm :gc-mainreverseloop)

    :gc-afterfollowedp

    ;; move to next memory location
    (%cmp-datum $gc-cannext $one)
    (branchimm-false :gc-aftercouldnext)
    (%add $gc-x $one)
    (jump-imm :gc-mainreverseloop)

    :gc-aftercouldnext

    ;; move to previous memory location
    (%cmp-datum $gc-canprev $one)
    (branchimm-false :gc-aftercouldprev)
    ;; address 0x48
    (%sub $gc-x $one)
    (jump-imm :gc-mainreverseloop)

    :gc-aftercouldprev

    ;; all cases exhausted: follow pointer back and reverse the reversal
    (%cmp-datum $gc-t $zero)
    (branchimm :gc-donepointerreversal)
    (%load $gc-temp $gc-t 0) ;; read from address gc-t, into gc-temp
    (%cpy $gc-mem $gc-temp)
    (%set-datum $gc-mem $gc-x)
    (%store $gc-mem $gc-t 0) ;; restore the correct pointer in gc-t
    (%cpy $gc-x $gc-t)
    (%cpy $gc-t $gc-temp)
    (jump-imm :gc-mainreverseloop)

    :gc-donepointerreversal

    ;; end of pointer reversal routine, from this point on,
    ;; all variables marked with "ptr-rev" are free for other use
    ;; ========> address 0x52 <=======

    ;; find the first address that's going to be copied
    (%cpy $gc-from $gc-startofmem)
    (%cpy $gc-to $gc-startofmem)
    :gc-findchangeloop
    (%cmp-datum $gc-from $gc-gcspace)
    (branchimm :gc-findnextloop)
    (%load $gc-mem $gc-from 0)
    (%cmp-gc-imm $gc-mem +gc-free+)
    (branchimm :gc-findnextloop)
    (%add $gc-from $one)
    (%add $gc-to $one)
    (jump-imm :gc-findchangeloop)
    :gc-findnextloop
    ;; we found the first hole, find the next element
    (%cmp-datum $gc-from $gc-gcspace)
    (branchimm :gc-copyloop)
    (%load $gc-mem $gc-from 0)
    (%cmp-gc-imm $gc-mem +gc-used+)
    (branchimm :gc-copyloop)
    (%add $gc-from $one)
    (jump-imm :gc-findnextloop)

    ;; copy the stuff
    ;; address 0x63

    :gc-copyloop

    (%load $gc-mem $gc-from 0) ;; read from gc-from into gc-mem
    (%cmp-gc-imm $gc-mem +gc-used+)
    (branchimm-false :gc-notrans)
    ;; put address in translation table
    (%cpy $gc-temp $gc-mem)
    (%div* $gc-mem $gc-from $gc-spacesize)
    (%mul $gc-mem $gc-spacesize)
    (%cpy $gc-temp2 $gc-from)
    (%sub $gc-temp2 $gc-mem)
    (%add $gc-temp2 $gc-gcspace)
    (%store $gc-to $gc-temp2 0) ;; write to-address to gc-temp2
    ;; copy
    (%load $gc-mem $gc-from 0)
    (%store $gc-temp $gc-to 0)
    (%add $gc-to $one)
    :gc-notrans
    (%add $gc-from $one)

    (%div* $gc-temp $gc-from $gc-spacesize)
    (%mul $gc-temp $gc-spacesize)
    (%sub* $gc-temp2 $gc-from $gc-temp)
    (%cmp-datum $gc-temp2 $zero)
    (branchimm-false :gc-noconvert)

    ;; translate pointers
    ;; address 0x79
    :gc-transloop
    (%cpy $gc-vi $gc-startofmem)
    :gc-transloop2
    (%load $gc-mem $gc-vi 0) ;; read from address gc-i and put into gc-mem
    (%cmp-gc-imm $gc-mem +gc-used+)
    (branchimm-false :gc-nexttrans)
    (%cmp-type-imm $gc-mem +type-ptr+)
    (branchimm :gc-isptr)
    (%cmp-type-imm $gc-mem +type-cons+)
    (branchimm :gc-isptr)
    (%cmp-type-imm $gc-mem +type-snoc+)
    (branchimm :gc-isptr)
    (jump-imm :gc-nexttrans)

    :gc-isptr
;; check that these branches work
;; OK for mem>=from-spacesize og mem<from
    (%sub* $gc-temp $gc-from $gc-spacesize)
    (%cmp-datum $gc-mem $gc-temp)
    (%branch* $zero :gc-nexttrans N)
    (%cmp-datum $gc-mem $gc-from)
    (%branch* $zero :gc-nexttrans (not N))

    ;; TODO replace the following section whenever (if) we get a
    ;; modulo instruction!

    ;; calculate gcspace+val%spacesize, put in val
    (%cpy $gc-val $gc-mem)
    (%div* $gc-temp $gc-val $gc-spacesize)
    (%mul $gc-temp $gc-spacesize)
    (%sub* $gc-temp2 $gc-val $gc-temp)
    (%add* $gc-val $gc-temp2 $gc-gcspace)
    (%load $gc-temp2 $gc-val 0)
    (%set-datum $gc-mem $gc-temp2)
    (%store $gc-mem $gc-vi 0)

    :gc-nexttrans
    (%add $gc-vi $one)
    (%cmp $gc-vi $gc-to)
    (branchimm-false :gc-noto)
    (%cpy $gc-vi $gc-from)
    :gc-noto
    (%cmp $gc-vi $gc-gcspace)
    (branchimm-false :gc-transloop2)

    :gc-noconvert

    (%cmp-datum $gc-from $gc-gcspace)
    (branchimm-false :gc-copyloop)

    ;; whee, gc is finished and we have a new address where
    ;; free space starts
    (%cpy $gc-firstfree $gc-to)

;; dummy-labels
:ret-error
:call-error
;; address 0x9E (as of now)

    (ret)))
	
