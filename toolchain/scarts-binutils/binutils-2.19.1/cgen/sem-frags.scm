; Semantic fragments.
; Copyright (C) 2000, 2009 Red Hat, Inc.
; This file is part of CGEN.
; See file COPYING.CGEN for details.

; Background info:
; Some improvement in pbb simulator efficiency is obtained in cases like
; the ARM where for example operand2 computation is expensive in terms of
; cpu cost, code size, and subroutine call overhead if the code is put in
; a subroutine.  It could be inlined, but there are numerous occurences
; resulting in poor icache usage.
; If the computation is put in its own fragment then code size is reduced
; [improving icache usage] and subroutine call overhead is removed in a
; computed-goto simulator [arguments are passed in machine generated local
; variables].
;
; The basic procedure here is to:
; - break all insns up into a set of statements
;   This is either one statement in the case of insns that don't begin with a
;   sequence, or a list of statements, one for each element in the sequence.
; - find a profitable set of common leading statements (called the "header")
;   and a profitable set of common trailing statements (called the "trailer")
;   What is "profitable" depends on
;   - how expensive the statement is
;   - how long the statement is
;   - the number of insns using the statement
;   - what fraction of the total insn the statement is
; - rewrite insn semantics in terms of the new header and trailer fragments
;   plus a "middle" part that is whatever is left over
;   - there is always a header, the middle and trailer parts are optional
;   - cti insns require a header and trailer, though they can be the same
;     fragment
;
; TODO:
; - check ARM orr insns which come out as header, tiny middle, trailer
;   - the tiny middle seems like a waste (combine with trailer?)
; - there are 8 trailers consisting of just `nop' for ARM
; - rearranging statements to increase number and length of common sets
; - combine common middle fragments
; - parallel's not handled yet (only have to handle parallel's at the
;   top level)
; - insns can also be split on timing-sensitive boundaries (pipeline, memory,
;   whatever) though that is not implemented yet.  This may involve rtl
;   additions.
;
; Usage:
; - call sim-sfrag-init! first, to initialize
; - call sim-sfrag-analyze-insns! to create the semantic fragments
; - afterwards, call
;   - sim-sfrag-insn-list
;   - sim-sfrag-frag-table
;   - sim-sfrag-usage-table
;   - sim-sfrag-locals-list

; Statement computation.

; Set to #t to collect various statistics.

(define -stmt-stats? #f)

; Collection of computed stats.  Only set if -stmt-stats? = #t.

(define -stmt-stats #f)

; Collection of computed statement data.  Only set if -stmt-stats? = #t.

(define -stmt-stats-data #f)

; Create a structure recording data of all statements.
; A pair of (next-ordinal . table).

(define (-stmt-data-make hash-size)
  (cons 0 (make-vector hash-size nil))
)

; Accessors.

(define (-stmt-data-table data) (cdr data))
(define (-stmt-data-next-num data) (car data))
(define (-stmt-data-set-next-num! data newval) (set-car! data newval))
(define (-stmt-data-hash-size data) (vector-length (cdr data)))

; A single statement.
; INSN semantics either consist of a single statement or a sequence of them.

(define <statement>
  (class-make '<statement> nil
	      '(
		; RTL code
		expr

		; Local variables of the sequence `expr' is in.
		locals

		; Ordinal of the statement.
		num

		; Costs.
		; SPEED-COST is the cost of executing fragment, relative to a
		; simple add.
		; SIZE-COST is the size of the fragment, relative to a simple
		; add.
		; ??? The cost numbers are somewhat arbitrary and subject to
		; review.
		speed-cost
		size-cost

		; Users of this statement.
		; Each element is (owner-number . owner-object),
		; where owner-number is an index into the initial insn table
		; (e.g. insn-list arg of sfrag-create-cse-mapping), and
		; owner-object is the corresponding object.
		users
		)
	      nil)
)

(define-getters <statement> -stmt (expr locals num speed-cost size-cost users))

(define-setters <statement> -stmt (users))

; Make a <statement> object of EXPR.
; LOCALS is a list of local variables of the sequence EXPR is in.
; NUM is the ordinal of EXPR.
; SPEED-COST is the cost of executing the statement, relative to a simple add.
; SIZE-COST is the size of the fragment, relative to a simple add.
; ??? The cost numbers are somewhat arbitrary and subject to review.
;
; The user list is set to nil.

(define (-stmt-make expr locals num speed-cost size-cost)
  (make <statement> expr locals num speed-cost size-cost nil)
)

; Add a user of STMT.

(define (-stmt-add-user! stmt user-num user-obj)
  (-stmt-set-users! stmt (cons (cons user-num user-obj) (-stmt-users stmt)))
  *UNSPECIFIED*
)

; Lookup STMT in DATA.
; CHAIN-NUM is an argument so it need only be computed once.
; The result is the found <statement> object or #f.

(define (-frag-lookup-stmt data chain-num stmt)
  (let ((table (-stmt-data-table data)))
    (let loop ((stmts (vector-ref table chain-num)))
      (cond ((null? stmts)
	     #f)
	    ; ??? equal? should be appropriate rtx-equal?, blah blah blah.
	    ((equal? (-stmt-expr (car stmts)) stmt)
	     (car stmts))
	    (else
	     (loop (cdr stmts))))))
)

; Hash a statement.

; Computed hash value.
; Global 'cus -frag-hash-compute! is defined globally so we can use
; /fastcall (FIXME: Need /fastcall to work on non-global procs).

(define -frag-hash-value-tmp 0)

(define (-frag-hash-string str)
  (let loop ((chars (map char->integer (string->list str))) (result 0))
    (if (null? chars)
	result
	(loop (cdr chars) (modulo (+ (* result 7) (car chars)) #xfffffff))))
)

(define (-frag-hash-compute! rtx-obj expr mode parent-expr op-pos tstate appstuff)
  (let ((h 0))
    (case (rtx-name expr)
      ((operand)
       (set! h (-frag-hash-string (symbol->string (rtx-operand-name expr)))))
      ((local)
       (set! h (-frag-hash-string (symbol->string (rtx-local-name expr)))))
      ((const)
       (set! h (rtx-const-value expr)))
      (else
       (set! h (rtx-num rtx-obj))))
    (set! -frag-hash-value-tmp
	  ; Keep number small.
	  (modulo (+ (* -frag-hash-value-tmp 3) h op-pos)
		  #xfffffff)))

  ; #f -> "continue with normal traversing"
  #f
)

(define (-frag-hash-stmt stmt locals size)
  (set! -frag-hash-value-tmp 0)
  (rtx-traverse-with-locals #f #f stmt -frag-hash-compute! locals #f) ; FIXME: (/fastcall-make -frag-hash-compute!))
  (modulo -frag-hash-value-tmp size)
)

; Compute the speed/size costs of a statement.

; Compute speed/size costs.
; Global 'cus -frag-cost-compute! is defined globally so we can use
; /fastcall (FIXME: Need /fastcall to work on non-global procs).

(define -frag-speed-cost-tmp 0)
(define -frag-size-cost-tmp 0)

(define (-frag-cost-compute! rtx-obj expr mode parent-expr op-pos tstate appstuff)
  ; FIXME: wip
  (let ((speed 0)
	(size 0))
    (case (rtx-class rtx-obj)
      ((ARG)
       #f) ; these don't contribute to costs (at least for now)
      ((SET)
       ; FIXME: speed/size = 0?
       (set! speed 1)
       (set! size 1))
      ((UNARY BINARY TRINARY)
       (set! speed 1)
       (set! size 1))
      ((IF)
       (set! speed 2)
       (set! size 2))
      (else
       (set! speed 4)
       (set! size 4)))
    (set! -frag-speed-cost-tmp (+ -frag-speed-cost-tmp speed))
    (set! -frag-size-cost-tmp (+ -frag-size-cost-tmp size)))

  ; #f -> "continue with normal traversing"
  #f
)

(define (-frag-stmt-cost stmt locals)
  (set! -frag-speed-cost-tmp 0)
  (set! -frag-size-cost-tmp 0)
  (rtx-traverse-with-locals #f #f stmt -frag-cost-compute! locals #f) ; FIXME: (/fastcall-make -frag-cost-compute!))
  (cons -frag-speed-cost-tmp -frag-size-cost-tmp)
)

; Add STMT to statement table DATA.
; CHAIN-NUM is the chain in the hash table to add STMT to.
; {SPEED,SIZE}-COST are passed through to -stmt-make.
; The result is the newly created <statement> object.

(define (-frag-add-stmt! data chain-num stmt locals speed-cost size-cost)
  (let ((stmt (-stmt-make stmt locals (-stmt-data-next-num data) speed-cost size-cost))
	(table (-stmt-data-table data)))
    (vector-set! table chain-num (cons stmt (vector-ref table chain-num)))
    (-stmt-data-set-next-num! data (+ 1 (-stmt-data-next-num data)))
    stmt)
)

; Return the locals in EXPR.
; If a sequence, return locals.
; Otherwise, return nil.
; The result is in assq'able form.

(define (-frag-expr-locals expr)
  (if (rtx-kind? 'sequence expr)
      (rtx-sequence-assq-locals expr)
      nil)
)

; Return the statements in EXPR.
; If a sequence, return the sequence's expressions.
; Otherwise, return (list expr).

(define (-frag-expr-stmts expr)
  (if (rtx-kind? 'sequence expr)
      (rtx-sequence-exprs expr)
      (list expr))
)

; Analyze statement STMT.
; If STMT is already in STMT-DATA increment its frequency count.
; Otherwise add it.
; LOCALS are locals of the sequence STMT is in.
; USAGE-TABLE is a vector of statement index lists for each expression.
; USAGE-INDEX is the index of USAGE-TABLE to use.
; OWNER is the object of the owner of the statement.

(define (-frag-analyze-expr-stmt! locals stmt stmt-data usage-table expr-num owner)
  (logit 3 "Analyzing statement: " (rtx-strdump stmt) "\n")
  (let* ((chain-num
	  (-frag-hash-stmt stmt locals (-stmt-data-hash-size stmt-data)))
	 (stmt-obj (-frag-lookup-stmt stmt-data chain-num stmt)))

    (logit 3 "  chain #" chain-num  "\n")

    (if (not stmt-obj)
	(let* ((costs (-frag-stmt-cost stmt locals))
	       (speed-cost (car costs))
	       (size-cost (cdr costs)))
	  (set! stmt-obj (-frag-add-stmt! stmt-data chain-num stmt locals
					  speed-cost size-cost))
	  (logit 3 "  new statement, #" (-stmt-num stmt-obj) "\n"))
	(logit 3   "  existing statement, #" (-stmt-num stmt-obj) "\n"))

    (-stmt-add-user! stmt-obj expr-num owner)

    ; If first entry, initialize list, otherwise append to existing list.
    (if (null? (vector-ref usage-table expr-num))
	(vector-set! usage-table expr-num (list (-stmt-num stmt-obj)))
	(append! (vector-ref usage-table expr-num)
		 (list (-stmt-num stmt-obj)))))

  *UNSPECIFIED*
)

; Analyze each statement in EXPR and add it to STMT-DATA.
; OWNER is the object of the owner of the expression.
; USAGE-TABLE is a vector of statement index lists for each expression.
; USAGE-INDEX is the index of the USAGE-TABLE entry to use.
; As each statement's ordinal is computed it is added to the usage list.

(define (-frag-analyze-expr! expr owner stmt-data usage-table usage-index)
  (logit 3 "Analyzing " (obj:name owner) ": " (rtx-strdump expr) "\n")
  (let ((locals (-frag-expr-locals expr))
	(stmt-list (-frag-expr-stmts expr)))
    (for-each (lambda (stmt)
		(-frag-analyze-expr-stmt! locals stmt stmt-data
					  usage-table usage-index owner))
	      stmt-list))
  *UNSPECIFIED*
)

; Compute statement data from EXPRS, a list of expressions.
; OWNERS is a vector of objects that "own" each corresponding element in EXPRS.
; The owner is usually an <insn> object.  Actually it'll probably always be
; an <insn> object but for now I want the disassociation.
;
; The result contains:
; - vector of statement lists of each expression
;   - each element is (stmt1-index stmt2-index ...) where each stmtN-index is
;     an index into the statement table
; - vector of statements (the statement table of the previous item)
;   - each element is a <statement> object

(define (-frag-compute-statements exprs owners)
  (logit 2 "Computing statement table ...\n")
  (let* ((num-exprs (length exprs))
	 (hash-size
	  ; FIXME: This is just a quick hack to put something down on paper.
	  ; blah blah blah.  Revisit as necessary.
	  (cond ((> num-exprs 300) 1019)
		((> num-exprs 100) 511)
		(else 127))))

    (let (; Hash table of expressions.
	  (stmt-data (-stmt-data-make hash-size))
	  ; Statement index lists for each expression.
	  (usage-table (make-vector num-exprs nil)))

      ; Scan each expr, filling in stmt-data and usage-table.
      (let loop ((exprs exprs) (exprnum 0))
	(if (not (null? exprs))
	    (let ((expr (car exprs))
		  (owner (vector-ref owners exprnum)))
	      (-frag-analyze-expr! expr owner stmt-data usage-table exprnum)
	      (loop (cdr exprs) (+ exprnum 1)))))

      ; Convert statement hash table to vector.
      (let ((stmt-hash-table (-stmt-data-table stmt-data))
	    (end (vector-length (-stmt-data-table stmt-data)))
	    (stmt-table (make-vector (-stmt-data-next-num stmt-data) #f)))
	(let loop ((i 0))
	  (if (< i end)
	      (begin
		(map (lambda (stmt)
		       (vector-set! stmt-table (-stmt-num stmt) stmt))
		     (vector-ref stmt-hash-table i))
		(loop (+ i 1)))))

	; All done.  Compute stats if asked to.
	(if -stmt-stats?
	    (begin
	      ; See how well the hashing worked.
	      (set! -stmt-stats-data stmt-data)
	      (set! -stmt-stats
		    (make-vector (vector-length stmt-hash-table) #f))
	      (let loop ((i 0))
		(if (< i end)
		    (begin
		      (vector-set! -stmt-stats i
				   (length (vector-ref stmt-hash-table i)))
		      (loop (+ i 1)))))))

	; Result.
	(cons usage-table stmt-table))))
)

; Semantic fragment selection.
;
; "semantic fragment" is the name assigned to each header/middle/trailer
; "fragment" as each may consist of more than one statement, though not
; necessarily all statements of the original sequence.

(define <sfrag>
  (class-make '<sfrag> '(<ident>)
	      '(
		; List of insn's using this frag.
		users

		; Ordinal's of each element of `users'.
		user-nums

		; Semantic format of insns using this fragment.
		sfmt

		; List of statement numbers that make up `semantics'.
		; Each element is an index into the stmt-table arg of
		; -frag-pick-best.
		; This is #f if the sfrag wasn't derived from some set of
		; statements.
		stmt-numbers

		; Raw rtl source of fragment.
		semantics

		; Compiled source.
		compiled-semantics

		; Boolean indicating if this frag is for parallel exec support.
		parallel?

		; Boolean indicating if this is a header frag.
		; This includes all frags that begin a sequence.
		header?

		; Boolean indicating if this is a trailer frag.
		; This includes all frags that end a sequence.
		trailer?
		)
	      nil)
)

(define-getters <sfrag> sfrag
  (users user-nums sfmt stmt-numbers semantics compiled-semantics
	 parallel? header? trailer?)
)

(define-setters <sfrag> sfrag
  (header? trailer?)
)

; Sorter to merge common fragments together.
; A and B are lists of statement numbers.

(define (-frag-sort a b)
  (cond ((null? a)
	 (not (null? b)))
	((null? b)
	 #f)
	((< (car a) (car b))
	 #t)
	((> (car a) (car b))
	 #f)
	(else ; =
	 (-frag-sort (cdr a) (cdr b))))
)

; Return a boolean indicating if L1,L2 match in the first LEN elements.
; Each element is an integer.

(define (-frag-list-match? l1 l2 len)
  (cond ((= len 0)
	 #t)
	((or (null? l1) (null? l2))
	 #f)
	((= (car l1) (car l2))
	 (-frag-list-match? (cdr l1) (cdr l2) (- len 1)))
	(else
	 #f))
)

; Return the number of expressions that match in the first LEN statements.

(define (-frag-find-matching expr-table indices stmt-list len)
  (let loop ((num-exprs 0) (indices indices))
    (cond ((null? indices)
	   num-exprs)
	  ((-frag-list-match? stmt-list
			      (vector-ref expr-table (car indices)) len)
	   (loop (+ num-exprs 1) (cdr indices)))
	  (else
	   num-exprs)))
)

; Return a boolean indicating if making STMT-LIST a common fragment
; among several owners is profitable.
; STMT-LIST is a list of statement numbers, indices into STMT-TABLE.
; NUM-EXPRS is the number of expressions with STMT-LIST in common.

(define (-frag-merge-profitable? stmt-table stmt-list num-exprs)
  ; FIXME: wip
  (and (>= num-exprs 2)
       (or ; No need to include speed costs yet.
	   ;(>= (-frag-list-speed-cost stmt-table stmt-list) 10)
	   (>= (-frag-list-size-cost stmt-table stmt-list) 4)))
)

; Return the cost of executing STMT-LIST.
; STMT-LIST is a list of statment numbers, indices into STMT-TABLE.
;
; FIXME: The yardstick to use is wip.  Currently we measure things relative
; to a simple add insn which is given the value 1.

(define (-frag-list-speed-cost stmt-table stmt-list)
  ; FIXME: wip
  (apply + (map (lambda (stmt-num)
		  (-stmt-speed-cost (vector-ref stmt-table stmt-num)))
		stmt-list))
)

(define (-frag-list-size-cost stmt-table stmt-list)
  ; FIXME: wip
  (apply + (map (lambda (stmt-num)
		  (-stmt-size-cost (vector-ref stmt-table stmt-num)))
		stmt-list))
)

; Compute the longest set of fragments it is desirable/profitable to create.
; The result is (number-of-matching-exprs . stmt-number-list)
; or #f if there isn't one (the longest set is the empty set).
;
; What is desirable depends on a few things:
; - how often is it used?
; - how expensive is it (size-wise and speed-wise)
; - relationship to other frags
;
; STMT-TABLE is a vector of all statements.
; STMT-USAGE-TABLE is a vector of all expressions.  Each element is a list of
; statement numbers (indices into STMT-TABLE).
; INDICES is a sorted list of indices into STMT-USAGE-TABLE.
; STMT-USAGE-TABLE is processed in the order specified by INDICES.
;
; FIXME: Choosing a statement list should depend on whether there are existing
; chosen statement lists only slightly shorter.

(define (-frag-longest-desired stmt-table stmt-usage-table indices)
  ; STMT-LIST is the list of statements in the first expression.
  (let ((stmt-list (vector-ref stmt-usage-table (car indices))))

    (let loop ((len 1) (prev-num-exprs 0))

      ; See how many subsequent expressions match at length LEN.
      (let ((num-exprs (-frag-find-matching stmt-usage-table (cdr indices)
					    stmt-list len)))
	; If there aren't any, we're done.
	; If LEN-1 is usable, return that.
	; Otherwise there is no profitable list of fragments.
	(if (= num-exprs 0)

	    (let ((matching-stmt-list (list-take (- len 1) stmt-list)))
	      (if (-frag-merge-profitable? stmt-table matching-stmt-list
					   prev-num-exprs)
		  (cons prev-num-exprs matching-stmt-list)
		  #f))

	    ; Found at least 1 subsequent matching expression.
	    ; Extend LEN and see if we still find matching expressions.
	    (loop (+ len 1) num-exprs)))))
)

; Return list of lists of objects for each unique <sformat-argbuf> in
; USER-LIST.
; Each element of USER-LIST is (insn-num . <insn> object).
; The result is a list of lists.  Each element in the top level list is
; a list of elements of USER-LIST that have the same <sformat-argbuf>.
; Insns are also distinguished by being a CTI insn vs a non-CTI insn.
; CTI insns require special handling in the semantics.

(define (-frag-split-by-sbuf user-list)
  ; Sanity check.
  (if (not (elm-bound? (cdar user-list) 'sfmt))
      (error "sformats not computed"))
  (if (not (elm-bound? (insn-sfmt (cdar user-list)) 'sbuf))
      (error "sformat argbufs not computed"))

  (let ((result nil)
	; Find INSN in SFMT-LIST.  The result is the list INSN belongs in
	; or #f.
	(find-obj (lambda (sbuf-list insn)
		    (let ((name (obj:name (sfmt-sbuf (insn-sfmt insn)))))
		      (let loop ((sbuf-list sbuf-list))
			(cond ((null? sbuf-list)
			       #f)
			      ((and (eq? name
					 (obj:name (sfmt-sbuf (insn-sfmt (cdaar sbuf-list)))))
				    (eq? (insn-cti? insn)
					 (insn-cti? (cdaar sbuf-list))))
			       (car sbuf-list))
			      (else
			       (loop (cdr sbuf-list))))))))
	)
    (let loop ((users user-list))
      (if (not (null? users))
	  (let ((try (find-obj result (cdar users))))
	    (if try
		(append! try (list (car users)))
		(set! result (cons (list (car users)) result)))
	    (loop (cdr users)))))

    ; Done
    result)
)

; Return a list of desired fragments to create.
; These consist of the longest set of profitable leading statements in EXPRS.
; Each element of the result is an <sfrag> object.
;
; STMT-TABLE is a vector of all statements.
; STMT-USAGE-TABLE is a vector of statement number lists of each expression.
; OWNER-TABLE is a vector of owner objects of each corresponding expression
; in STMT-USAGE-TABLE.
; KIND is one of 'header or 'trailer.
;
; This works for trailing fragments too as we do the computation based on the
; reversed statement lists.

(define (-frag-compute-desired-frags stmt-table stmt-usage-table owner-table kind)
  (logit 2 "Computing desired " kind " frags ...\n")

  (let* (
	 (stmt-usage-list
	  (if (eq? kind 'header)
	      (vector->list stmt-usage-table)
	      (map reverse (vector->list stmt-usage-table))))
	 ; Sort STMT-USAGE-TABLE.  That will bring exprs with common fragments
	 ; together.
	 (sorted-indices (sort-grade stmt-usage-list -frag-sort))
	 ; List of statement lists that together yield the fragment to create,
	 ; plus associated users.
	 (desired-frags nil)
	 )

    ; Update STMT-USAGE-TABLE in case we reversed the contents.
    (set! stmt-usage-table (list->vector stmt-usage-list))

    (let loop ((indices sorted-indices) (iteration 1))
      (logit 3 "Iteration " iteration "\n")
      (if (not (null? indices))
	  (let ((longest (-frag-longest-desired stmt-table stmt-usage-table indices)))

	    (if longest

		; Found an acceptable frag to create.
		(let* ((num-exprs (car longest))
		       ; Reverse statement numbers back if trailer.
		       (stmt-list (if (eq? kind 'header)
				      (cdr longest)
				      (reverse (cdr longest))))
		       (picked-indices (list-take num-exprs indices))
		       ; Need one copy of the frag for each sbuf, as structure
		       ; offsets will be different in generated C/C++ code.
		       (sfmt-users (-frag-split-by-sbuf
				    (map (lambda (expr-num)
					   (cons expr-num
						 (vector-ref owner-table
							     expr-num)))
					 picked-indices))))

		  (logit 3 "Creating frag of length " (length stmt-list) ", " num-exprs " users\n")
		  (logit 3 "Indices: " picked-indices "\n")

		  ; Create an sfrag for each sbuf.
		  (for-each
		   (lambda (users)
		     (let* ((first-owner (cdar users))
			    (sfrag
			     (make <sfrag>
			       (symbol-append (obj:name first-owner)
					      (if (eq? kind 'header)
						  '-hdr
						  '-trlr))
			       ""
			       atlist-empty
			       (map cdr users)
			       (map car users)
			       (insn-sfmt first-owner)
			       stmt-list
			       (apply
				rtx-make
				(cons 'sequence
				      (cons 'VOID
					    (cons nil
						  (map (lambda (stmt-num)
							 (-stmt-expr
							  (vector-ref stmt-table
								      stmt-num)))
						       stmt-list)))))
			       #f ; compiled-semantics
			       #f ; parallel?
			       (eq? kind 'header)
			       (eq? kind 'trailer)
			       )))
		       (set! desired-frags (cons sfrag desired-frags))))
		   sfmt-users)

		  ; Continue, dropping statements we've put into the frag.
		  (loop (list-drop num-exprs indices) (+ iteration 1)))

		; Couldn't find an acceptable statement list.
		; Try again with next one.
		(begin
		  (logit 3 "No acceptable frag found.\n")
		  (loop (cdr indices) (+ iteration 1)))))))

    ; Done.
    desired-frags)
)

; Return the set of desired fragments to create.
; STMT-TABLE is a vector of each statement.
; STMT-USAGE-TABLE is a vector of (stmt1-index stmt2-index ...) elements for
; each expression, where each stmtN-index is an index into STMT-TABLE.
; OWNER-TABLE is a vector of owner objects of each corresponding expression
; in STMT-USAGE-TABLE.
;
; Each expression is split in up to three pieces: header, middle, trailer.
; This computes pseudo-optimal headers and trailers (if they exist).
; The "middle" part is whatever is leftover.
;
; The result is a vector of 4 elements:
; - vector of (header middle trailer) semantic fragments for each expression
;   - each element is an index into the respective table or #f if not present
; - list of header fragments, each element is an <sfrag> object
; - same but for trailer fragments
; - same but for middle fragments
;
; ??? While this is a big function, each piece is simple and straightforward.
; It's kept as one big function so we can compute each expression's sfrag list
; as we go.  Though it's not much extra expense to not do this.

(define (-frag-pick-best stmt-table stmt-usage-table owner-table)
  (let (
	(num-stmts (vector-length stmt-table))
	(num-exprs (vector-length stmt-usage-table))
	; FIXME: Shouldn't have to do vector->list.
	(stmt-usage-list (vector->list stmt-usage-table))
	; Specify result holders here, simplifies code.
	(desired-header-frags #f)
	(desired-trailer-frags #f)
	(middle-frags #f)
	; Also allocate space for expression sfrag usage table.
	; We compute it as we go to save scanning the header and trailer
	; lists twice.
	; copy-tree is needed to avoid shared storage.
	(expr-sfrags (copy-tree (make-vector (vector-length stmt-usage-table)
					     #(#f #f #f))))
	)

    ; Compute desired headers.
    (set! desired-header-frags
	  (-frag-compute-desired-frags stmt-table stmt-usage-table owner-table
				       'header))

    ; Compute the header used by each expression.
    (let ((expr-hdrs-v (make-vector num-exprs #f))
	  (num-hdrs (length desired-header-frags)))
      (let loop ((hdrs desired-header-frags) (hdrnum 0))
	(if (< hdrnum num-hdrs)
	    (let ((hdr (car hdrs)))
	      (for-each (lambda (expr-num)
			  (vector-set! (vector-ref expr-sfrags expr-num) 0
				       hdrnum)
			  (vector-set! expr-hdrs-v expr-num hdr))
			(sfrag-user-nums hdr))
	      (loop (cdr hdrs) (+ hdrnum 1)))))

      ; Truncate each expression by the header it will use and then find
      ; the set of desired trailers.
      (let ((expr-hdrs (vector->list expr-hdrs-v)))

	(set! desired-trailer-frags
	      (-frag-compute-desired-frags
	       stmt-table
	       ; FIXME: Shouldn't have to use list->vector.
	       ; [still pass a vector, but use vector-map here instead of map]
	       (list->vector
		(map (lambda (expr hdr)
		       (if hdr
			   (list-drop (length (sfrag-stmt-numbers hdr)) expr)
			   expr))
		     stmt-usage-list expr-hdrs))
	       owner-table
	       'trailer))

	; Record the trailer used by each expression.
	(let ((expr-trlrs-v (make-vector num-exprs #f))
	      (num-trlrs (length desired-trailer-frags)))
	  (let loop ((trlrs desired-trailer-frags) (trlrnum 0))
	    (if (< trlrnum num-trlrs)
		(let ((trlr (car trlrs)))
		  (for-each (lambda (expr-num)
			      (vector-set! (vector-ref expr-sfrags expr-num) 2
					   trlrnum)
			      (vector-set! expr-trlrs-v expr-num trlr))
			    (sfrag-user-nums trlr))
		  (loop (cdr trlrs) (+ trlrnum 1)))))

	  ; We have the desired headers and trailers, now compute the middle
	  ; part for each expression.  This is just what's left over.
	  ; ??? We don't try to cse the middle part.  Though we can in the
	  ; future should it prove useful enough.
	  (logit 2 "Computing middle frags ...\n")
	  (let* ((expr-trlrs (vector->list expr-trlrs-v))
		 (expr-middle-stmts
		  (map (lambda (expr hdr trlr)
			 (list-tail-drop
			  (if trlr (length (sfrag-stmt-numbers trlr)) 0)
			  (list-drop
			   (if hdr (length (sfrag-stmt-numbers hdr)) 0)
			   expr)))
		       stmt-usage-list expr-hdrs expr-trlrs)))

	    ; Finally, record the middle sfrags used by each expression.
	    (let loop ((tmp-middle-frags nil)
		       (next-middle-frag-num 0)
		       (expr-num 0)
		       (expr-middle-stmts expr-middle-stmts))

	      (if (null? expr-middle-stmts)

		  ; Done!
		  ; [The next statement executed after this is the one at the
		  ; end that builds the result.  Maybe it should be built here
		  ; and this should be the last statement, but I'm trying this
		  ; style out for awhile.]
		  (set! middle-frags (reverse! tmp-middle-frags))

		  ; Does this expr have a middle sfrag?
		  (if (null? (car expr-middle-stmts))
		      ; Nope.
		      (loop tmp-middle-frags
			    next-middle-frag-num
			    (+ expr-num 1)
			    (cdr expr-middle-stmts))
		      ; Yep.
		      (let ((owner (vector-ref owner-table expr-num)))
			(vector-set! (vector-ref expr-sfrags expr-num)
				     1 next-middle-frag-num)
			(loop (cons (make <sfrag>
				      (symbol-append (obj:name owner) '-mid)
				      (string-append (obj:comment owner)
						     ", middle part")
				      (obj-atlist owner)
				      (list owner)
				      (list expr-num)
				      (insn-sfmt owner)
				      (car expr-middle-stmts)
				      (apply
				       rtx-make
				       (cons 'sequence
					     (cons 'VOID
						   (cons nil
							 (map (lambda (stmt-num)
								(-stmt-expr
								 (vector-ref stmt-table stmt-num)))
							      (car expr-middle-stmts))))))
				      #f ; compiled-semantics
				      #f ; parallel?
				      #f ; header?
				      #f ; trailer?
				      )
				    tmp-middle-frags)
			      (+ next-middle-frag-num 1)
			      (+ expr-num 1)
			      (cdr expr-middle-stmts))))))))))

    ; Result.
    (vector expr-sfrags
	    desired-header-frags
	    desired-trailer-frags
	    middle-frags))
)

; Given a list of expressions, return list of locals in top level sequences.
; ??? Collisions will be handled by rewriting rtl (renaming locals).
;
; This has to be done now as the cse pass must (currently) take into account
; the rewritten rtl.
; ??? This can be done later, with an appropriate enhancement to rtx-equal?
; ??? cse can be improved by ignoring local variable name (of course).

(define (-frag-compute-locals! expr-list)
  (logit 2 "Computing common locals ...\n")
  (let ((result nil)
	(lookup-local (lambda (local local-list)
			(assq (car local) local-list)))
	(local-equal? (lambda (l1 l2)
			(and (eq? (car l1) (car l2))
			     (mode:eq? (cadr l1) (cadr l2)))))
	)
    (for-each (lambda (expr)
		(let ((locals (-frag-expr-locals expr)))
		  (for-each (lambda (local)
			      (let ((entry (lookup-local local result)))
				(if (and entry
					 (local-equal? local entry))
				    #f ; already present
				    (set! result (cons local result)))))
			    locals)))
	      expr-list)
    ; Done.
    result)
)

; Common subexpression computation.

; Given a list of rtl expressions and their owners, return a pseudo-optimal
; set of fragments and a usage list for each owner.
; Common fragments are combined and the original expressions become a sequence
; of these fragments.  The result is "pseudo-optimal" in the sense that the
; desired result is somewhat optimal, though no attempt is made at precise
; optimality.
;
; OWNERS is a list of objects that "own" each corresponding element in EXPRS.
; The owner is usually an <insn> object.  Actually it'll probably always be
; an <insn> object but for now I want the disassociation.
;
; The result is a vector of six elements:
; - sfrag usage table for each owner #(header middle trailer)
; - statement table (vector of all statements, made with -stmt-make)
; - list of sequence locals used by header sfrags
;   - these locals are defined at the top level so that all fragments have
;     access to them
;   - ??? Need to handle collisions among incompatible types.
; - header sfrags
; - trailer sfrags
; - middle sfrags

(define (-sem-find-common-frags-1 exprs owners)
  ; Sanity check.
  (if (not (elm-bound? (car owners) 'sfmt))
      (error "sformats not computed"))

  ; A simple procedure that calls, in order:
  ; -frag-compute-locals!
  ; -frag-compute-statements
  ; -frag-pick-best
  ; The rest is shuffling of results.

  ; Internally it's easier if OWNERS is a vector.
  (let ((owners (list->vector owners))
	(locals (-frag-compute-locals! exprs)))

    ; Collect statement usage data.
    (let ((stmt-usage (-frag-compute-statements exprs owners)))
      (let ((stmt-usage-table (car stmt-usage))
	    (stmt-table (cdr stmt-usage)))

	; Compute the frags we want to create.
	; These are in general sequences of statements.
	(let ((desired-frags
	       (-frag-pick-best stmt-table stmt-usage-table owners)))
	  (let (
		(expr-sfrags (vector-ref desired-frags 0))
		(headers (vector-ref desired-frags 1))
		(trailers (vector-ref desired-frags 2))
		(middles (vector-ref desired-frags 3))
		)
	    ; Result.
	    (vector expr-sfrags stmt-table locals
		    headers trailers middles))))))
)

; Cover proc of -sem-find-common-frags-1.
; See its documentation.

(define (sem-find-common-frags insn-list)
  (-sem-find-common-frags-1
   (begin
     (logit 2 "Simplifying/canonicalizing rtl ...\n")
     (map (lambda (insn)
	    (rtx-simplify-insn #f insn))
	  insn-list))
   insn-list)
)

; Subroutine of sfrag-create-cse-mapping to compute INSN's fragment list.
; FRAG-USAGE is a vector of 3 elements: #(header middle trailer).
; Each element is a fragment number or #f if not present.
; Numbers in FRAG-USAGE are indices relative to their respective subtables
; of FRAG-TABLE (which is a vector of all 3 tables concatenated together).
; NUM-HEADERS,NUM-TRAILERS are used to compute absolute indices.
;
; No header may have been created.  This happens when
; it's not profitable (or possible) to merge this insn's
; leading statements with other insns.  Ditto for
; trailer.  However, each cti insn must have a header
; and a trailer (for pc handling setup and change).
; Try to use the middle fragment if present.  Otherwise,
; use the x-header,x-trailer virtual insns.

(define (-sfrag-compute-frag-list! insn frag-usage frag-table num-headers num-trailers x-header-relnum x-trailer-relnum)
  ; `(list #f)' is so append! works.  The #f is deleted before returning.
  (let ((result (list #f))
	(header (vector-ref frag-usage 0))
	(middle (and (vector-ref frag-usage 1)
		     (+ (vector-ref frag-usage 1)
			num-headers num-trailers)))
	(trailer (and (vector-ref frag-usage 2)
		      (+ (vector-ref frag-usage 2)
			 num-headers)))
	(x-header-num x-header-relnum)
	(x-trailer-num (+ x-trailer-relnum num-headers))
	)

    ; cse'd header created?
    (if header
	; Yep.
	(append! result (list header))
	; Nope.  Use the middle frag if present, otherwise use x-header.
	; Can't use the trailer fragment because by definition it is shared
	; among several insns.
	(if middle
	    ; Mark the middle frag as the header frag.
	    (sfrag-set-header?! (vector-ref frag-table middle) #t)
	    ; No middle, use x-header.
	    (append! result (list x-header-num))))

    ; middle fragment present?
    (if middle
	(append! result (list middle)))

    ; cse'd trailer created?
    (if trailer
	; Yep.
	(append! result (list trailer))
	; Nope.  Use the middle frag if present, otherwise use x-trailer.
	; Can't use the header fragment because by definition it is shared
	; among several insns.
	(if middle
	    ; Mark the middle frag as the trailer frag.
	    (sfrag-set-trailer?! (vector-ref frag-table middle) #t)
	    ; No middle, use x-trailer.
	    (append! result (list x-trailer-num))))

    ; Done.
    (cdr result))
)

; Subroutine of sfrag-create-cse-mapping to find the fragment number of the
; x-header/x-trailer virtual frags.

(define (-frag-lookup-virtual frag-list name)
  (let loop ((i 0) (frag-list frag-list))
    (if (null? frag-list)
	(assert (not "expected virtual insn not present"))
	(if (eq? name (obj:name (car frag-list)))
	    i
	    (loop (+ i 1) (cdr frag-list)))))
)

; Handle complex case, find set of common header and trailer fragments.
; The result is a vector of:
; - fragment table (a vector)
; - table mapping used fragments for each insn (a list)
; - locals list

(define (sfrag-create-cse-mapping insn-list)
  (logit 1 "Creating semantic fragments for pbb engine ...\n")

  (let ((cse-data (sem-find-common-frags insn-list)))

    ; Extract the results of sem-find-common-frags.
    (let ((sfrag-usage-table (vector-ref cse-data 0))
	  (stmt-table (vector-ref cse-data 1))
	  (locals-list (vector-ref cse-data 2))
	  (header-list1 (vector-ref cse-data 3))
	  (trailer-list1 (vector-ref cse-data 4))
	  (middle-list (vector-ref cse-data 5)))

      ; Create two special frags: x-header, x-trailer.
      ; These are used by insns that don't have one or the other.
      ; Header/trailer table indices are already computed for each insn
      ; so append x-header/x-trailer to the end.
      (let ((header-list
	     (append header-list1
		     (list
		      (make <sfrag>
			'x-header
			"header fragment for insns without one"
			(atlist-parse (make-prefix-context "semantic frag computation")
				      '(VIRTUAL) "")
			nil ; users
			nil ; user ordinals
			(insn-sfmt (current-insn-lookup 'x-before))
			#f ; stmt-numbers
			(rtx-make 'nop)
			#f ; compiled-semantics
			#f ; parallel?
			#t ; header?
			#f ; trailer?
			))))
	    (trailer-list
	     (append trailer-list1
		     (list
		      (make <sfrag>
			'x-trailer
			"trailer fragment for insns without one"
			(atlist-parse (make-prefix-context "semantic frag computation")
				      '(VIRTUAL) "")
			nil ; users
			nil ; user ordinals
			(insn-sfmt (current-insn-lookup 'x-before))
			#f ; stmt-numbers
			(rtx-make 'nop)
			#f ; compiled-semantics
			#f ; parallel?
			#f ; header?
			#t ; trailer?
			)))))

	(let ((num-headers (length header-list))
	      (num-trailers (length trailer-list))
	      (num-middles (length middle-list)))

	  ; Combine the three sfrag tables (headers, trailers, middles) into
	  ; one big one.
	  (let ((frag-table (list->vector (append header-list
						  trailer-list
						  middle-list)))
		(x-header-relnum (-frag-lookup-virtual header-list 'x-header))
		(x-trailer-relnum (-frag-lookup-virtual trailer-list 'x-trailer))
		)
	    ; Convert sfrag-usage-table to one that refers to the one big
	    ; sfrag table.
	    (logit 2 "Computing insn frag usage ...\n")
	    (let ((insn-frags
		   (map (lambda (insn frag-usage)
			  (-sfrag-compute-frag-list! insn frag-usage
						     frag-table
						     num-headers num-trailers
						     x-header-relnum
						     x-trailer-relnum))
			insn-list
		        ; FIXME: vector->list
			(vector->list sfrag-usage-table)))
		  )
	      (logit 1 "Done fragment creation.\n")
	      (vector frag-table insn-frags locals-list)))))))
)

; Data analysis interface.

(define -sim-sfrag-init? #f)
(define (sim-sfrag-init?) -sim-sfrag-init?)

; Keep in globals for now, simplifies debugging.
; evil globals, blah blah blah.
(define -sim-sfrag-insn-list #f)
(define -sim-sfrag-frag-table #f)
(define -sim-sfrag-usage-table #f)
(define -sim-sfrag-locals-list #f)

(define (sim-sfrag-insn-list)
  (assert -sim-sfrag-init?)
  -sim-sfrag-insn-list
)
(define (sim-sfrag-frag-table)
  (assert -sim-sfrag-init?)
  -sim-sfrag-frag-table
)
(define (sim-sfrag-usage-table)
  (assert -sim-sfrag-init?)
  -sim-sfrag-usage-table
)
(define (sim-sfrag-locals-list)
  (assert -sim-sfrag-init?)
  -sim-sfrag-locals-list
)

(define (sim-sfrag-init!)
  (set! -sim-sfrag-init? #f)
  (set! -sim-sfrag-insn-list #f)
  (set! -sim-sfrag-frag-table #f)
  (set! -sim-sfrag-usage-table #f)
  (set! -sim-sfrag-locals-list #f)
)

(define (sim-sfrag-analyze-insns!)
  (if (not -sim-sfrag-init?)
      (begin
	(set! -sim-sfrag-insn-list (non-multi-insns (non-alias-insns (current-insn-list))))
	(let ((frag-data (sfrag-create-cse-mapping -sim-sfrag-insn-list)))
	  (set! -sim-sfrag-frag-table (vector-ref frag-data 0))
	  (set! -sim-sfrag-usage-table (vector-ref frag-data 1))
	  (set! -sim-sfrag-locals-list (vector-ref frag-data 2)))
	(set! -sim-sfrag-init? #t)))

  *UNSPECIFIED*
)

; Testing support.

(define (-frag-small-test-data)
  '(
    (a . (sequence VOID ((SI tmp)) (set DFLT tmp rm) (set DFLT rd rm)))
    (b . (sequence VOID ((SI tmp)) (set DFLT tmp rm) (set DFLT rd rm)))
    (c . (set DFLT rd rm))
    )
)

(define (-frag-test-data)
  (cons
   (map (lambda (insn)
	  (rtx-simplify-insn #f insn))
	(non-multi-insns (non-alias-insns (current-insn-list))))
   (non-multi-insns (non-alias-insns (current-insn-list))))
)

(define test-sfrag-table #f)
(define test-stmt-table #f)
(define test-locals-list #f)
(define test-header-list #f)
(define test-trailer-list #f)
(define test-middle-list #f)

(define (frag-test-run)
  (let* ((test-data (-frag-test-data))
	 (frag-data (sem-find-common-frags (car test-data) (cdr test-data))))
    (set! test-sfrag-table (vector-ref frag-data 0))
    (set! test-stmt-table (vector-ref frag-data 1))
    (set! test-locals-list (vector-ref frag-data 2))
    (set! test-header-list (vector-ref frag-data 3))
    (set! test-trailer-list (vector-ref frag-data 4))
    (set! test-middle-list (vector-ref frag-data 5))
    )
  *UNSPECIFIED*
)
