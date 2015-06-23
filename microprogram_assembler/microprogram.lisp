(in-package #:mcasm)

(defparameter +microprogram-version+ #x12)

(defun alloc-imm (sz)
  (%set-datum-imm $alloc-size sz)
  (alloc $alloc-size))

(defun alloc (sz-reg)
  (%cpy $alloc-addr $gc-firstfree)
  (%add $gc-firstfree sz-reg)
  (%cmp-datum $gc-firstfree $gc-mem-limit)
  ;; TODO
  )

(defun %store-typed (datum-reg addr-reg addr-imm type)
  (%set-type-imm $car type)
  (%set-datum $car datum-reg)
  (%store $car addr-reg addr-imm))

(defun %make-obj (result-reg datum-reg type)
  (alloc $one)
  (%store-typed datum-reg $alloc-addr 0 type)
  (%set-datum result-reg $alloc-addr))

(defun %make-char (result-reg datum-reg)
  (with-new-label ("make-char-const" constant-char)
    (with-new-label ("make-char-non-const" non-constant-char)
      (%set-datum-imm result-reg %area-chars)
      (%add result-reg datum-reg)
      (with-force-label (non-constant-char)
	(%cmp-datum-imm datum-reg +constant-chars+)
	(%branch* $zero non-constant-char (not N))
	(%cmp-datum-imm datum-reg 0)
	(%branch* $zero non-constant-char N))
      (jump-imm constant-char)
      (make-label non-constant-char)
      (%make-obj result-reg datum-reg +type-char+)
      (make-label constant-char))))

(defun %make-int (result-reg datum-reg)
  (with-new-label ("make-int-const" constant-int)
    (with-new-label ("make-int-non-const" non-constant-int)
      (%set-datum-imm result-reg %area-ints)
      (%add result-reg datum-reg)
      (with-force-label (non-constant-int)
	(%cmp-datum-imm datum-reg +constant-ints+)
	(%branch* $zero non-constant-int (not N))
	(%cmp-datum-imm datum-reg 0)
	(%branch* $zero non-constant-int N))
      (jump-imm constant-int)
      (make-label non-constant-int)
      (%make-obj result-reg datum-reg +type-int+)
      (make-label constant-int))))

(defun %load-typed (result-reg addr-reg addr-imm type err-handler)
  (%load result-reg addr-reg addr-imm)
  (%cmp-type-imm result-reg type)
  (branchimm-false err-handler))

(defun %cons (result-reg car-reg cdr-reg)
  (%set-type-imm $car +type-cons+)
  (%set-type-imm $cdr +type-snoc+)
  (%set-datum $car car-reg)
  (%set-datum $cdr cdr-reg)
  (alloc $two)
  (%store $car $alloc-addr 0)
  (%store $cdr $alloc-addr 1)
  (%set-datum result-reg $alloc-addr))

(defun %car (result-reg cons-reg err-handler)
  (%load result-reg cons-reg 0)
  (%cmp-type-imm result-reg +type-cons+)
  (branchimm-false err-handler))

(defun %cdr (result-reg cons-reg err-handler)
  ;; TODO should check that cons-reg actually points to a cons
  ;; cell
  (%load result-reg cons-reg 1)
  (%cmp-type-imm result-reg +type-snoc+)
  (branchimm-false err-handler))

(defun call (addr)
  (with-new-label ("call" return-addr)
    (%cmp-datum-imm $mc-stack-top $mc-stack-max)
    (branchimm :call-error)
    (let ((return-addr return-addr))
      (force-label return-addr)
      (%set-datum-imm (indirect-register $mc-stack-top) return-addr))
    (%add $mc-stack-top $one)
    (jump-imm addr)
    (make-label return-addr)))

(defun ret ()
  (%cmp-datum-imm $mc-stack-top $mc-stack-min)
  (branchimm :ret-error)
  (%sub $mc-stack-top $one)
  (jump-reg (indirect-register $mc-stack-top)))

(defun %error-imm (error-type)
  (%set-datum-imm $car %error)
  (%set-datum-imm $cdr error-type)
  (%cons $s-condition $car $cdr)
  (%set-datum-imm $mc-stack-top $mc-stack-min)
  (call :interrupt)
  (jump-imm :main-loop-end))

(defun %error (error-type-reg)
  (%set-datum-imm $car %error)
  (%cons $s-condition $car error-type-reg)
  (%set-datum-imm $mc-stack-top $mc-stack-min)
  (call :interrupt)
  (jump-imm :main-loop-end))

(defun select-device (devnr-reg)
  (%when-not (%cmp-datum $io-devnr devnr-reg)
    (%cpy $io-devnr devnr-reg)
    (%store $io-devnr $io-mem-addr %io-curdev)))

(defun select-device-imm (devnr)
  (%when-not (%cmp-datum-imm $io-devnr devnr)
    (%set-datum-imm $io-devnr devnr)
    (%store $io-devnr $io-mem-addr %io-curdev)))

(defun message (msg-reg) ; output a char from a register
  (select-device-imm +dev-serial+)
  (%store msg-reg $io-mem-addr %io-object))

(defun message-reg-no-nl (reg)
  (%set-datum $message reg)
  (call :message-reg))

(defun message-reg (reg) ; output an integer from a register
  (message-reg-no-nl reg)
  (message-imm #\Return)
  (message-imm #\Newline))

(defun message-imm (msg) ; output an immediate character
  (%set-type-imm $message +type-char+)
  (%set-datum-imm $message (char-int msg))
  (message $message))

(defun message-str-no-nl (str)
  (%set-type-imm $message +type-char+)
  (select-device-imm +dev-serial+)
  (loop for ch across str do
       (%set-datum-imm $message (char-int ch))
       (%store $message $io-mem-addr %io-object)))

(defun message-str (str)
  (message-str-no-nl str)
  (message-imm #\Return)
  (message-imm #\Newline))

(defun e-expr () (indirect-register $e-expr))
(defun e-arg () (indirect-register $e-arg))
(defun e-result () (indirect-register $e-result))
(defun e-phase () (indirect-register $e-phase))

(defun push-eframe ()
  (with-new-label ("push-eframe-free-frame" push-eframe-free-frame)
    (%add $e-expr $e/f-frame-size)
    (%add $e-arg $e/f-frame-size)
    (%add $e-result $e/f-frame-size)
    (%add $e-phase $e/f-frame-size)

    ;; new frame in use or above top?
    (%cmp-type-imm (indirect-register $e-expr) +type-none+)
    ;; if so, call the subroutine to handle such cases
    (branchimm push-eframe-free-frame)
    (call :push-eframe-handle-overflow)
    (make-label push-eframe-free-frame)

    (%set-type-imm (e-expr) +type-cons+)
    (%set-datum-imm (e-arg) %nil)
    (%set-datum-imm (e-result) %nil))) ; caller must set $e-expr, $e-phase

(defun pop-eframe ()
  (with-new-label ("pop-eframe-start" pop-eframe-start)
    (with-new-label ("pop-eframe-non-empty-frame" pop-eframe-non-empty-frame)
      (with-new-label ("pop-eframe-not-func-frame" pop-eframe-not-func-frame)
	(make-label pop-eframe-start)
	(%set-type-imm (indirect-register $e-expr) +type-none+)

	(%sub $e-expr $e/f-frame-size)
	(%sub $e-arg $e/f-frame-size)
	(%sub $e-result $e/f-frame-size)
	(%sub $e-phase $e/f-frame-size)

	;; is this frame empty or below bottom?
	(%cmp-type-imm (indirect-register $e-expr) +type-none+)
	(branchimm-false pop-eframe-non-empty-frame)
	(call :pop-eframe-handle-underflow)
	(make-label pop-eframe-non-empty-frame)

	(%cmp-type-imm (indirect-register $e-expr) +type-function+)
	(branchimm-false pop-eframe-not-func-frame)
	(%set-datum $f-func (indirect-register $e-expr))
	(%set-datum $f-env (indirect-register $e-arg))
	(jump-imm pop-eframe-start)
	(make-label pop-eframe-not-func-frame)))))



(defun write-microprogram (&key (output-format :simulator))
  (with-assembly ("/tmp/microcode" :output-format output-format)
    :init

    ;; I/O init:
    (%load $io-devnr $io-mem-addr %io-curdev)

    (message-str (format nil "IGOREV INIT v. 0x~X" +microprogram-version+))


    ;; write initial data to memory:

    ;; nil/t/symbols, strings:
    (%store $init1 $zero %nil)

;;     (message-str "READ NIL,")
;;     (%load $tmp1 $zero %nil)
;;     (message-reg $tmp1)
;;     (%get-type $tmp2 $tmp1)
;;     (message-reg $tmp2)
    
    (%store $init2 $zero 1)
    (%set-type-imm $init1 +type-ptr+)
    (%set-type-imm $init2 +type-ptr+)
    (%set-type-imm $init3 +type-ptr+)
    :init-mem-symbols-loop
    (%set-datum $init1 (indirect-register $init-counter))
    (%shift-r $init1 $init-shift1)
    (%set-datum $init2 (indirect-register $init-counter))
    (%shift-r $init2 $init-shift2)
    (%and $init2 $init-char-mask)
    (%set-datum $init3 (indirect-register $init-counter))
    (%and $init3 $init-char-mask)
    (%set-type-imm (indirect-register $init-counter) 0)
    (%set-datum-imm (indirect-register $init-counter) 0)
    (%set-datum-imm $init-counter2 $init1)
    :init-mem-symbols-loop2
    (%cmp-datum-imm (indirect-register $init-counter2) 0)
    (branchimm :init-mem-symbols-end-symbol)
    (%add (indirect-register $init-counter2) $init-chars-start)
    (%incr $init-symbol-char-addr)
    (%store (indirect-register $init-counter2) $init-symbol-char-addr 0)
    :init-mem-symbols-loop2-continue
    (%cmp-datum-imm $init-counter2 $init3)
    (branchimm :init-mem-symbols-loop2-end)
    (%incr $init-counter2)
    (jump-imm :init-mem-symbols-loop2)
    :init-mem-symbols-end-symbol
    (%store-typed $zero $init-symbol-addr 0 +type-none+) ; in case there is no symbol
    (%sub* $init-symbol-array $init-symbol-char-addr $init-symbol-str-addr)
    (branchimm
     :init-mem-symbols-end-symbol-next) ; if there are no characters,
					; just skip to the next symbol
    (%set-type-imm $init-symbol-array +type-array+)
    (%store $init-symbol-array $init-symbol-str-addr 0)
    (%store $list-terminator $init-symbol-char-addr 1)
    (%store-typed $init-symbol-str-addr $init-symbol-addr 0 +type-symbol+)
    (%add $init-symbol-char-addr 2)
    (%set-datum $init-symbol-str-addr $init-symbol-char-addr)
    :init-mem-symbols-end-symbol-next
    (%incr $init-symbol-addr)
    (jump-imm :init-mem-symbols-loop2-continue)
    :init-mem-symbols-loop2-end
    (%incr $init-counter)
    (%cmp-type-imm (indirect-register $init-counter) +type-int+)
    (branchimm :init-mem-symbols-loop)

    ;; builtins:
    (%set-type-imm $init1 +type-builtin+)
    (%set-datum-imm $init1 +first-builtin+)
    :init-mem-builtins-loop
    (%store $init1 $init1 %area-builtins)
    (%cmp-datum-imm $init1 +last-builtin+)
    (branchimm :init-mem-builtins-loop-end)
    (%incr $init1)
    (jump-imm :init-mem-builtins-loop)
    :init-mem-builtins-loop-end

    ;; characters:
    (%set-type-imm $init1 +type-char+)
    (%set-datum-imm $init1 0)
    :init-mem-chars-loop
    (%store $init1 $init1 %area-chars)
    (%incr $init1)
    (%cmp-datum-imm $init1 +constant-chars+)
    (branchimm-false :init-mem-chars-loop)

    ;; ints:
    (%set-type-imm $init1 +type-int+)
    (%set-datum-imm $init1 0)
    :init-mem-ints-loop
    (%store $init1 $init1 %area-ints)
    (%incr $init1)
    (%cmp-datum-imm $init1 +constant-ints+)
    (branchimm-false :init-mem-ints-loop)

    ;; symbol list:
    (%set-type-imm $init1 +type-cons+)
    (%set-type-imm $init2 +type-snoc+)
    (%set-datum-imm $init1 2)                   ; init1: address of symbol
    (%set-datum-imm $init2 (+ %area-symlist 2)) ; init2: address of next cons cell
    :init-mem-symlist-loop
    (%load $init3 $init1 0)                     ; init3: current symbol
    (%cmp-type-imm $init3 +type-none+)
    (branchimm
     :init-mem-symlist-loop-continue) ; skip to next if no symbol
				      ; (there may be gaps)
    (%store $init1 $init2 -2)
    (%store $init2 $init2 -1)
    (%add $init2 $two)
    :init-mem-symlist-loop-continue
    (%incr $init1)
    (%cmp-datum-imm $init1 +last-symbol+)
    (branchimm-false :init-mem-symlist-loop)
    (%store $init1 $init2 -2)
    (%store $list-terminator $init2 -1)

    ;; memory root pointer:
    (%set-type-imm $tmp1 +type-cons+)
    (%set-datum-imm $tmp1 %nil)
    (%store $tmp1 $zero %memory-root)
    (%store $list-terminator $zero (+ %memory-root 1))
    ;; end memory initialization

    ;; most essential initialization:
    (%set-type-imm $zero +type-int+)
    (%set-datum-imm $zero 0)

    (%set-type-imm $one +type-int+)
    (%set-datum-imm $one 1)

    (%set-type-imm $two +type-int+)
    (%set-datum-imm $two 2)

;;     (%set-type-imm $list-terminator +type-snoc+)
;;     (%set-datum-imm $list-terminator 0)

    (%set-type-imm $mc-stack-top +type-int+)
    (%set-datum-imm $mc-stack-top $mc-stack-min)

    ;;(make-integer $gc-firstfree #x20000)
    (%set-type-imm $alloc-size +type-int+)
    (%set-type-imm $alloc-addr +type-int+)

;;     (%set-type-imm $io-mem-addr +type-int+)
;;     (%set-datum-imm $io-mem-addr #x3FFFF)
;;     (%set-datum-imm $tmp1 #x8)
;;     (%shift $io-mem-addr $tmp1)
    ;; end most essential initialization


    (message-str-no-nl "BOOT: ")
    :boot
    (select-device-imm +dev-boot+)
    (%load $tmp1 $io-mem-addr %io-size-l) ; $tmp1: boot program size
    (message-reg-no-nl $tmp1) (message-str " WORDS")
    (select-device-imm +dev-boot+)
;;     (%cmp-datum-imm $tmp1 0) ; temporary to avoid loading boot program
;;     (branchimm :boot-end)
    (%set-type-imm $tmp2 +type-int+)
    (%set-datum-imm $tmp2 0)              ; $tmp2: address counter
    (%store $tmp2 $io-mem-addr %io-addr-l)
    :boot-loop
    (%set-datum-imm $tmp4 #xFF)
    (%and $tmp4 $tmp2)
    (%cmp-datum-imm $tmp4 0)
    (branchimm-false :boot-loop-no-print)
    (message-reg-no-nl $tmp2)
    (message-imm #\Return)
    (select-device-imm +dev-boot+)
    :boot-loop-no-print

    (%load $tmp3 $io-mem-addr %io-object)
    (%store $tmp3 $tmp2 %boot-prog-start)
    (%incr $tmp2)
    ;;(message-reg $tmp2) (select-device-imm +dev-boot+)
    (%cmp-datum $tmp2 $tmp1)
    (branchimm-false :boot-loop)
    (%set-datum-imm $gc-firstfree %boot-prog-start)
    (%add $gc-firstfree $tmp2)
    :boot-end
    (message-str "COMPLETE")
    

    ;; start GC initialization
    (%set-datum-imm $gc-rootptr %memory-root)

    (%set-datum-imm $gc-startofmem (- %mem-reserved-top 2)) ; include root pointer

    ;; number of spaces
    (%set-datum-imm $gc-spaces +gc-spaces+)
    (%set-type-imm $gc-spaces +type-int+)

    ;; calculate spacesize
    ;; set this manually for now! not easy to replace div
    ;;(%set-datum-imm $gc-spacesize (/ (* 1048576 2) +gc-spaces+))
     ;;    (%div* $gc-spacesize $gc-maxblocks $gc-spaces)
     
    ;; find maximal address + 1 (sup)
    (%mul* $gc-sup $gc-spaces $gc-spacesize)

    ;; find start of gcspace
    (%sub* $gc-gcspace $gc-sup $gc-spacesize)

    (%set-datum-imm $tmp1 +gc-limit+)
    (%sub* $gc-mem-limit $gc-gcspace $tmp1)
    ;; end GC initialization


    ;; initialize evaluation stacks:
    (%set-datum-imm $e/f-frame-size 4)
    (%set-type-imm $e/f-below-marker +type-none+)
    (%set-type-imm $e/f-above-marker +type-cons+)

    (%set-datum-imm $tmp1 $e/f-min)
    :clear-e/f-loop
    (%set-type-imm (indirect-register $tmp1) +type-none+)
    (%set-datum-imm (indirect-register $tmp1) 0)
    (%add $tmp1 $one)
    (%cmp-datum-imm $tmp1 $e/f-max)
    (branchimm-false :clear-e/f-loop)

    (call :init-evaluation-level)

    ;; set current expression and environment to boot program's
    ;; expression and environment:
    (%set-datum-imm $tmp1 %boot-prog-start)
    (%car (e-expr) $tmp1 :err-not-a-pair)
    (%cdr $f-env $tmp1 :err-not-a-pair)
    (%set-datum-imm (e-phase) %phase-eval)



;;     (message-str "NIL IS ")
;;     (%load $tmp1 $zero %nil)
;;     (message-reg $tmp1)
;;     (message-str "TYPE ")
;;     (%get-type $tmp2 $tmp1)
;;     (message-reg $tmp2)
;;     (message-str "T IS ")
;;     (%load $tmp1 $zero 1)
;;     (message-reg $tmp1)
;;     (message-str "TYPE ")
;;     (%get-type $tmp2 $tmp1)
;;     (message-reg $tmp2)
;;     (message-str "IF IS ")
;;     (%load $tmp1 $zero 2)
;;     (message-reg $tmp1)
;;     (message-str "TYPE ")
;;     (%get-type $tmp2 $tmp1)
;;     (message-reg $tmp2)
;;     (message-str "CONS IS ")
;;     (%load $tmp1 $zero 6)
;;     (message-reg $tmp1)
;;     (message-str "TYPE ")
;;     (%get-type $tmp2 $tmp1)
;;     (message-reg $tmp2)
;;     (message-str "PHASE-EVAL IS ")
;;     (%load $tmp1 $zero #x40)
;;     (message-reg $tmp1)
;;     (message-str "TYPE ")
;;     (%get-type $tmp2 $tmp1)
;;     (message-reg $tmp2)
;;     (message-str "CONS FUNCTION IS ")
;;     (%load $tmp1 $zero #x106)
;;     (message-reg $tmp1)
;;     (message-str "TYPE ")
;;     (%get-type $tmp2 $tmp1)
;;     (message-reg $tmp2)
    



    :main-loop

    ;; check that phase is valid:
    (%cmp-datum-imm (e-phase) +first-phase+)
    (%branch* $zero :err-invalid-phase N)
    (%cmp-datum-imm (e-phase) (+ +last-phase+ 1))
    (%branch* $zero :err-invalid-phase (not N))

    ;;dispatch:
    (let ((label :phase-dispatch-table))
      (force-label label)
      (jump (e-phase) (- label +first-phase+)))

    :phase-dispatch-table
    (jump-imm :p-eval)
    (jump-imm :p-eval-args)
    (jump-imm :p-apply)
    (jump-imm :p-eval-if)
    (jump-imm :p-initial)
    (jump-imm :p-env-lookup)
    (jump-imm :p-env-lookup-local)
    (jump-imm :p-apply-function2)
    (jump-imm :p-bind-args)
    (jump-imm :p-eval-progn)
    (jump-imm :p-eval-args-top)
    (jump-imm :p-eval-args-cdr)
    (jump-imm :p-eval-args-cons)
    (jump-imm :p-eval-symbol)
    (jump-imm :p-set!)


    ;; PHASE: EVAL

    :p-eval
    (%load $car (e-expr) 0)
    (%cmp-type-imm $car +type-cons+)
    (branchimm :p-eval-form)
    (%cmp-type-imm $car +type-symbol+)
    (branchimm :p-eval-symbol1)
    :p-eval-self-evaluating
    (%cpy $tmp1 (e-expr))
    (pop-eframe)
    (%set-datum (e-result) $tmp1)
    (jump-imm :main-loop-end)


    :p-eval-symbol1
    (%cmp-datum-imm (e-expr) +first-magic-var+)
    (%branch* $zero :p-eval-symbol1-regular-var N)
    (%cmp-datum-imm (e-expr) (+ +last-magic-var+ 1))
    (%branch* $zero :p-eval-symbol1-regular-var (not N))

    :p-eval-symbol1-magic-var
    (%set-datum-imm $tmp1 %area-builtins)
    (%add $tmp1 (e-expr))
    (pop-eframe)
    (%set-datum (e-result) $tmp1)
;;     (%when (%cmp-datum-imm (e-expr) %symbol-table)
;;       (%set-datum-imm (e-result) %area-symlist))
    (jump-imm :main-loop-end)

    :p-eval-symbol1-regular-var
    (%set-datum $tmp1 (e-expr))
    (%set-datum-imm (e-phase) %phase-eval-symbol)
    (push-eframe)
    (%set-datum (e-expr) $tmp1)
    (%set-datum (e-arg) $f-env)
    (%set-datum-imm (e-phase) %phase-env-lookup)
    (jump-imm :main-loop-end)


    :p-eval-form
    (%load $car (e-expr) 0)
    (%load $cdr (e-expr) 1)
    (%cmp-datum-imm $car %quote)
    (branchimm :p-eval-form-quote)
    (%cmp-datum-imm $car %if)
    (branchimm :p-eval-form-if)
    (%cmp-datum-imm $car %lambda)
    (branchimm :p-eval-form-lambda)
    (%cmp-datum-imm $car %progn)
    (branchimm :p-eval-progn1)

    :p-eval-form-function
    (%set-datum-imm (e-phase) %phase-eval-args-top)
    (%set-datum $tmp1 $car)
    (push-eframe)
    (%set-datum (e-expr) $tmp1)
    (%set-datum-imm (e-phase) %phase-eval)
    (jump-imm :main-loop-end)

    :p-eval-form-quote
    (%set-datum $tmp1 $cdr)
    (pop-eframe)
    (%load $car $tmp1 0)
    (%set-datum (e-result) $car)
    (jump-imm :main-loop-end)

    :p-eval-form-lambda ; (%lambda name param-list expr)
    ;; TODO check args
    ;; TODO take name as additional argument
    (%car $tmp1 $cdr  :err-not-a-list) ; $tmp1: name
    (%cdr $cdr  $cdr  :err-not-a-list) ; $cdr: (param-list expr)
    (%car $tmp2 $cdr  :err-not-a-list) ; $tmp2: param-list
    (%cdr $cdr  $cdr  :err-not-a-list) ; $cdr: (expr)
    (%car $tmp3 $cdr  :err-not-a-list) ; $tmp3: expr
    (%cdr $cdr  $cdr  :err-not-a-list)
    (%cmp-datum-imm $cdr %nil)
    (branchimm-false :err-too-many-args)
    (%cons $tmp4 $f-env $list-terminator)   ; $tmp4: (env)
    (%cons $tmp4 $tmp3 $tmp4)               ; $tmp4: (expr env)
    (%cons $tmp4 $tmp2 $tmp4)               ; $tmp4: (param-list expr env)
    (%cons $tmp4 $tmp1 $tmp4)               ; $tmp4: (name param-list expr env)
    (%make-obj $tmp1 $tmp4 +type-function+) ; $tmp1: function (address)
    (pop-eframe)
    (%set-datum (e-result) $tmp1)
    (jump-imm :main-loop-end)

    :p-eval-form-if ; (%if test a b)
    (%load $tmp1 $cdr 0)
    ;;(%load $cdr $cdr 1)
    (%set-datum-imm (e-phase) %phase-eval-if)
    (push-eframe)
    (%set-datum (e-expr) $tmp1)
    (%set-datum-imm (e-phase) %phase-eval)
    (jump-imm :main-loop-end)


    ;; PHASE: EVAL-IF

    :p-eval-if ; (%if test a b) caddr, cadddr
    (%load $cdr (e-expr) 1)
    (%load $cdr $cdr 1) ;; cddr
    (%cmp-datum-imm (e-result) %nil)
    (branchimm-false :p-eval-if-true)
    (%load $cdr $cdr 1) ;; cdddr
    :p-eval-if-true
    (%load $car $cdr 0) ;; caddr/cadddr
    (%set-datum (e-expr) $car)
    (%set-datum-imm (e-phase) %phase-eval)
    (jump-imm :main-loop-end)


    ;; PHASE: EVAL-PROGN

    :p-eval-progn1 ; this first part belongs to EVAL phase
    (%set-datum (e-arg) $cdr)
    (%set-datum-imm (e-result) %nil)
    (%set-datum-imm (e-phase) %phase-eval-progn)
    :p-eval-progn ; (%progn form ...)
    (%cmp-datum-imm (e-arg) %nil)
    (branchimm :p-eval-progn-empty)
    (%car $tmp1 (e-arg) :err-not-a-list)  ; $tmp1: first argument
    (%cdr (e-arg) (e-arg) :err-not-a-list)
    (%cmp-datum-imm (e-arg) %nil)
    (branchimm :p-eval-progn-last)
    ;; more than one argument:
    (push-eframe)
    (%set-datum (e-expr) $tmp1)
    (%set-datum-imm (e-phase) %phase-eval)
    (jump-imm :main-loop-end)
    :p-eval-progn-empty ; no arguments
    (pop-eframe)
    (%set-datum-imm (e-result) %nil)
    (jump-imm :main-loop-end)
    :p-eval-progn-last ; exactly one argument, eval it in this eframe
    (%set-datum (e-expr) $tmp1)
    (%set-datum-imm (e-arg) %nil)
    (%set-datum-imm (e-result) %nil)
    (%set-datum-imm (e-phase) %phase-eval)
    (jump-imm :main-loop-end)


    ;; PHASE: EVAL-SYMBOL

    :p-eval-symbol
    (%cmp-datum-imm (e-result) %nil)
    (branchimm :err-unbound-symbol)
    (%cdr $tmp1 (e-result) :err-invalid-state)
    (pop-eframe)
    (%set-datum (e-result) $tmp1)
    (jump-imm :main-loop-end)


    ;; PHASES: EVAL-ARGS, EVAL-ARGS-{TOP,CDR,CONS}

    :p-eval-args-top
    (%set-datum (e-arg) (e-result)) ; copy function pointer to (e-arg)
    (%set-datum-imm (e-phase) %phase-apply)
    (%cdr $tmp1 (e-expr) :err-malformed-form)
    (push-eframe)
    (%set-datum-imm (e-phase) %phase-eval-args)
    (%set-datum (e-expr) $tmp1)
    (jump-imm :main-loop-end)

    :p-eval-args
    (%cmp-datum-imm (e-expr) %nil)
    (branchimm :p-eval-args-empty-list)
    (%car $tmp1 (e-expr) :p-eval-args-error)
    (%set-datum-imm (e-phase) %phase-eval-args-cdr)
    (push-eframe)
    (%set-datum (e-expr) $tmp1)
    (%set-datum-imm (e-phase) %phase-eval)
    (jump-imm :main-loop-end)
    :p-eval-args-empty-list
    (pop-eframe)
    (%set-datum-imm (e-result) %nil)
    (jump-imm :main-loop-end)
;;     (%set-datum (e-arg) (e-result))
;;     (%load $cdr (e-expr) 1)
;;     (%cmp-datum-imm $cdr %nil)
;;     (branchimm :p-apply1)
;;     (%load $cdr $cdr 1)
;;     (%load $car $cdr 0)
;;     (%set-datum-imm (e-phase) %phase-apply)
;;     (call :push-e)
;;     (%set-datum (e-expr) $car)
;;     (jump-imm :main-loop-end)

    :p-eval-args-cdr
    (%set-datum (e-arg) (e-result))
    (%cdr $tmp1 (e-expr) :p-eval-args-error)
    (%set-datum-imm (e-phase) %phase-eval-args-cons)
    (push-eframe)
    (%set-datum (e-expr) $tmp1)
    (%set-datum-imm (e-phase) %phase-eval-args)
    (jump-imm :main-loop-end)

    :p-eval-args-cons
    (%cons $tmp1 (e-arg) (e-result))
    (pop-eframe)
    (%set-datum (e-result) $tmp1)
    (jump-imm :main-loop-end)

    :p-eval-args-error ; common to p-eval-args, p-eval-args-cdr, p-eval-args-cons
    (%error %err-invalid-arg-list)


    ;; PHASE: ENV-LOOKUP

    :p-env-lookup
    ;; (e-expr): variable name (address)
    ;; (e-arg): env (address)
    (%cmp-datum-imm (e-result) %nil)
    (branchimm-false :p-env-lookup-ret)
    (%cmp-datum-imm (e-arg) %nil)
    (branchimm :p-env-lookup-ret)
    ;;(branchimm :err-unbound-symbol)
    (%set-datum $tmp1 (e-expr))
    (%car $tmp2 (e-arg) :err-invalid-env)
    (%cdr (e-arg) (e-arg) :err-invalid-env)
    (push-eframe)
    (%set-datum (e-expr) $tmp1)
    (%set-datum (e-arg) $tmp2)
    (%set-datum-imm (e-phase) %phase-env-lookup-local)
    (jump-imm :main-loop-end)
    :p-env-lookup-ret
    (%set-datum $tmp1 (e-result))
    (pop-eframe)
    (%set-datum (e-result) $tmp1)
    (jump-imm :main-loop-end)


    ;; PHASE: ENV-LOOKUP-LOCAL
    
    :p-env-lookup-local
    ;; (e-expr): variable name (address)
    ;; (e-arg): env binding list (address)
    (%set-datum-imm $tmp1 %nil)
    (%cmp-datum-imm (e-arg) %nil)
    (branchimm :p-env-lookup-local-ret)
    (%car $tmp1 (e-arg) :err-invalid-env) ; $tmp1: (symbol . value)
    (%car $tmp2 $tmp1 :err-invalid-env)  ; $tmp2: symbol
    (%cmp-datum $tmp2 (e-expr))
    (branchimm :p-env-lookup-local-ret)
    (%cdr (e-arg) (e-arg) :err-invalid-env)
    (jump-imm :main-loop-end)
    :p-env-lookup-local-ret
    (pop-eframe)
    (%set-datum (e-result) $tmp1)
    (jump-imm :main-loop-end)


    ;; PHASE: BIND-ARGS

    :p-bind-args
    ;; (e-expr): existing bindings
    ;; (e-arg): (rest of) param list
    ;; (e-result): (rest of) arg list
    (%load $params-car (e-arg) 0)
    ;; dispatch on type of param list:
    (%cmp-type-imm $params-car +type-cons+)
    (branchimm :p-bind-args-head)
    (%cmp-type-imm $params-car +type-nil+)
    (branchimm :p-bind-args-empty)
    (%cmp-type-imm $params-car +type-symbol+)
    (branchimm :p-bind-args-tail)
    (jump-imm :err-invalid-param-list)

    :p-bind-args-head
    ;; param list is of form (p1 . rest). check that arg list has form
    ;; (a1 . rest) and that p1 is actually a symbol. if so, bind p1 to
    ;; a1 and continue cdr-ing down both lists:
    (%load $tmp1 $params-car 0)
    (%cmp-type-imm $tmp1 +type-symbol+)
    (branchimm-false :err-invalid-param-list)
    (%load $args-car (e-result) 0)
    (%cmp-type-imm $args-car +type-cons+)
    (branchimm-false :err-too-few-args)
    ;; make a binding (p1 . a1):
    (%cons $tmp1 $params-car $args-car)
    ;; cons the new binding on the list:
    (%cons (e-expr) $tmp1 (e-expr))
    ;; cdr down param and arg list:
    (%load (e-arg) (e-arg) 1)
    (%load (e-result) (e-result) 1)
    (jump-imm :main-loop-end)

    :p-bind-args-tail
    ;; param list is of form p1, that is, just a single symbol; so
    ;; bind this to the whole arglist and return:
    (%cons $tmp1 (e-arg) (e-result))
    (%cons $tmp1 $tmp1 (e-expr))
    (pop-eframe)
    (%set-datum (e-result) $tmp1)
    (jump-imm :main-loop-end)

    :p-bind-args-empty
    ;; empty param list; check that arg list is empty too, and return:
    (%cmp-datum-imm (e-result) %nil)
    (branchimm-false :err-too-many-args)
    (%set-datum $tmp1 (e-expr))
    (pop-eframe)
    (%set-datum (e-result) $tmp1)
    (jump-imm :main-loop-end)


    ;; PHASE: APPLY

    :p-apply
    ;; (e-arg): function (address)
    ;; (e-result): argument list (address)
    (%load $apply-func (e-arg) 0)
    (%cmp-type-imm $apply-func +type-builtin+)
    (branchimm :p-apply-builtin)
    (%cmp-type-imm $apply-func +type-function+)
    (branchimm :p-apply-function1)
    (%error-imm %err-not-a-function)

    :p-apply-builtin ; $apply-func contains the identifier of the
		     ; function (the adress of the symbol used for
		     ; naming it), use this as offset into the table
		     ; below
    (%set-type-imm $builtin-arg1 +type-none+)
    (%set-type-imm $builtin-arg2 +type-none+)
    (%set-type-imm $builtin-arg3 +type-none+)

    ;; check builtin identifier:
    (%cmp-datum-imm $apply-func +first-builtin+)
    (%branch* $zero :err-invalid-builtin N)
    (%cmp-datum-imm $apply-func (+ +last-builtin+ 1))
    (%branch* $zero :err-invalid-builtin (not N))

    (let ((label :p-apply-table))
      (force-label label)
      (jump $apply-func (- label +first-builtin+)))
    :p-apply-table
    (jump-imm :builtin-cons)
    (jump-imm :builtin-car)
    (jump-imm :builtin-cdr)
    (jump-imm :builtin-eval)
    (jump-imm :builtin-apply)
    (jump-imm :builtin-type)
    (jump-imm :builtin-make-array)
    (jump-imm :builtin-array-size)
    (jump-imm :builtin-array-get)
    (jump-imm :builtin-array-set)
    (jump-imm :builtin-make-symbol)
    (jump-imm :builtin-symbol-to-string)
    (jump-imm :builtin-char-to-int)
    (jump-imm :builtin-int-to-char)
    (jump-imm :builtin-get-char)
    (jump-imm :builtin-put-char)
    (jump-imm :builtin-num-devices)
    (jump-imm :builtin-device-type)
    (jump-imm :builtin-set-address)
    (jump-imm :builtin-get-address)
    (jump-imm :builtin-error)
    (jump-imm :builtin-add)
    (jump-imm :builtin-sub)
    (jump-imm :builtin-mul)
    (jump-imm :builtin-div)
    (jump-imm :builtin-bitwise-and)
    (jump-imm :builtin-bitwise-or)
    (jump-imm :builtin-bitwise-not)
    (jump-imm :builtin-bitwise-shift)
    (jump-imm :builtin-current-environment)
    (jump-imm :builtin-make-eval-state)
    (jump-imm :builtin-eval-partial)
    (jump-imm :builtin-define)
    (jump-imm :builtin-undefine)
    (jump-imm :builtin-eq?)
    (jump-imm :builtin-num-eq?)
    (jump-imm :builtin-char-eq?)
    (jump-imm :builtin-less-than?)
    (jump-imm :builtin-mod)
    (jump-imm :builtin-set!)
    (jump-imm :builtin-set-car!)
    (jump-imm :builtin-set-cdr!)
    (jump-imm :builtin-function-data)
    (jump-imm :builtin-builtin-name)
    (jump-imm :builtin-device-size)
    (jump-imm :builtin-device-status)

    :builtin-cons ; (%cons obj1 obj2)
    (%set-type-imm $builtin-arg1 +type-t+)
    (%set-type-imm $builtin-arg2 +type-t+)
    (call :fetch-args)
    (%cons $apply-result $builtin-arg1 $builtin-arg2)
    (jump-imm :p-apply-end)

    :builtin-car ; (%car cons-cell)
    (%set-type-imm $builtin-arg1 +type-cons+)
    (call :fetch-args)
    (%set-datum $apply-result $builtin-arg1-val)
    (jump-imm :p-apply-end)

    :builtin-cdr ; (%cdr cons-cell)
    (%set-type-imm $builtin-arg1 +type-cons+)
    (call :fetch-args)
    (%load $apply-result $builtin-arg1 1)
    (jump-imm :p-apply-end)

    :builtin-eq? ; (%eq? obj1 obj2)
    (%set-type-imm $builtin-arg1 +type-t+)
    (%set-type-imm $builtin-arg2 +type-t+)
    (call :fetch-args)
    (%set-datum-imm $apply-result %nil)
    (when= ($builtin-arg1 $builtin-arg2)
      (%set-datum-imm $apply-result %t))
    (jump-imm :p-apply-end)

    :builtin-type ; (%type obj)
    (%set-type-imm $builtin-arg1 +type-t+)
    (call :fetch-args)
    (%get-type $tmp1 $builtin-arg1-val)
    (%make-obj $apply-result $tmp1 +type-int+)
    (jump-imm :p-apply-end)

    :builtin-eval ; (%eval expr env)
    (%set-type-imm $builtin-arg1 +type-t+)
    (%set-type-imm $builtin-arg2 +type-t+)
    (call :fetch-args)
    (%set-datum $apply-eval-expr $builtin-arg1)
    (%set-datum $apply-eval-env $builtin-arg2)
    (call :push-or-reuse-fframe)
    (%set-datum-imm $f-func %eval) ; should maybe have a dedicated symbol for this
    (%set-datum $f-env $apply-eval-env)
    (%set-datum (e-expr) $apply-eval-expr)
    (%set-datum-imm (e-phase) %phase-eval)
    (jump-imm :main-loop-end) ; note: not :p-apply-end

    :builtin-apply ; (%apply func args)
    ;; move stuff around and go through APPLY phase again:
    (%set-type-imm $builtin-arg1 +type-t+) ; function or builtin
    (%set-type-imm $builtin-arg2 +type-t+) ; list (cons or nil)
    (call :fetch-args)
    (%set-datum (e-arg) $builtin-arg1)
    (%set-datum (e-result) $builtin-arg2)
    (jump-imm :main-loop-end)

    :builtin-make-array ; (%make-array size init-value)
    (%set-type-imm $builtin-arg1 +type-int+)
    (%set-type-imm $builtin-arg2 +type-t+)
    (call :fetch-args)
    ;; TODO check size
    (%set-datum $tmp1 $builtin-arg1-val)
    (%add $tmp1 $two) ; $tmp1: words needed (array object + pointers + end marker)
    (alloc $tmp1)
    (%store-typed $builtin-arg1-val $alloc-addr 0 +type-array+)
    (%add $tmp1 $alloc-addr)
    (%decr $tmp1)                  ; $tmp1: address of end marker
    (%set-datum $tmp2 $alloc-addr)
    (%incr $tmp2)                  ; $tmp2: address to store pointer at
    :builtin-make-array-loop
    (%store-typed $builtin-arg2 $tmp2 0 +type-ptr+)
    (%incr $tmp2)
    (%cmp-datum $tmp2 $tmp1)
    (branchimm-false :builtin-make-array-loop)
    (%store-typed $zero $tmp2 0 +type-snoc+) ; end marker
    (%set-datum $apply-result $alloc-addr)
    (jump-imm :p-apply-end)

    :builtin-array-size ; (%array-size array)
    (%set-type-imm $builtin-arg1 +type-array+)
    (call :fetch-args)
    (%make-obj $apply-result $builtin-arg1-val +type-int+)
    (jump-imm :p-apply-end)

    :builtin-array-get ; (%array-get array index)
    (%set-type-imm $builtin-arg1 +type-array+)
    (%set-type-imm $builtin-arg2 +type-int+)
    (call :fetch-args)

    ;; check index;
    (%cmp-datum $builtin-arg2-val $builtin-arg1-val)
    (%branch* $zero :err-invalid-array-index (not N))
    (%cmp-datum $builtin-arg2-val $zero)
    (%branch* $zero :err-invalid-array-index N)

    (%add* $tmp1 $builtin-arg1 $builtin-arg2-val)
    (%load $apply-result $tmp1 1)
    (jump-imm :p-apply-end)

    :builtin-array-set ; (%array-set array index value) => array
    (%set-type-imm $builtin-arg1 +type-array+)
    (%set-type-imm $builtin-arg2 +type-int+)
    (%set-type-imm $builtin-arg3 +type-t+)
    (call :fetch-args)

    ;; check index;
    (%cmp-datum $builtin-arg2-val $builtin-arg1-val)
    (%branch* $zero :err-invalid-array-index (not N))
    (%cmp-datum $builtin-arg2-val $zero)
    (%branch* $zero :err-invalid-array-index N)

    (%add* $tmp1 $builtin-arg1 $builtin-arg2-val)
    (%store-typed $builtin-arg3 $tmp1 1 +type-ptr+)
    (%set-datum $apply-result $builtin-arg1)
    (jump-imm :p-apply-end)

    :builtin-make-symbol ; (%make-symbol str)
    (%set-type-imm $builtin-arg1 +type-array+) ; TODO check that it is a string
    (call :fetch-args)
    (%make-obj $apply-result $builtin-arg1 +type-symbol+)
    (jump-imm :p-apply-end)

    :builtin-symbol-to-string ; (%symbol-to-string symb)
    (%set-type-imm $builtin-arg1 +type-symbol+)
    (call :fetch-args)
    (%set-datum $apply-result $builtin-arg1-val)
    (jump-imm :p-apply-end)

    :builtin-char-to-int ; (%char-to-int ch)
    (%set-type-imm $builtin-arg1 +type-char+)
    (call :fetch-args)
    (%make-int $apply-result $builtin-arg1-val)
    (jump-imm :p-apply-end)

    :builtin-int-to-char ; (%int-to-char n)
    (%set-type-imm $builtin-arg1 +type-int+)
    (call :fetch-args)
    (%make-char $apply-result $builtin-arg1-val)
    ;;(%make-obj $apply-result $builtin-arg1-val +type-char+)
    (jump-imm :p-apply-end)

    :builtin-char-eq? ; (%char-eq? ch1 ch2)
    (%set-type-imm $builtin-arg1 +type-char+)
    (%set-type-imm $builtin-arg2 +type-char+)
    (call :fetch-args)
    (%set-datum-imm $apply-result %nil)
    (%when (%cmp-datum $builtin-arg1-val $builtin-arg2-val)
      (%set-datum-imm $apply-result %t))
    (jump-imm :p-apply-end)

    :builtin-get-char ; (%get-char devnr)
    (%set-type-imm $builtin-arg1 +type-int+)
    (call :fetch-args)
    (select-device $builtin-arg1-val)
;;    :builtin-get-char-read
    (%load-typed $tmp1 $io-mem-addr %io-object +type-char+ :err-io-error)
    ;; TODO handle errors
    (%make-char $apply-result $tmp1)
    (jump-imm :p-apply-end)

;;     :builtin-get-char-io-error
;;     (message-str "I/O ERROR")
;;     (message-reg $tmp1)
;;     (%get-type $tmp2 $tmp1)
;;     (message-reg $tmp2)
;;     (jump-imm :builtin-get-char-read)

    :builtin-put-char ; (%put-char devnr ch) => ch
    (%set-type-imm $builtin-arg1 +type-int+)
    (%set-type-imm $builtin-arg2 +type-char+)
    (call :fetch-args)
    (select-device $builtin-arg1-val)
    (%store $builtin-arg2-val $io-mem-addr %io-object)
    ;; TODO handle errors
    (%set-datum $apply-result $builtin-arg2)
    (jump-imm :p-apply-end)

    :builtin-num-devices ; (%num-devices)
    (call :fetch-args)
    (%load-typed $tmp1 $io-mem-addr %io-devices +type-int+ :err-io-error)
    (%make-int $apply-result $tmp1)
    (jump-imm :p-apply-end)

    :builtin-device-type ; (%device-type devnr)
    (%set-type-imm $builtin-arg1 +type-int+)
    (call :fetch-args)
    (select-device $builtin-arg1-val)
    (%load-typed $tmp1 $io-mem-addr %io-identification +type-int+ :err-io-error)
    (%make-int $apply-result $tmp1)
    (jump-imm :p-apply-end)

    :builtin-set-address ; (%set-address devnr addr) => addr
    ;; only sets lower part of address as of now
    (%set-type-imm $builtin-arg1 +type-int+)
    (%set-type-imm $builtin-arg2 +type-int+)
    (call :fetch-args)
    (select-device $builtin-arg1-val)
    (%store-typed $builtin-arg2-val $io-mem-addr %io-addr-l +type-int+)
    (%set-datum $apply-result $builtin-arg2)
    (jump-imm :p-apply-end)

    :builtin-get-address ; (%get-address devnr)
    ;; only gets lower part of address as of now
    (%set-type-imm $builtin-arg1 +type-int+)
    (call :fetch-args)
    (select-device $builtin-arg1-val)
    (%load-typed $tmp1 $io-mem-addr %io-addr-l +type-int+ :err-io-error)
    (%make-int $apply-result $tmp1)
    (jump-imm :p-apply-end)

    :builtin-device-size ; (%builtin-device-size devnr)
    ;; only get lower part of size
    (%set-type-imm $builtin-arg1 +type-int+)
    (call :fetch-args)
    (select-device $builtin-arg1-val)
    (%load-typed $tmp1 $io-mem-addr %io-size-l +type-int+ :err-io-error)
    (%make-int $apply-result $tmp1)
    (jump-imm :p-apply-end)

    :builtin-device-status ; (%builtin-device-status devnr)
    (%set-type-imm $builtin-arg1 +type-int+)
    (call :fetch-args)
    (select-device $builtin-arg1-val)
    (%load-typed $tmp1 $io-mem-addr %io-status +type-int+ :err-io-error)
    (%make-int $apply-result $tmp1)
    (jump-imm :p-apply-end)



    :builtin-error ; (%error reason)
    (%set-type-imm $builtin-arg1 +type-t+)
    (call :fetch-args)
    (%error $builtin-arg1)

    :builtin-add
    (call :builtin-binop-fetch-args)
    (%add* $apply-result-val $builtin-arg1-val $builtin-arg2-val)
    (%branch* $zero :err-overflow O)
    (jump-imm :builtin-binop-end)
    :builtin-sub
    (call :builtin-binop-fetch-args)
    (%sub* $apply-result-val $builtin-arg1-val $builtin-arg2-val)
    (%branch* $zero :err-overflow O)
    (jump-imm :builtin-binop-end)
    :builtin-mul
    (call :builtin-binop-fetch-args)
    (%mul* $apply-result-val $builtin-arg1-val $builtin-arg2-val)
    (%branch* $zero :err-overflow O)
    (jump-imm :builtin-binop-end)
    :builtin-div
    (call :builtin-binop-fetch-args)
    (%when (%cmp-datum-imm $builtin-arg2-val 0)
      (%error-imm %err-division-by-zero))
    ;; binary search for the answer
    (call :div-wrapper)
    (jump-imm :builtin-binop-end)
    :div-wrapper
    (%sub* $div-res $zero $one)
    (%cpy $div-sign $one)
    (%cmp-datum $builtin-arg1-val $zero)
    (%branch* $zero :div-nozero1 (not N))
    (%xor $div-sign $one)
    (%mul $builtin-arg1-val $div-res)
    :div-nozero1
    (%cmp-datum $builtin-arg2-val $zero)
    (%branch* $zero :div-nozero2 (not N))
    (%xor $div-sign $one)
    (%mul $builtin-arg2-val $div-res)
    :div-nozero2
    (%cmp-datum $div-sign $zero)
    (branchimm-false :div-nofix)
    (%sub $div-sign $one)
    :div-nofix
    (call :div-noneg)
    :div-afterdiv
    (%mul $div-low $div-sign)
    (%cpy $apply-result-val $div-low)
    :div-slutten
    (ret)

    ;; binaersoek: gitt arg1, arg2:
    ;; finn ans slik at ans*arg2<=arg1 og (ans+1)*arg2>arg1

    :div-noneg
    (%cmp-datum $builtin-arg1-val $builtin-arg2-val)
    (branchimm-false :div-notequal)
    (%cpy $div-low $one)
    (ret)
    :div-notequal
    (%cmp-datum $builtin-arg1-val $builtin-arg2-val)
    (%branch* $zero :div-fortsett (not N))
    (%cpy $div-low $zero)
    (ret)
    :div-fortsett
    (%set-datum $div-low $one)
    (%set-type-imm $div-low +type-int+)
    (%set-datum-imm $div-high 18631)
    (%set-type-imm $div-high +type-int+)
    (%set-datum-imm $div-mid 1801)
    (%set-type-imm $div-mid +type-int+)
    (%mul $div-high $div-mid) ;; voila, 2^25-1 (luckily 25 isn't prime)

    (%cmp-datum $builtin-arg2-val $zero)
    (branchimm-false :div-check1)
    (%cpy $div-low $zero)
    (jump-imm :div-end)
    ;; error
    :div-check1
    (%sub* $div-mid $div-high $div-low)
    (%cmp-datum $div-mid $one)
    (branchimm :div-end)

    :div-bsloop
    (%sub* $div-mid $div-high $div-low)
    (%shift-r $div-mid $one)
    (%add $div-mid $div-low)
    (%mul* $div-res $div-mid $builtin-arg2-val)
    (%branch* $zero :div-toohigh O)
    (%sub $div-res $one)
    (%cmp-datum $div-res $builtin-arg1-val)
    (%branch* $zero :div-toohigh (not N))
    (%cpy $div-low $div-mid)
    (jump-imm :div-check1)
    :div-toohigh
    (%cpy $div-high $div-mid)
    (jump-imm :div-check1)
    :div-end
    (ret)
    :builtin-mod
    (call :builtin-binop-fetch-args)
    (%cpy $mod-val1 $builtin-arg1-val)
    (%cpy $mod-val2 $builtin-arg2-val)
    (%when (%cmp-datum-imm $builtin-arg2-val 0)
      (%error-imm %err-division-by-zero))
    (call :div-wrapper)
    :modbreak
    (%mul $apply-result-val $mod-val2)
    (%sub $mod-val1 $apply-result-val)
    (%cpy $apply-result-val $mod-val1)
    (jump-imm :builtin-binop-end)
    :builtin-bitwise-and
    (call :builtin-binop-fetch-args)
    (%and* $apply-result-val $builtin-arg1-val $builtin-arg2-val)
    (jump-imm :builtin-binop-end)
    :builtin-bitwise-or
    (call :builtin-binop-fetch-args)
    (%or* $apply-result-val $builtin-arg1-val $builtin-arg2-val)
    (jump-imm :builtin-binop-end)
    :builtin-bitwise-not
    (%set-type-imm $builtin-arg1 +type-int+)
    (call :fetch-args)
    (%set-type-imm $apply-result-val +type-int+)
    (%not $apply-result-val $builtin-arg1-val)
    (jump-imm :p-apply-end)
    :builtin-bitwise-shift
    (%set-type-imm $builtin-arg1 +type-int+)
    (%set-type-imm $builtin-arg2 +type-int+)
    (call :fetch-args)
    (%cpy $apply-result-val $builtin-arg1-val)
    (%cmp-datum-imm $builtin-arg2-val 0)
    (%branch* $zero :builtin-bitwise-shift-right N)
    (%shift-l $apply-result-val $builtin-arg2-val)
    (jump-imm :builtin-binop-end)
    :builtin-bitwise-shift-right
    (%cpy $tmp1 $zero)
    (%sub $tmp1 $builtin-arg2-val) ; $tmp1 = -arg2
    (%shift-r $apply-result-val $tmp1)
    (jump-imm :builtin-binop-end)

    :builtin-binop-fetch-args ; subroutine
;;    (%set-type-imm $builtin-arg1 +type-t+)
;;    (%set-type-imm $builtin-arg2 +type-t+)
    (%set-type-imm $builtin-arg1 +type-int+) ; assume all binops want INTs as args
    (%set-type-imm $builtin-arg2 +type-int+)
    (jump-imm :fetch-args) ; tail call

    :builtin-binop-end
    ;; TODO check for errors
    (%cmp-type-imm $apply-result-val +type-int+)
    (branchimm :builtin-binop-end-int)
    (alloc-imm 1)
    (%store $apply-result-val $alloc-addr 0)
    (%set-datum $apply-result $alloc-addr)
    (jump-imm :p-apply-end)
    :builtin-binop-end-int
    (%make-int $apply-result $apply-result-val)
    (jump-imm :p-apply-end)

    :builtin-num-eq? ; (%num-eq? n1 n2)
    (call :builtin-binop-fetch-args)
    (%set-datum-imm $apply-result %nil)
    (%when (%cmp-datum $builtin-arg1-val $builtin-arg2-val)
      (%set-datum-imm $apply-result %t))
    (jump-imm :p-apply-end)

    :builtin-less-than? ; (%less-than? n1 n2)
    (call :builtin-binop-fetch-args)
    (%set-datum-imm $apply-result %t)
    (%cmp-datum $builtin-arg1-val $builtin-arg2-val)
    (%branch* $zero :builtin-less-than?-end N)
    (%set-datum-imm $apply-result %nil)
    :builtin-less-than?-end
    (jump-imm :p-apply-end)

    :builtin-current-environment ; (%current-environment)
    (call :fetch-args)
    (%set-datum $apply-result $f-env)
    (jump-imm :p-apply-end)

    :builtin-make-eval-state ; (%make-eval-state expr env)
    (%set-type-imm $builtin-arg1 +type-t+)
    (%set-type-imm $builtin-arg2 +type-t+)
    (call :fetch-args)
    ;; TODO should we do some typechecking here?
    (%set-datum $tmp1 $builtin-arg1)
    (%set-datum $tmp2 $builtin-arg2)
    (pop-eframe)
    (call :push-s)
    (call :init-evaluation-level)
    (%set-datum (e-expr) $tmp1)
    (%set-datum-imm (e-phase) %phase-eval)
    (%set-datum $f-env $tmp2)
    (call :interrupt)
    (jump-imm :main-loop-end) ; note: not :p-apply-end

    :builtin-eval-partial ; (%eval-partial state iterations) => new-state
    (%set-type-imm $builtin-arg1 +type-t+)
    (%set-type-imm $builtin-arg2 +type-int+)
    (call :fetch-args)
    ;; TODO should we do some typechecking here?
    (%set-datum $tmp1 $builtin-arg1)
    (%set-datum $tmp2 $builtin-arg2-val)
    (pop-eframe)
    (call :push-s)
    (%set-datum $s-addr $tmp1)
    (call :load-sframe-without-parent)
    (%set-datum $s-iterations $tmp2)
    (jump-imm :main-loop)

    :builtin-define ; (%define symb val) => val
    (%set-type-imm $builtin-arg1 +type-symbol+)
    (%set-type-imm $builtin-arg2 +type-t+)
    (call :fetch-args)
    (%cons $tmp1 $builtin-arg1 $builtin-arg2) ; $tmp1: new binding
    (%car $tmp2 $f-env :err-invalid-env)      ; $tmp2: local binding list
    (%cons $tmp1 $tmp1 $tmp2)                 ; $tmp1: new local binding list
    (%store-typed $tmp1 $f-env 0 +type-cons+) ; (set-car! $f-env $tmp1)
    (%set-datum $apply-result $builtin-arg2)
    (jump-imm :p-apply-end)

    :builtin-undefine ; (%undefine symb) => nil
    ;;(%set-type-imm $builtin-arg1 +type-symbol+)
    ;;(call :fetch-args)
    ;;TODO
    (message-str "UNDEF")
    (%halt)

    :builtin-set! ; (%set! symb val) => val
    (%set-type-imm $builtin-arg1 +type-symbol+)
    (%set-type-imm $builtin-arg2 +type-t+)
    (call :fetch-args)
    (%set-datum $tmp1 $builtin-arg1)
    (%set-datum (e-arg) $builtin-arg2)
    (%set-datum-imm (e-phase) %phase-set!)
    (push-eframe)
    (%set-datum (e-expr) $tmp1)
    (%set-datum (e-arg) $f-env)
    (%set-datum-imm (e-phase) %phase-env-lookup)
    (jump-imm :main-loop-end)

    :builtin-set-car! ; (%set-car! cell val) => val
    (%set-type-imm $builtin-arg1 +type-cons+)
    (%set-type-imm $builtin-arg2 +type-t+)
    (call :fetch-args)
    (%store-typed $builtin-arg2 $builtin-arg1 0 +type-cons+)
    (%set-datum $apply-result $builtin-arg2)
    (jump-imm :p-apply-end)

    :builtin-set-cdr! ; (%set-cdr! cell val) => val
    (%set-type-imm $builtin-arg1 +type-cons+)
    (%set-type-imm $builtin-arg2 +type-t+)
    (call :fetch-args)
    (%store-typed $builtin-arg2 $builtin-arg1 0 +type-snoc+)
    (%set-datum $apply-result $builtin-arg2)
    (jump-imm :p-apply-end)

    :builtin-function-data
    (%set-type-imm $builtin-arg1 +type-function+)
    (call :fetch-args)
    (%load $apply-result $builtin-arg1 0)
    (jump-imm :p-apply-end)

    :builtin-builtin-name
    (%set-type-imm $builtin-arg1 +type-builtin+)
    (call :fetch-args)
    (%load $apply-result $builtin-arg1 0)
    (jump-imm :p-apply-end)


    :p-apply-end
    (pop-eframe)
    (%set-datum (e-result) $apply-result)
    (jump-imm :main-loop-end)


    ;; subroutine for getting the arguments to a builtin function
    :fetch-args
    (%set-datum $fetch-args-arglist (e-result))

    (%set-datum-imm $fetch-args-arg-reg $builtin-arg1)
    (%set-datum-imm $fetch-args-argval-reg $builtin-arg1-val)
    :fetch-args-loop

    (%cmp-type-imm (indirect-register $fetch-args-arg-reg) +type-none+)
    (branchimm :fetch-args-end)
    (%car $fetch-args-arg $fetch-args-arglist :err-too-few-args)
    (%load $fetch-args-argval $fetch-args-arg 0)
    (%when-not (%cmp-type-imm (indirect-register $fetch-args-arg-reg) +type-t+)
      (%when-not (%cmp-type (indirect-register $fetch-args-arg-reg) $fetch-args-argval)
	(%error-imm %err-type-error)))
    (%cpy (indirect-register $fetch-args-arg-reg) $fetch-args-arg)
    (%cpy (indirect-register $fetch-args-argval-reg) $fetch-args-argval)
    (%cdr $fetch-args-arglist $fetch-args-arglist :err-too-few-args)

    (%cmp-datum-imm $fetch-args-arg-reg $builtin-arg3)
    (branchimm :fetch-args-end)
    (%add $fetch-args-arg-reg $one)
    (%add $fetch-args-argval-reg $one)
    (jump-imm :fetch-args-loop)

    :fetch-args-end
    (%cmp-datum-imm $fetch-args-arglist %nil)
    (branchimm-false :err-too-many-args)
    (ret)



    :p-apply-function1
    (%set-datum-imm (e-phase) %phase-apply-function)
    (%cdr $tmp1 $apply-func :err-invalid-function) ; $tmp1: (param-list expr env)
    (%car $tmp1 $tmp1 :err-invalid-function)       ; $tmp1: param list
    (%set-datum $tmp2 (e-result))                   ; $tmp2: arg list
    (push-eframe)
    (%set-datum-imm (e-expr) %nil)
    (%set-datum (e-arg) $tmp1)
    (%set-datum (e-result) $tmp2)
    (%set-datum-imm (e-phase) %phase-bind-args)
    (jump-imm :main-loop-end)

    ;; PHASE: APPLY-FUNCTION

    :p-apply-function2
    ;; (e-arg): function (address)
    ;; (e-result): list of argument bindings (address)
    (%load-typed $apply-func (e-arg) 0 +type-function+ :err-not-a-function)
    (%cdr $cdr  $apply-func :err-invalid-function) ; $cdr: (param-list expr env)
    (%cdr $cdr  $cdr        :err-invalid-function) ; $cdr: (expr env)
    (%car $tmp1 $cdr        :err-invalid-function) ; $tmp1: expr
    (%cdr $cdr  $cdr        :err-invalid-function) ; $cdr: (env)
    (%car $tmp2 $cdr        :err-invalid-function) ; $tmp2: env
    (%cons $tmp2 (e-result) $tmp2)                  ; $tmp2: new env
    (%set-datum $tmp3 (e-arg))                      ; $tmp3: function (address)
    (call :push-or-reuse-fframe)
    (%set-datum $f-func $tmp3)
    (%set-datum $f-env $tmp2)
    (%set-datum (e-expr) $tmp1)
    (%set-datum-imm (e-phase) %phase-eval)
    (jump-imm :main-loop-end)


    ;; PHASE: SET!

    :p-set!
    ;; (e-arg): new value
    ;; (e-result): existing binding (or nil if variable is unbound)
    (%cmp-datum-imm (e-result) %nil)
    (branchimm :err-unbound-symbol)
    (%car $tmp1 (e-result) :err-invalid-state) ; check that (e-result) is a cons cell
    (%store-typed (e-arg) (e-result) 1 +type-snoc+) ; (set-cdr! (e-result) (e-arg))
    (%set-datum $tmp1 (e-arg))
    (pop-eframe)
    (%set-datum (e-result) $tmp1)
    (jump-imm :main-loop-end)


    ;; PHASE: INITIAL

    :p-initial
    (%when (%cmp-datum-imm $s-parent %nil)
      (message-str "HALT")
      (%halt))
    (call :interrupt)
    ;; (jump-imm :main-loop-end) ; not necessary here


    ;; All paths inside the main loop lead to here
    :main-loop-end
    (%cmp-datum $gc-firstfree $gc-mem-limit)   ; lots of memory left?
    (%branch* $zero :main-loop-end-after-gc N) ; if so, skip GC
    ;; Not enough memory, invoke GC. First store the evaluation state:
    (call :store-sframe)
    (%set-type-imm $tmp1 +type-cons+)
    (%set-datum $tmp1 $s-addr)
    (%store $tmp1 $zero %memory-root)
    ;; Then call garbage collector:
    (call :gc-garbagecollect)
    (%cmp-datum $gc-firstfree $gc-mem-limit) ; lots of memory now?
    (%branch* $zero :out-of-memory (not N))  ; if not, give up completely
    (%load $s-addr $zero %memory-root)
    (call :load-sframe)
    :main-loop-end-after-gc
    (%cmp-datum-imm $s-iterations 0)
    (branchimm :main-loop)
    (%sub $s-iterations $one)
    (%cmp-datum-imm $s-iterations 0)
    (branchimm-false :main-loop)
    (%set-datum-imm $s-condition %timeout)
    (call :interrupt)
    (jump-imm :main-loop)


    :out-of-memory
    (message-str "ERROR: OUT OF MEMORY")
    (%halt)


    ;; ERROR HANDLERS:

    :err-not-a-list
    (%error-imm %err-not-a-list)

    :err-not-a-pair
    (%error-imm %err-not-a-pair)

    :err-not-a-function
    (%error-imm %err-not-a-function)

    :err-malformed-form
    (%error-imm %err-malformed-form)

    :err-invalid-function
    (%error-imm %err-invalid-function)

    :err-invalid-builtin
    (%error-imm %err-invalid-builtin)

    :err-invalid-env
    (%error-imm %err-invalid-env)

    :err-unbound-symbol
    (%error-imm %err-unbound-symbol)

    :err-invalid-param-list
    (%error-imm %err-invalid-param-list)
    :err-too-few-args
    (%error-imm %err-too-few-args)
    :err-too-many-args
    (%error-imm %err-too-many-args)

    :err-invalid-array-index
    (%error-imm %err-invalid-array-index)

    :err-invalid-phase
    (%error-imm %err-invalid-phase)

    :err-invalid-state
    (%error-imm %err-invalid-state)

    :err-io-error
    (%error-imm %err-io-error)

    :err-overflow
    (%error-imm %err-overflow)


    ;; SUBROUTINES:

    :make-empty-environment
    (%set-datum-imm $env %nil)
    (%cons $env $env $env)
    (ret)


    ;; Subroutine. Initializes a new evaluation level (that is, a new
    ;; state). Puts an initial e-frame at the bottom of the e/f
    ;; buffer, pushes an e-frame on top of it (it is the caller's
    ;; responsibility to initialize expr and phase in this new frame).
    :init-evaluation-level
    (%set-datum-imm $s-condition %nil)
    (%set-datum-imm $s-iterations 0)

    (%set-datum-imm $f-func %nil)
    (call :make-empty-environment)
    (%set-datum $f-env $env)
    (%set-datum-imm $f-addr %nil)

    (%set-datum-imm $e-expr $e/f-min-expr)
    (%set-datum-imm $e-arg $e/f-min-arg)
    (%set-datum-imm $e-result $e/f-min-result)
    (%set-datum-imm $e-phase $e/f-min-phase)

    (%set-type-imm (e-expr) +type-cons+)
    (%set-datum-imm (e-expr) %nil)
    (%set-datum-imm (e-arg) %nil)
    (%set-datum-imm (e-result) %nil)
    (%set-datum-imm (e-phase) %phase-initial)
    (%set-datum-imm $e-addr %nil)
    (push-eframe)
    (ret)


    ;; Subroutine. End the current evaluation level. Stores the whole
    ;; state to memory, returns it to the active e-frame in the
    ;; previous level (or halt the machine if we were at the
    ;; top-level).
    :interrupt
    (%cmp-datum-imm $s-parent %nil)
    (branchimm :interrupt-at-top-level)
    (call :store-sframe-without-parent)
    (%set-datum $interrupt-tmp $s-addr)
    (call :pop-s)
    (%set-datum (e-result) $interrupt-tmp)
    (ret)
    :interrupt-at-top-level
    (message-str "ERR:INTERRUPT")
    (%load $tmp1 $s-condition 1)
    (message-reg $tmp1)
    (message-reg $e-expr)
    (message-reg $e-arg)
    (message-reg $e-result)
    (message-reg $e-phase)
    (%halt)


    ;; STACK SUBROUTINES

    ;; Subroutine to take care of the cases in pushing e-frames when the
    ;; new place isn't immediately available. This might be either because
    ;; it is above the top of the buffer (in which case we should wrap
    ;; around) or because it is occupied (in which case we should store
    ;; the frame which is there to main memory).
    :push-eframe-handle-overflow
    (%cmp-datum-imm $e-expr $e/f-above-marker)
    (branchimm-false :push-eframe-handle-overflow-store)
    (%set-datum-imm $e-expr $e/f-min-expr)
    (%set-datum-imm $e-arg $e/f-min-arg)
    (%set-datum-imm $e-result $e/f-min-result)
    (%set-datum-imm $e-phase $e/f-min-phase)
    (%cmp-type-imm (e-expr) +type-none+)
    (branchimm :push-eframe-handle-overflow-end)
    :push-eframe-handle-overflow-store
    ;; buffer is full
    (%cmp-type-imm (e-expr) +type-function+)
    (branchimm-false :push-eframe-handle-overflow-store-e)
    (call :store-fframe)		; sets $f-addr
    (jump-imm :push-eframe-handle-overflow-end)
    :push-eframe-handle-overflow-store-e
    (call :store-eframe)		; sets $e-addr
    :push-eframe-handle-overflow-end
    (%set-datum-imm (e-expr) +type-cons+)
    (ret)


    :pop-eframe-handle-underflow
    (%cmp-datum-imm $e-expr $e/f-below-marker)
    (branchimm-false :pop-eframe-handle-underflow-load)
    (%set-datum-imm $e-expr $e/f-max-expr)
    (%set-datum-imm $e-arg $e/f-max-arg)
    (%set-datum-imm $e-result $e/f-max-result)
    (%set-datum-imm $e-phase $e/f-max-phase)
    (%cmp-type-imm (e-expr) +type-none+)
    (branchimm-false :pop-eframe-handle-underflow-end)
    :pop-eframe-handle-underflow-load
    ;; buffer is empty
    (%cmp-datum-imm $e-addr %nil)
    (branchimm-false :pop-eframe-handle-underflow-load-e)
    (jump-imm :load-fframe) ; tail call
;;     (call :load-f-and-e-frame-to-empty-buffer) ; sets $e-addr, $f-addr
;;     (ret)
    :pop-eframe-handle-underflow-load-e
    (call :load-eframe)
    :pop-eframe-handle-underflow-end
    (ret)




    :store-eframe
    (%set-type-imm (indirect-register $e-expr) +type-cons+)
    (%set-type-imm (indirect-register $e-arg) +type-cons+)
    (%set-type-imm (indirect-register $e-result) +type-cons+)
    (%set-type-imm (indirect-register $e-phase) +type-cons+)
    (%set-type-imm $e-addr +type-cons+)
    (alloc-imm 10)
    (%set-type-imm $e-tmp1 +type-snoc+)
    (%set-datum $e-tmp1 $alloc-addr)
    (%set-type-imm $e-tmp2 +type-int+)
    (%set-datum-imm $e-tmp2 2)
    (%set-type-imm $e-tmp3 +type-int+)
    (%set-datum $e-tmp3 $e-tmp1)
    (%store $e-addr $e-tmp1 0)
    (%store $list-terminator $e-tmp1 1)
    (%store (indirect-register $e-phase) $e-tmp1 2)
    (%store $e-tmp1 $e-tmp1 3)
    (%add $e-tmp3 $e-tmp2)
    (%set-datum $e-tmp1 $e-tmp3)
    (%store (indirect-register $e-result) $e-tmp1 2)
    (%store $e-tmp1 $e-tmp1 3)
    (%add $e-tmp3 $e-tmp2)
    (%set-datum $e-tmp1 $e-tmp3)
    (%store (indirect-register $e-arg) $e-tmp1 2)
    (%store $e-tmp1 $e-tmp1 3)
    (%add $e-tmp3 $e-tmp2)
    (%set-datum $e-tmp1 $e-tmp3)
    (%store (indirect-register $e-expr) $e-tmp1 2)
    (%store $e-tmp1 $e-tmp1 3)
    (%add $e-tmp3 $e-tmp2)
    (%set-datum $e-addr $e-tmp3)
    (ret)

    :load-eframe
    (%car (indirect-register $e-expr) $e-addr :load-eframe-error)
    (%cdr $e-tmp1 $e-addr :load-eframe-error)
    (%car (indirect-register $e-arg) $e-tmp1 :load-eframe-error)
    (%cdr $e-tmp1 $e-tmp1 :load-eframe-error)
    (%car (indirect-register $e-result) $e-tmp1 :load-eframe-error)
    (%cdr $e-tmp1 $e-tmp1 :load-eframe-error)
    (%car (indirect-register $e-phase) $e-tmp1 :load-eframe-error)
    (%cdr $e-tmp1 $e-tmp1 :load-eframe-error)
    (%car $e-addr $e-tmp1 :load-eframe-error)
    (ret)
    :load-eframe-error
    (message-str "ERR:L-E")
    (%halt)



    ;; Subroutine. Makes sure there is a function frame with a single
    ;; evaluation frame at the top of the stack. These might be the
    ;; frames currently at the top (if the current e-frame has no
    ;; parent, in which case it is safe to tail-call optimize) or new
    ;; frames. If a new f-frame is pushed, the current e-frame is
    ;; popped first.
    :push-or-reuse-fframe
    (%sub* $f-tmp1 $e-expr $e/f-frame-size)
    (%when (%cmp-datum-imm $f-tmp1 $e/f-below-marker)
      (%set-datum-imm $f-tmp1 $e/f-max-expr))
    ;; is frame below current a func frame?
    (%cmp-type-imm (indirect-register $f-tmp1) +type-function+)
    ;; if it is, eframe has no parent, so we can reuse fframe:
    (branchimm :push-or-reuse-fframe-can-reuse)
    ;; is frame below current empty?
    (%cmp-type-imm (indirect-register $f-tmp1) +type-none+)
    ;; if not, eframe has parent in e/f buffer, so we cannot reuse fframe:
    (branchimm-false :push-or-reuse-fframe-cannot-reuse)
    ;; if we got here, $e-addr is the address of this e-frame's
    ;; parent. check if it is NIL:
    (%cmp-datum-imm $e-addr %nil)
    ;; if not, eframe has parent in memory, so cannot reuse fframe:
    (branchimm-false :push-or-reuse-fframe-cannot-reuse)
    :push-or-reuse-fframe-can-reuse
    ;; if we get to here, the eframe has no parent, so we can reuse fframe:
    (%set-datum-imm (indirect-register $e-arg) %nil)
    (%set-datum-imm (indirect-register $e-result) %nil) ; caller must set $e-expr, $e-phase
    (ret)
    :push-or-reuse-fframe-cannot-reuse
    (pop-eframe)
    (call :push-fframe)
    (push-eframe)
    (ret)


    ;; Subroutine. Pushes the current f-frame onto the e/f buffer.
    :push-fframe
    ;; get a nice empty place in the e/f buffer:
    (push-eframe)
    ;; put our current fframe there:
    (%set-datum (indirect-register $e-expr) $f-func)
    (%set-datum (indirect-register $e-arg) $f-env)
    ;; mark this as being an fframe by setting the type of the first
    ;; register:
    (%set-type-imm (indirect-register $e-expr) +type-function+)
    (ret)



    ;; Subroutine. Stores the current frame in e/f buffer as an
    ;; f-frame. Sets $f-addr to the address it was stored to, $e-addr to
    ;; %nil (to indicate that the e-frame directly above this in the
    ;; buffer has no parent).
    :store-fframe
    (%set-type-imm (indirect-register $e-expr) +type-cons+)
    (%set-type-imm (indirect-register $e-arg) +type-cons+)
    (%set-type-imm $f-addr +type-cons+)
    (alloc-imm 8)
    (%set-type-imm $f-tmp1 +type-snoc+)
    (%set-datum $f-tmp1 $alloc-addr)
    (%set-type-imm $f-tmp2 +type-int+)
    (%set-datum-imm $f-tmp2 2)
    (%set-type-imm $f-tmp3 +type-int+)
    (%set-datum $f-tmp3 $f-tmp1)
    (%store $f-addr $f-tmp1 0)
    (%store $list-terminator $f-tmp1 1)
    (%store $e-addr $f-tmp1 2)
    (%store $f-tmp1 $f-tmp1 3)
    (%add $f-tmp3 $f-tmp2)
    (%set-datum $f-tmp1 $f-tmp3)
    (%store (indirect-register $e-arg) $f-tmp1 2)
    (%store $f-tmp1 $f-tmp1 3)
    (%add $f-tmp3 $f-tmp2)
    (%set-datum $f-tmp1 $f-tmp3)
    (%store (indirect-register $e-expr) $f-tmp1 2)
    (%store $f-tmp1 $f-tmp1 3)
    (%add $f-tmp3 $f-tmp2)
    (%set-datum $f-addr $f-tmp3)
    (%set-datum-imm $e-addr %nil)
    (ret)

    ;; Subroutine. Loads an f-frame into the e/f buffer. The f-frame is
    ;; found at the memory address in $f-addr; this register is changed to
    ;; be the address of this frame's parent. Sets $e-addr to the address
    ;; of the top e-frame in this f-frame.
    :load-fframe
    (%car $f-tmp1 $f-addr :load-fframe-error)
    (%set-datum (e-expr) $f-tmp1)
    (%set-type-imm (e-expr) +type-function+)
    (%cdr $f-tmp1 $f-addr :load-fframe-error)
    (%car (e-arg) $f-tmp1 :load-fframe-error)
    (%cdr $f-tmp1 $f-tmp1 :load-fframe-error)
    (%car $e-addr $f-tmp1 :load-fframe-error)
    (%cdr $f-tmp1 $f-tmp1 :load-fframe-error)
    (%car $f-addr $f-tmp1 :load-fframe-error)
    (ret)
    ;;(jump-imm :load-eframe)			; tail call
    :load-fframe-error
    (message-str "ERR:L-F")
    (%halt)


    :load-f-and-e-frame-to-empty-buffer
    (call :load-fframe)
    (%set-datum $f-func (e-expr))
    (%set-datum $f-env (e-arg))
    (%set-type-imm (e-expr) +type-none+)
    (jump-imm :load-eframe)		; tail call



    :store-e/f-stack
    (call :push-fframe)		  ; put current fframe into e/f buffer
    (%set-datum $e/f-top $e-expr)	; remember current position
    ;; Traverse the whole buffer, pushing dummy frames. This has the
    ;; effect that all frames in the buffer will be stored to main memory.
    :store-e/f-stack-loop
    (push-eframe)
    (%set-type-imm (indirect-register $e-expr) +type-none+)
    (%cmp-datum $e-expr $e/f-top)
    (branchimm-false :store-e/f-stack-loop)
    (ret)


    :push-s
    (call :store-sframe)
    (%set-datum $s-parent $s-addr)
    (ret)


    :store-sframe
    (%cons $s-tmp $s-parent $list-terminator)
    :store-sframe-without-parent-1
    (%make-obj $s-iterations $s-iterations +type-int+)
    (%cons $s-tmp $s-iterations $s-tmp)
    (%cons $s-tmp $s-condition $s-tmp)
    (call :store-e/f-stack) ; stores the whole e/f buffer, we get address
					; of top f-frame in $f-addr
    (%cons $s-tmp $f-addr $s-tmp)
    (%set-datum $s-addr $s-tmp)
    (ret)
    :store-sframe-without-parent
    (%set-datum-imm $s-tmp %nil)
    (jump-imm :store-sframe-without-parent-1)



    :pop-s
    (%set-datum $s-addr $s-parent)
    :load-sframe
    (call :load-sframe-common)
    (%cdr $s-tmp $s-tmp :load-sframe-error)
    (%car $s-parent $s-tmp :load-sframe-error)
    (jump-imm :load-f-and-e-frame-to-empty-buffer) ; tail call
    :load-sframe-error
    ;;(%error %err-invalid-state)
    (message-str "ERR:L-S")
    (%halt)



    :load-sframe-without-parent
    (call :load-sframe-common)
    (jump-imm :load-f-and-e-frame-to-empty-buffer) ; tail call
    :load-sframe-without-parent-error
    (%halt)

    :load-sframe-common
    (%car $f-addr $s-addr :load-sframe-error)
    (%cdr $s-tmp $s-addr :load-sframe-error)
    (%car $s-condition $s-tmp :load-sframe-error)
    (%cdr $s-tmp $s-tmp :load-sframe-error)
    (%car $s-iterations $s-tmp :load-sframe-error)
    (%load $s-iterations $s-iterations 0)
    (ret)



    ;; OUTPUT

    ;; Subroutine, print int from $message
    :message-reg
    (select-device-imm +dev-serial+)
    (%set-datum-imm $message-shift 24)
    (%set-datum-imm $message-mask #xF)
    :message-reg-loop
    (%set-datum $message-tmp1 $message)
    (%shift-r $message-tmp1 $message-shift)
    (%and $message-tmp1 $message-mask)
    (%set-datum-imm $message-tmp2 (char-int #\0))
    (%cmp-datum-imm $message-tmp1 #xA)
    (%branch* $zero :message-reg-below-a N)
    (%set-datum-imm $message-tmp2 (- (char-int #\A) #xA))
    :message-reg-below-a
    (%add $message-tmp1 $message-tmp2)
    (%store $message-tmp1 $io-mem-addr %io-object)
    (%cmp-datum-imm $message-shift 0)
    (branchimm :message-reg-loop-end)
    (%set-datum-imm $message-tmp1 4)
    (%sub $message-shift $message-tmp1)
    (jump-imm :message-reg-loop)
    :message-reg-loop-end
    (ret)




    ;; GARBAGE COLLECTOR


    ;; Garbage collection subroutine
    :gc-garbagecollect
    (message-str-no-nl ":")

    ;; mark everything as free
    (%cpy $gc-vi $gc-startofmem)

    :gc-loop1
    ;; load the contents of memory address (contained in gc-vi)
    ;; into register gc-1)
    ;; loop tested in emu: OK
    (%load $gc-1 $gc-vi 0)
    ;; if gc-flag already free, stop
    (%cmp-gc-imm $gc-1 +gc-free+)
    (branchimm :gc-nodeletegc)
    (%set-gc-imm $gc-1 +gc-free+)
    (%store $gc-1 $gc-vi 0)
    :gc-nodeletegc
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
    (%cmp-type-imm $gc-y +type-function+)
    (branchimm :gc-setfollowp)
    (%cmp-type-imm $gc-y +type-symbol+)
    (branchimm :gc-setfollowp)
    (%cmp-type-imm $gc-y +type-builtin+)
    (branchimm :gc-setfollowp)
    ;; if any other types contain pointers, add them here!
    (jump-imm :gc-afterfollowp)

    :gc-setfollowp

    ;; don't follow pointer if it's a low address
;    (%cmp-datum $gc-y $gc-startofmem)
;    (%branch* $zero :gc-afterfollowp (not N))

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


    (message-str-no-nl ",")

    ;; end of pointer reversal routine, from this point on,
    ;; all variables marked with "ptr-rev" are free for other use

    ;; pre-fill low memory values into translation area
    (%cpy $gc-from $zero)
    (%cpy $gc-to $gc-gcspace)
    :gc-prefill
    (%store $gc-from $gc-to 0)
    (%add $gc-from $one)
    (%add $gc-to $one)
    (%cmp-datum $gc-from $gc-startofmem)
    (branchimm-false :gc-prefill)

    ;; copy the stuff

    (%cpy $gc-to $gc-from)
    (%cpy $gc-baseaddr $zero)
    :gc-copyloop

    (%load $gc-mem $gc-from 0) ;; read from gc-from into gc-mem
    (%cmp-gc-imm $gc-mem +gc-used+)
    (branchimm-false :gc-notrans)
    ;; put address in translation table
    (%cpy $gc-temp $gc-from)
    (%sub $gc-temp $gc-baseaddr)
;    (%div* $gc-mem $gc-from $gc-spacesize)
;    (%mul $gc-mem $gc-spacesize)
;    (%cpy $gc-temp2 $gc-from)
;    (%sub $gc-temp2 $gc-mem)
    (%add $gc-temp $gc-gcspace)
    (%store $gc-to $gc-temp 0) ;; write to-address to gc-temp
    ;; copy
;;    (%load $gc-mem $gc-from 0)
    (%store $gc-mem $gc-to 0)
    (%add $gc-to $one)
    :gc-notrans
    (%add $gc-from $one)

    (%cpy $gc-temp $gc-baseaddr)
    (%add $gc-temp $gc-spacesize)
    

;    (%div* $gc-temp $gc-from $gc-spacesize)
;    (%mul $gc-temp $gc-spacesize)
;    (%sub* $gc-temp2 $gc-from $gc-temp)
    (%cmp-datum $gc-from $gc-temp)
    (branchimm-false :gc-noconvert)

    ;; translate pointers
    :gc-transloop
    (%cpy $gc-vi $gc-startofmem)

    (message-str-no-nl ".")

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
    (%cmp-type-imm $gc-mem +type-symbol+)
    (branchimm :gc-isptr)
    (%cmp-type-imm $gc-mem +type-function+)
    (branchimm :gc-isptr)
    (%cmp-type-imm $gc-mem +type-builtin+)
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

    ;; calculate gcspace+val%spacesize, put in val
    (%cpy $gc-val $gc-mem)
    (%sub $gc-val $gc-baseaddr)
    (%add $gc-val $gc-gcspace)

;    (%div* $gc-temp $gc-val $gc-spacesize)
;    (%mul $gc-temp $gc-spacesize)
;    (%sub* $gc-temp2 $gc-val $gc-temp)
;    (%add* $gc-val $gc-temp2 $gc-gcspace)
    (%load $gc-temp2 $gc-val 0)
    (%set-datum $gc-mem $gc-temp2)
    (%store $gc-mem $gc-vi 0)

    :gc-nexttrans
    (%add $gc-vi $one)
    (%cmp-datum $gc-vi $gc-to)
    (branchimm-false :gc-noto)
    (%cpy $gc-vi $gc-from)
    :gc-noto
    (%cmp-datum $gc-vi $gc-gcspace)
    (branchimm-false :gc-transloop2)

    ;; done with one block, increase base address
    (%add $gc-baseaddr $gc-spacesize)

    :gc-noconvert

    (%cmp-datum $gc-from $gc-gcspace)
    (branchimm-false :gc-copyloop)

    ;; whee, gc is finished and we have a new address where
    ;; free space starts
    (%cpy $gc-firstfree $gc-to)
    (message-str-no-nl ":")
    (ret)
    ;; End of garbage collection subroutine


    :call-error
    (message-str "ERR:CALL")
    (%halt)
    :ret-error
    (message-str "ERR:RET")
    (%halt)
    ))


(defun write-register-file ()
  (with-open-file (s
		   "/tmp/regfile"
		   :element-type 'character
		   :direction :output
		   :if-does-not-exist :create
		   :if-exists :supersede)
    (let ((symbols-start #x100))
      (format s "size ~X~%" +n-regs+)
      ;; initialize some general registers:
      (format s "addr 0~%")
      (format s "int 0~%")               ; $zero
      (format s "int 1~%")               ; $one
      (format s "int 2~%")               ; $two
      (format s "addr ~X~%" $list-terminator)
      (format s "snoc ~X~%" %nil)
      (format s "addr ~X~%" $mc-stack-top)
      (format s "int ~X~%" $mc-stack-min)
      (format s "addr ~X~%" $io-mem-addr)
      (format s "int 3FFFF00~%")
      (format s "addr ~X~%" $gc-maxblocks)
      (format s "int ~X~%" +memory-size+)
      (format s "addr ~X~%" $gc-spacesize)
      (format s "int ~X~%" (floor (/ +memory-size+ +gc-spaces+)))
      ;; write symbol strings in compressed form (three characters per
      ;; register):
      (format s "addr ~X~%" symbols-start)
      (loop for v in (compress-symbols (make-symbols))
	 do (format s "int ~X~%" v))
      ;; initialize registers used by initialization:
      (format s "addr ~X~%" $init1)
      (format s "nil~%")                  ; init1
      (format s "t~%")                    ; init2
      (format s "none~%")                 ; init3
      (format s "int ~X~%" symbols-start) ; init-counter
      (format s "int 0~%")                ; init-counter2
      (format s "int 10~%")               ; init-shift1
      (format s "int 8~%")                ; init-shift2
      (format s "int FF~%")               ; init-char-mask
      (format s "int ~X~%" %area-chars)   ; init-chars-start
      (format s "int 2~%")                ; init-symbol-addr
      (format s "int ~X~%" %area-strings) ; init-symbol-str-addr
      (format s "int ~X~%" %area-strings) ; init-symbol-char-addr
      (format s "array 0~%")              ; init-symbol-array
      )))

(defun make-symbols ()
  (let ((symbols "%IF
%QUOTE
%LAMBDA
%PROGN
%CONS
%CAR
%CDR
%EVAL
%APPLY
%TYPE
%MAKE-ARRAY
%ARRAY-SIZE
%ARRAY-GET
%ARRAY-SET
%MAKE-SYMBOL
%SYMBOL-TO-STRING
%CHAR-TO-INT
%INT-TO-CHAR
%GET-CHAR
%PUT-CHAR
%NUM-DEVICES
%DEVICE-TYPE
%SET-ADDRESS
%GET-ADDRESS
%ERROR
%ADD
%SUB
%MUL
%DIV
%BITWISE-AND
%BITWISE-OR
%BITWISE-NOT
%BITWISE-SHIFT
%CURRENT-ENVIRONMENT
%MAKE-EVAL-STATE
%EVAL-PARTIAL
%DEFINE
%UNDEFINE
%EQ?
%NUM-EQ?
%CHAR-EQ?
%LESS-THAN?
%MOD
%SET!
%SET-CAR!
%SET-CDR!
%FUNCTION-DATA
%BUILTIN-NAME
%DEVICE-SIZE
%DEVICE-STATUS











%SYMBOL-TABLE
%PHASE-EVAL
%PHASE-EVAL-ARGS
%PHASE-APPLY
%PHASE-EVAL-IF
%PHASE-INITIAL
%PHASE-ENV-LOOKUP
%PHASE-ENV-LOOKUP-LOCAL
%PHASE-APPLY-FUNCTION
%PHASE-BIND-ARGS
%PHASE-EVAL-PROGN
%PHASE-EVAL-ARGS-TOP
%PHASE-EVAL-ARGS-CDR
%PHASE-EVAL-ARGS-CONS
%PHASE-EVAL-SYMBOL
%PHASE-SET!

%TIMEOUT
%ERR-INVALID-PHASE
%ERR-UNBOUND-SYMBOL
%ERR-INVALID-PARAM-LIST
%ERR-TOO-FEW-ARGS
%ERR-TOO-MANY-ARGS
%ERR-INVALID-STATE
%ERR-INVALID-ARG-LIST
%ERR-TYPE-ERROR
%ERR-NOT-A-LIST
%ERR-NOT-A-FUNCTION
%ERR-INVALID-FUNCTION
%ERR-MALFORMED-FORM
%ERR-INVALID-BUILTIN
%ERR-INVALID-ARRAY-INDEX
%ERR-INVALID-ENV
%ERR-NOT-A-PAIR
%ERR-IO-ERROR
%ERR-DIVISION-BY-ZERO
%ERR-OVERFLOW
"))
    (loop for ch across symbols
	 collect (if (char= ch #\Newline)
		     0
		     (char-int ch)))))

(defun compress-symbols (char-list)
  (if char-list
      (let* ((c1 (car char-list))
	     (l1 (cdr char-list))
	     (c2 (if l1 (car l1) 0))
	     (l2 (if l1 (cdr l1) nil))
	     (c3 (if l2 (car l2) 0))
	     (l3 (if l2 (cdr l2) nil)))
	(cons (logior (ash c1 16)
		      (ash c2 8)
		      c3)
	      (compress-symbols l3)))
      nil))
