;;;
;;; Sexp to memory file
;;;

(defpackage #:sexptomem
  (:use #:cl))

(in-package #:sexptomem)

(defvar *symbolinfo*)
(defvar *symbolinfopos*)
(defvar *datastartpos* #x1000)
(defvar *symbolstartpos* (+ *datastartpos* 2))

(defun listify (list)
  (if (listp list)
      list
      (list list)))

(defun handle-integer (x)
  (values nil
	  (format nil "int ~X" x)
	  1))

(defvar *character-start-position* #x200)
(defun char-position (char)
  (+ *character-start-position* (char-code char)))

(defun handle-string (str)
  (let ((len (length str)))
    (values
     nil
     (concatenate 'list
      (list (format nil "array ~X" len))
      (loop for ch across str
	 collect (format nil "ptr ~X" (char-position ch)))
      (list "snoc 0"))
     (+ 2 len))))

(defun handle-special-list (op cons)
  t)

(defun handle-cons (cons)
  (if (eq cons nil)
      (values t 0 0)
      (if (eq (type-of (car cons)) 'keyword)
	  (handle-special-list (car cons) (cdr cons))
	  (handle-list cons))))

(defun handle-list (cons)
  (if (not cons)
      (values t 0 0)
      (multiple-value-bind (carinplace cars carp)
	  (sexp-to-memory-fun (car cons))
	(multiple-value-bind (cdrinplace cdrs cdrp)
	    (handle-list (cdr cons))
	  (let ((list (concatenate 'list
				   (list
				    (if carinplace
					(format nil "cons ~X" cars)
					(format nil "cons +~X" 2)))
				   (list (if (not (cdr cons))
					     (format nil "snoc 0")
					     (if cdrinplace
						 (format nil "snoc ~X" cdrs)
						 (format nil "snoc +~X" (1+ (if carinplace 0 carp))))))
				   (listify (if carinplace () cars))
				   (listify (if cdrinplace () cdrs)))))
	    (values nil list
		    (+ 2 (if carinplace 0 carp) (if cdrinplace 0 cdrp))))))))

(defun handle-symbol (sym)
  (let ((res (assoc sym *symbolinfo*)))
    (if (not res)
	(progn
	  (setf *symbolinfo* (append *symbolinfo* (list (cons sym *symbolinfopos*))))
	  (incf *symbolinfopos*)
	  (handle-symbol sym))
	(values t (cdr res) 0))))

(defun handle-character (char)
;  (values nil (format nil "char ~X ~A" (char-code char) char) 1))
  (values t (char-position char) 0))

(defun sexp-to-memory-fun (body)
  (typecase body
    (list (handle-cons body))
    (string (handle-string body))
    (integer (handle-integer body))
    (symbol (handle-symbol body))
    (character (handle-character body))
    (t (error "Unknown type: ~A~%" (type-of body)))))

(defun rewrite-sexp-expr-list-to-cons (list)
  (if list
      `(%cons ,(rewrite-sexp-expr (car list))
	      ,(rewrite-sexp-expr-list-to-cons (cdr list)))
      '%nil))

(defun rewrite-sexp-expr-list (list)
  (cond ((eq (car list) '%%list)
	 (rewrite-sexp-expr-list-to-cons (cdr list)))
	((eq (car list) 'quote)
	 (cons '%quote (cdr list)))
	((eq (car list) 'let)
	 `((%lambda anonymous (,(caaadr list))
		    (%progn
		     ,@(mapcar #'rewrite-sexp-expr (cddr list))))
	   ,(rewrite-sexp-expr (cadr (caadr list)))))
	((eq (car list) 'defun)
	 (when (< (length list) 4)
	   (error "Malformed DEFUN ~A" list))
	 (let ((name (cadr list))
	       (params (caddr list))
	       (body (if (= (length list) 4)
			 (rewrite-sexp-expr (cadddr list))
			 `(%progn ,@(mapcar #'rewrite-sexp-expr
					    (cdddr list))))))
	   `(%define (%quote ,name)
		     (%lambda ,name ,params ,body))))
	((eq (car list) 'dolist)
	 (let ((elm (cadr list))
	       (in-list (rewrite-sexp-expr (caddr list)))
	       (body (rewrite-sexp-expr (cadddr list))))
	   `((%lambda
	      dolist
	      (_rec in-list)
	      (_rec in-list))
	     (%lambda dolist-rec (lst)
		      (if lst
			  ((%lambda inder-rec (,elm)
				    (%progn
				     ,body
				     (_rec (cdr lst)))))
			  nil))
	     ,in-list)))
	(t (mapcar #'rewrite-sexp-expr list))))

(defun rewrite-sexp-expr (body)
  (typecase body
    (list (rewrite-sexp-expr-list body))
    (t body)))

(defmacro sexp-to-memory* (&body body)
  `(sexp-to-memory
     ,(car body)

     ,@(loop for a in (cdr body)
	    collect (rewrite-sexp-expr a))))


(defmacro sexp-to-memory (&body body)
  (let ((sexpvar (gensym)))
    `(let* ((*symbolinfopos* 0)
	    (outlist ())
	    (symbols (loop for sym in ',(car body)
			for i from 0
			do (setf *symbolinfopos* i)
			collect (cons sym i))))
       (setf *symbolinfopos* *symbolstartpos*)
       (with-open-file (out
			"/tmp/initmem"
			:element-type 'character
			:direction :output
			:if-does-not-exist :create
			:if-exists :supersede)
	 (let ((pos 0)
	       (*symbolinfo* symbols))
	   (loop for ,sexpvar in ',(cdr body)
	      do (cond ((keywordp ,sexpvar)
			(let ((addr (parse-integer (format nil "~A" ,sexpvar) :radix 16)))
			  (setf outlist (append outlist (list (format nil "~%addr ~X~%" addr))))
			  (format t "Changing address from 0x~X to 0x~X~%" pos addr)
			  (setf pos addr)))
		       (t
			(multiple-value-bind (special list num)
			    (sexp-to-memory-fun ,sexpvar)
			  (declare (ignore special))
			  (incf pos num)
			  (setf outlist (append outlist (listify list)))))))


	   (let* ((newsymbols (nthcdr (length ',(car body)) *symbolinfo*)))
	     (let* ((sympos (+ *symbolstartpos* (length newsymbols)))
		    ;; Build symbols and symbol names
		    (symbols
		     (loop for (sym . pos) in newsymbols
			collect (multiple-value-bind (special b c)
				    (sexp-to-memory-fun (format nil "~A" sym))
				  (declare (ignore special))
				  (format t "Increasing sympos by: ~A for ~A~%" c sym)
				  (let ((sympos* sympos))
				    (incf sympos c)
				    (list b (format nil "symbol ~X ~A" sympos* sym))))))
		    (dataposition sympos)
		    (symboltable-start dataposition)
		    ;; Build symboltable
		    (symboltable (multiple-value-bind (special data len)
				     (sexp-to-memory-fun (mapcar #'car newsymbols))
				   (declare (ignore special))
				   ;; Link it up against the cpu symboltable
				   (setf (nth (1- (length data)) data) "snoc E00")
				   (incf dataposition (length data))
				   data))
		    (environment-position dataposition)
		    ;; Build our environment
		    (env (let ((env* (list "cons +2" "snoc 0"
					   "cons +2" "snoc 0"
					   (format nil "cons ~X" (multiple-value-bind (special data len)
								     (handle-symbol '%symbol-table)
								   (declare (ignore special len))
								   data))
					   (format nil "snoc ~X" symboltable-start))))
			   (incf dataposition (length env*))
			   env*)))

	       (let ((curpos *datastartpos*))
		 (flet ((printinc ()
			  ;(format out "# Add ~X~%" curpos)
			  (incf curpos)))

		   ;; Intial setup, start address. Pointer to expression and environment
		   (format out "addr ~X~%" *datastartpos*)
		   (format out "start ~X~%" *datastartpos*)
		   (printinc)
		   (format out "cons ~X~%" dataposition)
		   (printinc)
		   (format out "snoc ~X~%" environment-position)
		   ;; Symbols
		   (format out "# Symbols~%")
		   (dolist (sym (mapcar #'second symbols))
		     (printinc)
		     (format out "~A~%" sym))
		   ;; Symbol names
		   (format out "# Symbol names~%")
		   (dolist (name (mapcar #'first symbols))
		     (dolist (elem name)
		       (printinc)
		       (format out "~A~%" elem)))

		   ;; Symbol table
		   (format out "# Symboltable~%")
		   (dolist (elem symboltable)
		     (printinc)
		     (format out "~A~%" elem))
	       
		   ;; Environment
		   (format out "# Environment~%")
		   (dolist (elem env)
		     (printinc)
		     (format out "~A~%" elem))
	       
		   ;; Program
		   (format out "# Program~%")
		   (dolist (a outlist)
		     (printinc)
		     (format out "~A~%" a)))))))))))
    

#|
(sexp-to-memory
  (nil t if)
  (define read (lambda (str) #\b t)))
|#
