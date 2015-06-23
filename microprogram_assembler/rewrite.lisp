;;;
;;; with-assembly rewrite routines
;;;

(in-package #:mcasm)

;; Check if argument is a label
(defun labelp (a)
  (typep a 'keyword))

;; Add a label to the assembly data
(defun make-label (label)
  (when (eq *assembler-state* :gather)
    (setf (gethash label *assembler-labels*) *assembler-position*)))

; Do instruction rewrite
(defun rewrite-instruction-inst (inst state)
  (loop for arg in (cdr inst)
     for i from 1
     when (eq (argument-to-type arg) 'label)
     do (setf (nth i inst)
	      (if (eq state :gather)
		  0
		  `(if (gethash ,arg *assembler-labels*)
		       (gethash ,arg *assembler-labels*)
		       (error "Unknown label: ~A" ,arg)))))
  inst)

;; Rewrite an assembly instruction
;; :label => (make-label :label)
(defun rewrite-instruction (inst state)
  (typecase inst
    (list (rewrite-instruction-inst inst state))
    (keyword `(make-label ,inst))
    (t (error "Unknown instruction type: ~A" (type-of inst)))))
