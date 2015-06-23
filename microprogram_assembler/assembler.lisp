;;;
;;; Assembler!
;;;

(in-package #:mcasm)

(defvar *assembler-constants* (make-hash-table :test 'equal))
(defvar *assembler-labelnumbers* 0)

(defun next-labelnumber ()
  (incf *assembler-labelnumbers*))

(defstruct constant-info
  type
  name
  number)

(defun constant-info-to-string (info &key (key nil))
  (format nil "~A~A~A~A"
	  (constant-info-type info)
	  (if key
	      "-"
	      " ")
	  (constant-info-name info)
	  (if key ""
	      (format nil " ~X" (constant-info-number info)))))

(defmacro def-const ((name number &key (type "const")) &body body)
  `(let ((info (make-constant-info :type ,type
				   :name ',name
				   :number ,number)))
     (setf (gethash (constant-info-to-string info :key nil) *assembler-constants*) info)
     ,@body))

(defmacro def-branch (name number)
  `(def-const (,name ,number :type "branch")
     (defparameter ,(intern (format nil "-BRANCH-~A-" name)) ,number)))

(def-branch O 1)
(def-branch C 2)
(def-branch N 4)
(def-branch Z 8)
(def-branch B 16)

(defmacro def-type (name number)
  `(def-const (,name ,number :type "type")
     (defparameter ,(intern (format nil "+TYPE-~A+" name)) ,number)))

(def-type none #x0)
(def-type int #x1)
(def-type float #x3)
(def-type cons #x4)
(def-type snoc #x5)
(def-type ptr #x6)
(def-type array #x7)
(def-type nil #x8)
(def-type t #x9)
(def-type char #xA)
(def-type symbol #xB)
(def-type function #xC)
(def-type builtin #xD)

(defparameter +n-regs+ #x400) ; number of registers

(defmacro defreg (name number)
  `(def-const (,name ,number :type "reg")
     (defparameter ,(intern (format nil "$~A" name)) ,number)))

(defmacro defmem (name number)
  `(def-const (,name ,number :type "memory")
     (defparameter ,(intern (format nil "%~A" name)) ,number)))

(defreg zero #x00)
(defreg one  #x01)
(defreg two  #x02)

(defreg s-addr #x03) ; address where an sframe has been stored
;;(defreg s-name #x04) ;; TODO do we want this?
;;(defreg s-fstack #x04)
(defreg s-condition #x04)
(defreg s-iterations #x05)
(defreg s-parent #x06)

;;(defreg e/f-addr #x07)
;;(defreg e/f-parent-addr #x08)

(defreg s-tmp  #x09)
(defreg e-tmp1 #x0A)
(defreg e-tmp2 #x0B)
(defreg e-tmp3 #x0C)
(defreg f-tmp1 #x0D)
(defreg f-tmp2 #x0E)
(defreg f-tmp3 #x0F)

;;(defreg e-addr #x09) ;; TODO remove this
(defreg e-expr #x10)
(defreg e-arg #x11)
(defreg e-result #x12)
(defreg e-phase #x13)
(defreg e-addr #x14)

;;(defreg f-addr #x15) ;; TODO remove this
(defreg f-func #x16)
(defreg f-env #x17)
;;(defreg f-estack #x18)
(defreg f-addr #x19)

(defreg alloc-addr #x20)
(defreg alloc-top #x21)
(defreg alloc-size #x22)

(defreg store-list-start #x23)
(defreg store-list-end #x24)
(defreg store-list-addr #x25)
(defreg store-list-reg #x26)
(defreg store-list-val #x27)

(defreg apply-result #x28)
(defreg apply-result-val #x29)
(defreg apply-func #x2A)
(defreg builtin-arg1 #x2B)
(defreg builtin-arg2 #x2C)
(defreg builtin-arg3 #x2D)
(defreg builtin-arg1-val #x2E)
(defreg builtin-arg2-val #x2F)
(defreg builtin-arg3-val #x30)

(defreg tmp-result #x33)

(defreg apply-argc #x34)
(defreg apply-required-argc #x35)

(defreg car #x40)
(defreg cdr #x41)
(defreg list-terminator #x42)

(defreg interrupt-tmp #x45)

(defreg params-car #x50)
(defreg args-car #x51)
(defreg apply-eval-expr #x52)
(defreg apply-eval-env #x53)
(defreg apply-apply-args #x54)
(defreg apply-apply-params #x55)
(defreg env #x56)

(defreg tmp1 #x57)
(defreg tmp2 #x58)
(defreg tmp3 #x59)
(defreg tmp4 #x5A)

(defreg fetch-args-arg-reg #x60)
(defreg fetch-args-arg #x61)
(defreg fetch-args-argval-reg #x62)
(defreg fetch-args-argval #x63)
(defreg fetch-args-arglist #x64)

(defreg io-devnr #x65)
(defreg io-new-devnr #x66)
(defreg io-mem-addr #x67)

(defreg message #x68)
(defreg message-shift #x69)
(defreg message-mask #x6A)
(defreg message-tmp1 #x6B)
(defreg message-tmp2 #x6C)

(defreg mc-stack-top #x090)
(defreg mc-stack-min #x091)
(defreg mc-stack-max #x09E)

(defreg e/f-top #x09F)
(defreg e/f-below-marker #x100)
(defreg e/f-min #x104)
(defreg e/f-min-expr #x104)
(defreg e/f-min-arg #x105)
(defreg e/f-min-result #x106)
(defreg e/f-min-phase #x107)

;; (defreg e/f-max-expr #x118)
;; (defreg e/f-max-arg #x119)
;; (defreg e/f-max-result #x11A)
;; (defreg e/f-max-phase #x11B)
;; (defreg e/f-max #x11B)
;; (defreg e/f-above-marker #x11C)

(defreg e/f-max-expr #x3F8)
(defreg e/f-max-arg #x3F9)
(defreg e/f-max-result #x3FA)
(defreg e/f-max-phase #x3FB)
(defreg e/f-max #x3FB)
(defreg e/f-above-marker #x3FC)
(defreg e/f-frame-size #x3FD)

(defreg init1                 #x3F0) 
(defreg init2                 #x3F1)
(defreg init3                 #x3F2)
(defreg init-counter          #x3F3)
(defreg init-counter2         #x3F4)
(defreg init-shift1           #x3F5)
(defreg init-shift2           #x3F6)
(defreg init-char-mask        #x3F7)
(defreg init-chars-start      #x3F8)
(defreg init-symbol-addr      #x3F9)
(defreg init-symbol-str-addr  #x3FA)
(defreg init-symbol-char-addr #x3FB)
(defreg init-symbol-array     #x3FC)

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
(defreg gc-baseaddr #x88)

(defreg gc-mem-limit #x7F)

;; div-variables (reusing gc-registers)
(defreg div-low #x88)
(defreg div-high #x89)
(defreg div-mid #x8a)
(defreg div-res #x8b)
(defreg div-sign #x8c)
(defreg mod-val1 #x87)
(defreg mod-val2 #x86)

(defparameter +gc-free+ #x00)
(defparameter +gc-used+ #x01)

(defparameter +gc-spaces+ #xA)

(defparameter +gc-limit+ #x1000) ; if free space is less than this, GC should be run


;; memory:

(defmem nil #x00)
(defmem t #x01)
(defmem if #x02)
(defmem quote #x03)
(defmem lambda #x04)
(defmem progn #x05)

(defparameter +first-builtin+ #x06)
(defmem cons #x06)
(defmem car #x07)
(defmem cdr #x08)
(defmem eval #x09)
(defmem apply #x0A)
(defmem type #x0B)
(defmem make-array #x0C)
(defmem array-size #x0D)
(defmem array-get #x0E)
(defmem array-set #x0F)
(defmem make-symbol #x10)
(defmem symbol-to-string #x11)
(defmem char-to-int #x12)
(defmem int-to-char #x13)
(defmem get-char #x14)
(defmem put-char #x15)
(defmem num-devices #x16)
(defmem device-type #x17)
(defmem set-address #x18)
(defmem get-address #x19)
(defmem error #x1A)
(defmem add #x1B)
(defmem sub #x1C)
(defmem mul #x1D)
(defmem div #x1E)
(defmem bitwise-and #x1F)
(defmem bitwise-or #x20)
(defmem bitwise-not #x21)
(defmem bitwise-shift #x22)
(defmem current-environment #x23)
(defmem make-eval-state #x24)
(defmem eval-partial #x25)
(defmem define #x26)
(defmem undefine #x27)
(defmem eq? #x28)
(defmem num-eq? #x29)
(defmem char-eq? #x2A)
(defmem less-than? #x2B)
(defmem mod #x2C)
(defmem set! #x2D)
(defmem set-car! #x2E)
(defmem set-cdr! #x2F)
(defmem function-data #x30)
(defmem builtin-name #x31)
(defmem device-size #x32)
(defmem device-status #x33)
(defparameter +last-builtin+ %device-status)
(defparameter +first-magic-var+ +first-builtin+)
(defparameter +last-magic-var+ +last-builtin+)

(defmem symbol-table #x3F)
(defparameter +first-phase+ #x40)
(defmem phase-eval #x40)
(defmem phase-eval-args #x41)
(defmem phase-apply #x42)
(defmem phase-eval-if #x43)
(defmem phase-initial #x44)
(defmem phase-env-lookup #x45)
(defmem phase-env-lookup-local #x46)
(defmem phase-apply-function #x47)
(defmem phase-bind-args #x48)
(defmem phase-eval-progn #x49)
(defmem phase-eval-args-top #x4A)
(defmem phase-eval-args-cdr #x4B)
(defmem phase-eval-args-cons #x4C)
(defmem phase-eval-symbol #x4D)
(defmem phase-set! #x4E)
(defparameter +last-phase+ %phase-set!)

(defmem timeout #x50)
(defmem err-invalid-phase #x51)
(defmem err-unbound-symbol #x52)
(defmem err-invalid-param-list #x53)
(defmem err-too-few-args #x54)
(defmem err-too-many-args #x55)
(defmem err-invalid-state #x56)
(defmem err-invalid-arg-list #x57)
(defmem err-type-error #x58)
(defmem err-not-a-list #x59)
(defmem err-not-a-function #x5A)
(defmem err-invalid-function #x5B)
(defmem err-malformed-form #x5C)
(defmem err-invalid-builtin #x5D)
(defmem err-invalid-array-index #x5E)
(defmem err-invalid-env #x5F)
(defmem err-not-a-pair #x60)
(defmem err-io-error #x61)
(defmem err-division-by-zero #x62)
(defmem err-overflow #x63)
(defparameter +last-symbol+ %err-overflow)

(defmem area-builtins #x100)
(defmem area-chars    #x200)
(defmem area-ints     #x280)
(defmem area-strings  #x300)
(defmem area-symlist  #xE00)

(defparameter +constant-chars+ (- %area-ints %area-chars))
(defparameter +constant-ints+ (- %area-strings %area-ints))

(defmem memory-root #xFFE)
(defmem mem-reserved-top #x1000)
(defmem boot-prog-start %mem-reserved-top)

(defparameter +memory-size+ (* 2 (* 1024 1024)))

(defmem io-mem-addr  #x3FFFF00) ; TODO too large for immediate value
(defmem io-devices        #x00)
(defmem io-curdev         #x01)
(defmem io-cli            #x02)
(defmem io-sai            #x03)
(defmem io-intrdev        #x04)
(defmem io-object         #x10)
(defmem io-addr-l         #x11)
(defmem io-addr-h         #x12)
(defmem io-size-l         #x13)
(defmem io-size-h         #x14)
(defmem io-status         #x15)
(defmem io-identification #x16)
(defmem io-irqenable      #x17)

(defparameter +dev-boot+ #x03)
(defparameter +dev-serial+ #x00)


;;; Helper functions

;; Convert a argument to the argument type
(defun argument-to-type (arg)
  (typecase arg
    (integer 'imm)
    (keyword 'label)
    (t 'other)))

;; Make the instruction
;; Only set the opcode
(defun make-inst-opcode (opcode &key (debug 0) (break 0))
  (let ((inst 0))
    (setf (ldb (byte 6 42) inst) opcode)
    (setf (ldb (byte 1 41) inst) debug)
    (setf (ldb (byte 1 40) inst) break)
    inst))

;; Parse an integer symbol and return the register number
(defun reg-to-num (reg)
  (typecase reg
    (symbol
     (parse-integer (subseq (format nil "~A" reg) 1)))
    (integer
     reg)))

(defmacro rewrite-inst-part (inst &key from size value)
  `(setf (ldb (byte ,size ,from) ,inst) ,value))
  
;; Make a function that returnes the binary representation of an instruction
(defmacro set-instruction ((&rest rest) &body body)
  (let ((opcodevar (gensym))
	(debugvar (gensym))
	(instvar (gensym))
	(breakvar (gensym)))
    `(lambda (,opcodevar ,@rest &key (,debugvar 0) (,breakvar 0))
       (let ((,instvar (make-inst-opcode ,opcodevar :debug ,debugvar :break ,breakvar)))
	 ,@(loop for part in body
	      collect (cons 'rewrite-inst-part (cons instvar part)))
	 ,instvar))))

;; The different opcode formats
(defparameter +opcodeformats+
  `(
    (noarg . (() ,(set-instruction ())))
    (mem . ((r r imm) ,(set-instruction (r1 r2 imm)
					(:size 11 :from 29 :value (reg-to-num r1))
					(:size 11 :from 18 :value (reg-to-num r2))
					(:size 18 :from 0 :value imm))))
    (data . ((r r) ,(set-instruction (r1 r2)
					 (:size 11 :from 29 :value (reg-to-num r1))
					 (:size 11 :from 18 :value (reg-to-num r2)))))
    (dataimm . ((r imm) ,(set-instruction (r1 imm)
					    (:size 11 :from 29 :value (reg-to-num r1))
					    ;(:size 11 :from 18 :value (reg-to-num r2))
					    (:size 29 :from 0 :value imm))))
    (onereg . ((r) ,(set-instruction (r1)
				     (:size 11 :from 29 :value (reg-to-num r1)))))
    (alu . ((r r) ,(set-instruction (r1 r2)
				      (:size 11 :from 29 :value (reg-to-num r1))
				      (:size 11 :from 18 :value (reg-to-num r2)))))
    (argtype0 . ((imm) ,(set-instruction (imm)
					 (:size 40 :from 0 :value imm))))
    (argtype1 . ((r imm) ,(set-instruction (r1 imm)
					   (:size 11 :from 29 :value (reg-to-num r1))
					   (:size 29 :from 0 :value imm))))
    (branch . ((r imm imm imm) ,(set-instruction (r1 mask flag addr)
						 (:size 11 :from 29 :value (reg-to-num r1))
						 (:size 8 :from 21 :value mask)
						 (:size 8 :from 13 :value flag)
						 (:size 13 :from 0 :value addr))))
    ))

;; Get the function from a format type
(defun get-format-function (format)
  (second (cdr (assoc format +opcodeformats+))))

;; Add an instruction to the list
(defun add-instruction (opcode args function)
  (setf *pre-assembly-data*
	(append
	 (list (list opcode args function))
	 *pre-assembly-data*)))

;; Define an instruction
;; The generated function returns a list that contains the opcode,
;; the arguments and the function that makes the bit representation.
(defmacro make-instruction (name format opcode)
  `(defun ,(intern (format nil "%~A" name)) (&rest args)
     (when (eq *assembler-state* :gather)
       (incf *assembler-position*))
     (let ((f (cdr (assoc ',format +opcodeformats+))))
       (when (not f)
	 (error "Missing opcode group for ~A for instruction ~A" ',format ',name))
       (add-instruction ,opcode args f))))

;; Write a 48bit binary value to a stream
(defun write-48bit-unsigned (value s)
  (write-byte (ldb (byte 8 40) value) s)
  (write-byte (ldb (byte 8 32) value) s)
  (write-byte (ldb (byte 8 24) value) s)
  (write-byte (ldb (byte 8 16) value) s)
  (write-byte (ldb (byte 8 8) value) s)
  (write-byte (ldb (byte 8 0) value) s))

;; Assemble our instructions
(defun assemble-it (pre-assembly stream &key output-format simulator-lines)
  (let ((pre-assembly (copy-tree (reverse pre-assembly))))
    ;; Assemble and write out
    (format t "Writing out assembly~%")
    (let ((instructions (loop for a in pre-assembly
			   unless (labelp a)
			   collect (apply (second (third a)) (first a) (second a)))))
      (let ((number-of-instructions (length instructions)))
	(dolist (inst instructions)
	  (cond ((eq output-format :human-readable)
		 (format stream "~12,'0X -- ~48,'0B~%" inst inst))
		((eq output-format :simulator)
		 (format stream "~48,'0B~%" inst))
		(t
		 (write-48bit-unsigned inst stream))))
	(when simulator-lines
	  (dotimes (i (- simulator-lines number-of-instructions))
	    (format stream "~48,'0B~%" 0)))))))

;; Empty assembler cache
(defun reset-assembler ()
  (setf *pre-assembly-data* (list)))

;;; Setup instructions and reset the assembler
(defun setup-assembler ()
  (make-instruction nop noarg #x00)
  (make-instruction halt noarg #x01)

  ;; ALU
  (make-instruction add alu #x02)
  (make-instruction sub alu #x03)
  (make-instruction mul alu #x04)
  (make-instruction div alu #x05)
  (make-instruction and alu #x06)
  (make-instruction or alu #x07)
  (make-instruction xor alu #x08)
  (make-instruction not alu #x09)
  (make-instruction shift-l alu #x0A)
  (make-instruction mod alu #x0B)
  (make-instruction shift-r alu #x0C)

  ;; Memory
  (make-instruction load mem #x10)
  (make-instruction store mem #x11)

  ;; Branch
  (make-instruction branch branch #x16)

  ;; Status
  (make-instruction set-flag argtype1 #x17)
  (make-instruction clear-flag argtype0 #x18)
  (make-instruction get-flag argtype1 #x19)

  ;; Data
  (make-instruction get-type data #x20)
  (make-instruction set-type data #x21)
  (make-instruction set-type-imm dataimm #x22)
  
  (make-instruction set-datum data #x23)
  (make-instruction set-datum-imm dataimm #x24)
  
  (make-instruction get-gc data #x25)
  (make-instruction set-gc data #x26)
  (make-instruction set-gc-imm dataimm #x27)

  (make-instruction cpy data #x28)

  ;; Compare
  (make-instruction cmp-type data #x29)
  (make-instruction cmp-type-imm dataimm #x2A)
  (make-instruction cmp-datum data #x2B)
  (make-instruction cmp-datum-imm dataimm #x2C)
  (make-instruction cmp-gc data #x2D)
  (make-instruction cmp-gc-imm dataimm #x2E)
  (make-instruction cmp data #x2F)

  ;; Leds
  (make-instruction set-leds onereg #x3F)
  
  (reset-assembler)
  
  t)

;; Info gathering or assembling state
;; The first get labels information and so on, the second assemble correct instructions
(defvar *assembler-state*)
(defvar *assembler-labels*)
(defvar *assembler-position*)

;; Debug functions

;; Write labels
(defun write-labels (file labels)
  (format t "Writing out label information~%")
  (with-open-file (s
		   (concatenate 'string file ".labels")
		   :element-type 'character
		   :direction :output
		   :if-does-not-exist :create
		   :if-exists :supersede)
    (maphash
     (lambda (key value)
       (format s "~A ~X~%" key value))
     labels)))

;; Write constant information
(defun write-constants (file constants labels)
  (format t "Writing constant information~%")
  (with-open-file (s
		   (concatenate 'string file ".const")
		   :element-type 'character
		   :direction :output
		   :if-does-not-exist :create
		   :if-exists :supersede)
    (maphash
     (lambda (key value)
       (format s "label ~A ~X~%" key value))
     labels)
    (maphash (lambda (key value)
	       (declare (ignore key))
	       (format s "~A~%" (constant-info-to-string value)))
	     constants)))

;; The main assembly macro
;; Adds inst-prefixes and fixes labels
(defmacro with-assembly ((outfile &key output-format simulator-lines) &body body)
  (let ((streamvar (gensym "STREAM")))
    `(let ((*assembler-labels* (make-hash-table))
	   (*assembler-state* :gather)
	   (*assembler-position* 0))
       (setf *assembler-labelnumbers* 0)
       ,@(loop
	    for inst in (copy-tree body)
	    when (not (labelp inst))
	    collect (rewrite-instruction inst :gather)
	    when (labelp inst)
	    collect `(setf (gethash ,inst *assembler-labels*) *assembler-position*))
       (setf *assembler-labelnumbers* 0)
       (format t "We got ~D instructions~%" *assembler-position*)
       (with-open-file (,streamvar ,outfile
				   :element-type ,(cond ((or (eq output-format :human-readable)
							     (eq output-format :simulator))
							 ''character)
							(t ''unsigned-byte))
				   :direction :output
				   :if-does-not-exist :create
				   :if-exists :supersede)
	 (setf *assembler-state* :assemble)
	 (reset-assembler)
	 ,@(loop
	      for inst in body
	      when (not (labelp inst))
	      collect (rewrite-instruction inst :assemble))
	 ;; Write out assembled exectuable
	 (assemble-it *pre-assembly-data* ,streamvar :output-format ,output-format :simulator-lines ,simulator-lines)
	 ;; Output debug info
	 (write-constants ,outfile *assembler-constants* *assembler-labels*)
	 (write-labels ,outfile *assembler-labels*)))))
  
;;; Microcode instructions

(defmacro with-new-label ((prefix var) &body body)
  `(let ((,var (intern (format nil "~A-~A" (string-upcase ,prefix) (next-labelnumber)) (find-package "KEYWORD"))))
     ,@body))

(defmacro force-label (label)
  `(when (labelp ,label)
     (if (eq *assembler-state* :gather)
	 (setf ,label 0)
	 (progn
	   (unless (gethash ,label *assembler-labels*)
	     (error "Unknown label: ~A" ,label))
	   (setf ,label (gethash ,label *assembler-labels*))))))

(defmacro with-force-label ((label) &body body)
  (if (integerp label)
      `(progn
	 ,@body)
      `(let ((,label ,label))
	 (force-label ,label)
	 ,@body)))

(defmacro with-force-label* ((var label) &body body)
  `(let ((,var ,label))
     (force-label ,var)
     ,@body))

(defmacro %when (comparison &body body)
  `(with-new-label ("when" end)
     ,comparison
     (branchimm-false end)
     ,@body
     (make-label end)))

(defmacro %when-not (comparison &body body)
  `(with-new-label ("when" end)
     ,comparison
     (branchimm end)
     ,@body
     (make-label end)))

(defmacro when= ((r1 r2) &body body)
  `(with-new-label ("when=" end)
     (%cmp-datum ,r1 ,r2)
     (branchimm-false end)
     ,@body
     (make-label end)))

(defmacro when!= ((r1 r2) &body body)
  `(with-new-label ("when=" end)
     (%cmp-datum ,r1 ,r2)
     (branchimm end)
     ,@body
     (make-label end)))

(defun some-stuff ()
  (make-integer 3 4)
  (make-integer 4 4)
  (when= (3 4)
    (make-integer 5 4)))

;; Make a indirect register
(defun indirect-register (reg)
  (let ((i reg))
    (setf (ldb (byte 1 10) i) 1)
    i))

;; Branch

(defmacro %branch* (reg offset &rest flags)
  (let ((maskvar (gensym))
	(flagvar (gensym)))
    `(let ((,maskvar (funcall #'logior ,@(loop for flag in flags
					    collect (intern (format nil "-BRANCH-~A-" (if (listp flag) (cadr flag) flag))))))
	   (,flagvar (funcall #'logior ,@(loop for flag in flags
					    when (not (listp flag))
					    collect (intern (format nil "-BRANCH-~A-" flag))))))
       (%branch ,reg ,maskvar ,flagvar ,offset))))

(defun branchimm* (mask flag addr)
  (with-force-label (addr) ;; Hack to fix labels in a few places, sorry about this.
    (%branch $zero mask flag addr)))

;; Immediate branch true
(defun branchimm (addr)
  (branchimm* #x8 #x8 addr))

;; Immediate branch false
(defun branchimm-false (addr)
  (branchimm* #x8 0 addr))

;; Jmp
(defun jump (r addr)
  (with-force-label (addr)
    (%branch r 0 0 addr)))

(defun jump-imm (addr)
  (with-force-label (addr)
    (jump $zero addr)))

(defun jump-reg (r)
  (jump r 0))

(defun make-object-imm (reg type value)
  (%set-type-imm reg type)
  (%set-datum-imm reg value))

(defun make-integer (reg value)
  (make-object-imm reg +type-int+ value))

(defun %add* (d a b)
  (%cpy d a)
  (%add d b))

(defun %sub* (d a b)
  (%cpy d a)
  (%sub d b))

(defun %mul* (d a b)
  (%cpy d a)
  (%mul d b))

(defun %div* (d a b)
  (%cpy d a)
  (%div d b))

(defun %mod* (d a b)
  (%cpy d a)
  (%mod d b))

(defun %and* (d a b)
  (%cpy d a)
  (%and d b))

(defun %or* (d a b)
  (%cpy d a)
  (%or d b))

(defun %incr (reg)
  (%add reg $one))

(defun %decr (reg)
  (%sub reg $one))

(defun labeltest ()
  (let ((label (gensym "IF-")))
    (make-integer 10 #x5)
    (make-label (intern (format nil "~A" label) (find-package "KEYWORD")))))

#|
;; Another simple test function
;; Suppose to be used to define the real API the assembler will have
(defun test-set2 ()
  (with-assembly ("/tmp/microcode" :output-format :simulator :simulator-lines 100)
    (make-integer 3 4)
    (make-integer 4 4)
    (when= (3 4)
      (make-integer 5 4))
    (when!= (3 4)
      (make-integer 6 4))))
|#
  
;; Make microcode instruction functions
(setup-assembler)
