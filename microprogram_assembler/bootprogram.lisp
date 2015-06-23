;;;
(in-package #:sexptomem)

(sexp-to-memory*
  (%nil
   %t
   %if
   %quote
   %lambda
   %progn
   %cons
   %car
   %cdr
   %eval
   %apply
   %type
   %make-array
   %array-size
   %array-get
   %array-set
   %make-symbol
   %symbol-to-string
   %char-to-int
   %int-to-char
   %get-char
   %put-char
   %num-devices
   %device-type
   %set-address
   %get-address
   %error
   %add
   %sub
   %mul
   %div
   %bitwise-and
   %bitwise-or
   %bitwise-not
   %bitwise-shift
   %current-environment
   %make-eval-state
   %eval-partial
   %define
   %undefine
   %eq?
   %num-eq?
   %char-eq?
   %less-than?
   %mod
   %set!
   %set-car!
   %set-cdr!
   %function-data
   %builtin-name
   %device-size
   %device-status

   xxxaa
   xxxab
   xxxac
   xxxad
   xxxae
   xxxaf
   xxxag
   xxxah
   xxxai
   xxxaj
   xxxak
  
   %symbol-table

   %phase-eval
   %phase-eval-args
   %phase-apply
   %phase-eval-if
   %phase-initial
   %phase-env-lookup
   %phase-env-lookup-local
   %phase-apply-function
   %phase-bind-args
   %phase-eval-progn
   %phase-eval-args-top
   %phase-eval-args-cdr
   %phase-eval-args-cons
   %phase-eval-symbol
   %phase-set!

   xxx3F

   %timeout
   %err-invalid-phase
   %err-unbound-symbol
   %err-invalid-param-list
   %err-too-few-args
   %err-too-many-args
   %err-invalid-state
   %err-invalid-arg-list
   %err-type-error
   %err-not-a-list
   %err-not-a-function
   %err-invalid-function
   %err-malformed-form
   %err-invalid-builtin
   %err-invalid-array-index
   %err-invalid-env
   %err-not-a-pair
   %err-division-by-zero
   %err-overflow
   )

  (%progn
   
   (%progn				; Define types
    (%define '+type-none+ #x0)
    (%define '+type-int+ #x1)
    (%define '+type-float+ #x3)
    (%define '+type-cons+ #x4)
    (%define '+type-snoc+ #x5)
    (%define '+type-ptr+ #x6)
    (%define '+type-array+ #x7)
    (%define '+type-nil+ #x8)
    (%define '+type-t+ #x9)
    (%define '+type-char+ #xA)
    (%define '+type-symbol+ #xB)
    (%define '+type-function+ #xC)
    (%define '+type-builtin+ #xD)
    )
  
   (%define 'current-input 2)
   (%define 'current-output 2)

   (%define '*print-base* 16)
  
   (%define '1+ (%lambda 1+ (x)
			 (%add 1 x)))
  
   (%define '1- (%lambda 1- (x) (%sub x 1)))

   (%define 'map (%lambda map (fn list)
			  (%if list
			       (%cons (fn (%car list))
				      (map fn (%cdr list)))
			       %nil)))
   
   (%define 'map-short (%lambda map-short (fn list)
				(%if list
				     (%cons (fn (%car list))
					    (map fn (%cdr list)))
				     %nil)))
   

   (%define 'list (%lambda list list list))
     
   (%define 'char-upper (%lambda char-upper (char)
				 (let ((n (%char-to-int char)))
				   (%if (%less-than? (1- (%char-to-int #\a)) n)
					(%if (%less-than? n (1+ (%char-to-int #\z)))
					     (%int-to-char (%sub n 32))
					     char)
					char))))
  
   (%define 'make-string-stream (%lambda make-string-stream (str pos)
					 (%lambda string-stream (cmd)
						  (%if (%eq? cmd 'get-char)
						       (%if (%less-than? (1- (%array-size str)) pos)
							    'eos
							    (%progn
							     (%set! 'pos (1+ pos))
							     (%array-get str (1- pos))))
						       (%if (%eq? cmd 'peek-char)
							    (%if (%less-than? (1- (%array-size str)) pos)
								 'eos
								 (%array-get str pos))
							    %nil)))))

   (%define 'make-device-input-stream (%lambda make-device-input-stream (device-number)
					       (let ((chpeek %nil))
						 (%lambda device-input-stream (cmd)
							  (%if (%eq? cmd 'get-char)
							       (let ((thech (%if chpeek
										 (let ((ch chpeek))
										   (%set! 'chpeek %nil)
										   ch)
										 (%get-char device-number))))
								 (%if (or2 (%num-eq? device-number 2) (%num-eq? device-number 0))
								      (%put-char current-output thech)
								      %nil)
								 thech)
							       (%if (%eq? cmd 'peek-char)
								    (%if chpeek
									 chpeek
									 (%set! 'chpeek (%get-char device-number)))
								    %nil))))))




  
   (%define
    'stream-wrapper-narwhal
    (%lambda stream-wrapper-narwhal (stream)
	     (let ((chpeek %nil))
	       (%lambda input-stream (cmd)
			(%if (%eq? cmd 'get-char)
			     (%if chpeek
				 (let ((chkeep chpeek))
				   (%set! 'chpeek %nil)
				   chkeep)
				 (stream 'get-char))
			     (%if (%eq? cmd 'peek-char)
				  (%if chpeek
				       chpeek
				       (%set! 'chpeek (stream 'get-char)))
				  (%error 'I-<3-YOU-STREAM-WRAPPER)))))))

   ;Code for reading the filesystem
   ;Filetable first, each entry has [in use, filename, start-block, length]
   ;Then comes one word per block, which is rather hilarious usage of space...
   ;... "meta-info" about blocks, we'll call it. suuure.
   ;Then comes the blocks. Each block is some size. A block has a pointer to
   ;the next block that follows it.
   
;The fileinfo (file identifier) passed around.
   (%define '+fileinfo-num-fields+ 6)
   (%define '+fileinfo-name+ 0)
   (%define '+fileinfo-tableindex+ 1)
   (%define '+fileinfo-block+ 2)
   (%define '+fileinfo-block-pos+ 3)
   (%define '+fileinfo-current-pos+ 4)
   (%define '+fileinfo-size+ 5)
  
;The metadata structure.
   (%define '+metadata-pos+ 0)
   (%define '+metadata-size+ 16)
   (%define '+metadata-num-blocks+ 0)
   (%define '+metadata-free-blocks+ 1)
   (%define '+metadata-blocksize+ 2)
   (%define '+metadata-block-pos+ 3)
   (%define '+metadata-ft-num-rows+ 4) ;number of filetable rows
   (%define '+metadata-ft-free-rows+ 5) ;number of free rows
   (%define '+metadata-ft-rowsize+ 6) ;size of a filetable row
   (%define '+metadata-ft-pos+ 7) ;position of filetable (absolute address)

;The filetable structure and various values
   (%define '+filetable-pos+ 16)
   (%define '+filetable-field-size+ 16)
   (%define '+filetable-num-rows+ 2)
   (%define '+filetable-size+ 32)
   (%define '+filetable-not-in-use-marker+ 0)
   (%define '+filetable-field-in-use+ 0)
   (%define '+filetable-field-filename+ 1)
   (%define '+filetable-field-start-block+ 14)
   (%define '+filetable-field-filesize+ 15)
   (%define '+filename-size+ 13)
   
;The blocktale structure
   (%define '+blocktable-pos+ 48)
   (%define '+blocktable-size+ 8)

;Various defines partaining to blocks
   (%define '+block-section-pos+ 56)
   (%define '+block-size+ 8)
   (%define '+num-blocks+ 8)


;The device used for storage
   (%define '+storage-dev+ 1)
  
   
    ;get the ith entry from the filetable, put it in an array
   (defun filetable-entry (index)
     (get-string
      (address-of-entry index)
      (metadata +metadata-ft-rowsize+)))
    
   (%define '+file-null-char+ 4)
  
   ;should've had array-append... 
   (defun count-non-null* (s pos num)
     (%if (%num-eq?
	   (%array-size s)
	   pos)
	  num
	  (%if (%num-eq? 
		+file-null-char+
		(%char-to-int (%array-get s pos)))
	       (count-non-null* s (1+ pos) num)
	       (count-non-null* s (1+ pos) (1+ num)))))     
   (defun count-non-null (s)
     (count-non-null* s 0 0))



   (defun strip-null (s)
     (array-resize s (count-non-null s)))




   (defun array-resize* (new arr size pos)
     (%if (%num-eq?
	   size
	   pos)
	  new
	  (%progn 
	   (%array-set new pos (%array-get arr pos))
	   (array-resize* new arr size (1+ pos)))))

   (defun array-resize (arr size)
     (let ((new (%make-array size %nil)))
       (array-resize* new arr size 0)))  




   
   
   (defun str-eq?* (f1 f2 pos)
     (%if 
      (%num-eq? (%array-size f1) pos)
      %t
      (%if (%char-eq? 
	    (%array-get f1 pos)
	    (%array-get f2 pos))
	   (str-eq?* f1 f2 (1+ pos))
	   %nil)))
  
  (defun str-eq? (f1 f2)
    (%if (%num-eq? (%array-size f1) (%array-size f2))
	 (str-eq?* f1 f2 0)
	 %nil))

   ;slice of a part of an array of chars [tested ok...]
   (%define
    'string-slice*
    (%lambda
     string-slice* (str slice stringpos pos len)
     (%if (%num-eq? pos len)
	  slice
	  (%progn
	   (%array-set slice pos (%array-get str stringpos))
	   (string-slice* str slice (1+ stringpos) (1+ pos) len)))))
	   
   (%define
    'string-slice
    (%lambda
     string-slice (str start len)
     (let ((slice (%make-array len %nil)))
       (string-slice* str slice start 0 len))))
  
  
   ;get the filename of an entry in the filetable
   (%define
    'filetable-entry-filename
    (%lambda filetable-entry-filename (filetable-entry)
	     (string-slice
	      filetable-entry
	      +filetable-field-filename+
	      +filename-size+)))
  
   (%define
    'filetable-entry-block
    (%lambda filetable-entry-block (filetable-entry)
	     (%char-to-int
	      (%array-get filetable-entry +filetable-field-start-block+))))

   (%define
    'filetable-entry-size
    (%lambda filetable-entry-size (filetable-entry)
	     (%char-to-int
	      (%array-get filetable-entry +filetable-field-filesize+))))

		
  
   (defun filetable-entry-in-use (entry)
     (%if (%num-eq?
	   (%char-to-int (%array-get entry +filetable-field-in-use+))
	   0)
	  %nil
	  %T))
					;Get the starting block of the file at index in filetable
   (%define
    'filetable-start-block
    (%lambda filetable-start-block (index) 
	     (%progn 
	      (%set-address +storage-dev+ 0)
	      (%char-to-int (%get-char (%add 
				       (%mul +filetable-field-size+ index) 
				       +filetable-field-start-block+))))))
  
					;Get the size of the file at index in the filetable
   (%define
    'filetable-filesize
    (%lambda filetable-filesize
	     (%set-address +storage-dev+ 0)
	     (%char-to-int (%get-char (%add
				       (%mul +filetable-field-size+ index)
				       +filetable-field-filesize+)))))

   ;put length chars from starting-position into an array of length size
   (defun get-string* (str len pos)
     (%if (%num-eq? pos len)
	  str
	  (%progn
	   (%array-set str pos (%get-char +storage-dev+))
	   (get-string* str len (1+ pos)))))


   (defun get-string (start-pos length)
     (let ((string (%make-array length %nil)))
       (%set-address +storage-dev+ start-pos)
       (get-string* string length 0)))
    

   (defun put-string* (src len pos)
     (%if (%num-eq? pos len)
	  src
	  (%progn
	   (%put-char +storage-dev+ (%array-get src pos))
	   (put-string* src len (1+ pos)))))

   (defun put-string (dst string)
     (%set-address +storage-dev+ dst)
     (put-string* string (%array-size string) 0))

    ;iterate file-table, find matching filename and return the fileinfo-entry, used by streams
   (defun open-file* (filename file-info index)
     (%if (%num-eq?
	   (metadata +metadata-ft-num-rows+)
	   index)
	  (display "No such file or filename. IGOR is not happy, making him work this much...")
	  
	  (let ((entry (filetable-entry index))) ;get ith entry in filetable
	    (%if (filetable-entry-in-use entry)
		 (let ((entry-filename (strip-null (filetable-entry-filename entry)))) ;store filename
		   (%if (str-eq? entry-filename filename) ;compare filenames, if equal:
			(%progn 
					;create a file-info structure
		    (%array-set file-info +fileinfo-name+ entry-filename)
		    (%array-set file-info +fileinfo-block+ (filetable-entry-block entry))
		    (%array-set file-info +fileinfo-size+ (filetable-entry-size entry))
		    file-info)
					;filename mismatch, next entry please
			(open-file* filename file-info (1+ index))))
		 (open-file* filename file-info (1+ index)))))) ;entry not in use, next.

   (defun open-file (filename)
     (let ((file-info (%make-array +fileinfo-num-fields+ 0)))
       (open-file* filename file-info 0)))


   
   
   (defun filetable-get-offset (filename index)
     (let ((current-filename (get-string 
			      (%add 
			       +filetable-field-fieldname+ (%mul 
							    index 
							    +filetable-field-size+))
			      +filename-size+)))))



   (defun file-address (file-info)
     (%add
      (address-of-block (%array-get file-info +fileinfo-block+))
      (%array-get file-info +fileinfo-block-pos+)))

   (%define
    'make-fisk-stream
    (%lambda make-fisk-stream (open-fisk-dings)
	     (stream-wrapper-narwhal
	      (%lambda fisk-stream (cmd)
		       (%if (%eq? cmd 'get-char)
			   (file-get-char open-fisk-dings))))))
   
   
   (%define
    'file-eof?
    (%lambda file-eof? (file-info)
	     (%if (%eq? 
		   (%array-get file-info +fileinfo-current-pos+)
		   (%array-get file-info +fileinfo-size+))
		  %t
		  %nil)))
   (%define 
    'file-get-char 
    (%lambda file-get-char (file-info)
	     (%if (file-eof? file-info)
		  (%error 'EOF)
		  (let ((ch (file-read-char file-info)))

		    (file-increment-pos file-info)
		    ch))))
   

   (%define
    'file-read-char
    (%lambda file-read-char (file-info)
	     (%progn 
	      (%set-address +storage-dev+ (file-address file-info))
	      (%get-char +storage-dev+))))
   
   (%define
    'file-increment-pos
    (%lambda file-increment-pos (file-info)
	     (%if (file-eof? file-info) ;if we're at the end of the file...
		  %nil ;...don't increment
		  (%progn 
		   (%array-set   ;else, increment the current-position by 1
		    file-info 
		    +fileinfo-current-pos+
		    (1+ (%array-get file-info +fileinfo-current-pos+)))
		   (%if (end-of-block file-info) ;if end of block...
			(%progn
			 (%array-set 
			  file-info 
			  +fileinfo-block+ 
			  (file-next-block 
			   (%array-get file-info +fileinfo-block+))) ;find the next block and set
			 (%array-set 
			  file-info 
			  +fileinfo-block-pos+ 
			  0)) ;and set the current inter-block-position to 0
			(%array-set  ;else, we're not at the end of the block.
			 file-info 
			 +fileinfo-block-pos+ 
			 (1+ (%array-get file-info +fileinfo-block-pos+)))))))) ; simply update current block

   
   (%define
    'end-of-block
    (%lambda end-of-block (file-info)
	     (%if (%num-eq? 
		   (%array-get file-info +fileinfo-block-pos+)
		   (%sub +block-size+ 2))
		  %t
		  %nil);not end of block
	     )) 


   (%define
    'file-next-block
    (%lambda file-next-block (current-block)
	     (%progn
	      (%set-address 
	       +storage-dev+ 
	       (%add 
		(address-of-block current-block)
		(1- +block-size+)))
	      (%char-to-int (%get-char +storage-dev+)))))

   (defun address-of-block (bloc)
     (%add 
      +block-section-pos+ 
      (%mul +block-size+ bloc)))


   (defun list-files* (index)
     (%if (%num-eq?
	   index
	   +filetable-num-rows+)
	  %T
	  (let ((entry (filetable-entry index)))
	    (%if (filetable-entry-in-use entry)
		 (%progn
		  (display (strip-null (filetable-entry-filename entry)))
		  (newline)
		  (list-files* (1+ index)))
		 (list-files* (1+ index))))))

   (defun list-files ()
     (list-files* 0))


   (defun metadata (num)
     (%set-address +storage-dev+ (%add +metadata-pos+ num))
     (%char-to-int (%get-char +storage-dev+)))
   
   ;Code for writing to the filesystem is below.
   (defun create-file (filename)
     (let ((entry (filetable-free-entry)))
       (let ((addr (address-of-entry entry)))
	 (put-char-at-addr addr (%int-to-char 1))
	 (put-string (%add
		      addr
		      +filetable-field-filename+)
		     filename)
	 (put-char-at-addr (%add
			    addr
			    +filetable-field-start-block+)
			   (%int-to-char (find-free-block)))
	 (put-char-at-addr (%add
			    addr
			    +filetable-field-filesize+)
			   (%int-to-char 0))))
     (open-file filename))
		     
   (defun put-char-at-addr (addr char)
     (%set-address +storage-dev+ addr)
     (%put-char +storage-dev+ char))
   
     
     (defun address-of-entry (entry)
       (%add
	(%mul
	 entry
	 (metadata +metadata-ft-rowsize+))
	(metadata +metadata-ft-pos+)))
	
   ;DOES: Attempts to find a free entry in the file table.
   ;THROWS: 'filetable-full
   (defun filetable-free-entry ()
     (%if (%num-eq? (metadata +metadata-ft-free-rows+) 0)
	  (%error 'filetable-meta-full)
	  (filetable-free-entry* 0)))
   (defun filetable-free-entry* (index)
     (%if
      (%num-eq?
       index
       (metadata +metadata-ft-num-rows+))
      (%error 'filetable-full)
      (%if  ;if this entry is not in use
       (%num-eq?
	(%char-to-int (%array-get (filetable-entry index) +filetable-field-in-use+))
	+filetable-not-in-use-marker+);...eh
       index ;return the index.
       (filetable-free-entry* (1+ index)))))

	  
	  
   (defun find-free-block* (index)
     (%if
      (%num-eq?
       (metadata +metadata-num-blocks+)
       index)
      %nil
      (%progn
       (%set-address +storage-dev+ (%add +blocktable-pos+ index))
       (%if
	(%num-eq?
	 (%char-to-int (%get-char +storage-dev+))
	 0)
	index
	(find-free-block* (1+ index))))))

   (defun find-free-block ()
     (%if
      (%num-eq?
       (metadata +metadata-free-blocks+)
       0)
      (%error 'no-free-blocks)
      (find-free-block* 0)))
     
  

   (defun set-block-unfree '()
     (display "cannot unfree what has been unseen"))
   (defun set-block-free '()
     (display "setting a block free!"))


   
   (defun write-filetable-entry (fileinfo)
     (let ((entry (filetable-find-free-entry)))))   

					  
   (%define 'string=-rec (%lambda string=-rec (i s1 s2)
				  (%if (%num-eq? i (%array-size s1))
				       %t
				       (%if (%char-eq? (%array-get s1 i)
						       (%array-get s2 i))
					    (string=-rec (1+ i) s1 s2)
					    %nil))))

   (%define 'string=? (%lambda string=? (s1 s2)
			       (%if (%num-eq? (%array-size s1) (%array-size s2))
				    (string=-rec 0 s1 s2)
				    %nil)))
     
   (%define 'symbol-exists?-rec (%lambda symbol-exists?-rec (symbol-table str)
					 (%if symbol-table
					      (%if (string=? (%symbol-to-string (%car symbol-table)) str)
						   (%car symbol-table)
						   (symbol-exists?-rec (%cdr symbol-table) str))
					      %nil)))
  
   ;; Check if a symbol is interned
   (%define 'symbol-exists? (%lambda symbol-exists? (str)
				     (symbol-exists?-rec %symbol-table str)))
    
   ;; Intern a symbol, if it is already intered, just return the symbol
   (%define 'intern (%lambda intern (str)
			     (let ((sym (symbol-exists? str)))
			       (%if sym sym
				    (let ((sym (%make-symbol str)))
				      (%set! '%symbol-table (%cons sym %symbol-table))
				      sym)))))

   (%define
    'intern-char-hash
    (%lambda
     intern-char-hash (ch)
     (%bitwise-and (%char-to-int ch) 7)))

   (%define
    'intern-make-node
    (%lambda
     intern-make-node ()
     (%cons nil (%make-array 8 nil))))

   (%define
    'intern-get-node
    (%lambda
     intern-get-node (tab hash)
     (%array-get
      (%if (%array-get tab hash)
	   tab
	   (%array-set tab hash (intern-make-node)))
      hash)))

   (%define
    'intern-get-sym-in-list
    (%lambda
     intern-get-sym-in-list (str list)
     (%if list
	  (%if (string=? (%symbol-to-string (%car list)) str)
	       (%car list)
	       (intern-get-sym-in-list str (%cdr list)))
	  nil)))

   (%define
    'intern-rec
    (%lambda
     intern-rec (str i tree existing-symbol)
     (%if (%num-eq? i (%array-size str))
	  (let ((sym (intern-get-sym-in-list str (%car tree))))
	    (%if sym sym
		 (%car (%set-car! tree (%cons (%if existing-symbol
						   existing-symbol
						   (%make-symbol str))
					      (%car tree))))))
	  (intern-rec
	   str
	   (%add i 1)
	   (intern-get-node (%cdr tree) (intern-char-hash (%array-get str i)))
	   existing-symbol))))

   (%define 'symbol-tree (intern-make-node))

   (%define
    'intern-foo
    (%lambda
     intern (str)
     (intern-rec str 0 symbol-tree nil)))

   (%define
    'intern-symbols
    (%lambda
     intern-symbols (list)
     (%if list
	  (%progn (intern-rec (%symbol-to-string (%car list)) 0 symbol-tree (%car list))
		  (intern-symbols (%cdr list)))
	  nil)))


   ;; See if an element member of a list
   (%define 'member (%lambda member (elem list test)
			     (%if list
				  (%if (test (%car list) elem)
				       %t
				       (member elem (%cdr list) test))
				  %nil)))

   ;; Or functions
   ;; XXX: Special form
   (%define 'or2 (%lambda or2 (a b)	; XXX: Special forms
			  (%if a a b)))
   (%define 'or3 (%lambda or3 (a b c)
			  (or2 a (or2 b c))))

   (%define 'digits (%%list #\0 #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9))
   (%define 'digits-hex (%cons #\a (%cons #\b (%cons #\c (%cons #\d (%cons #\e (%cons #\f
										      (%cons #\A (%cons #\B (%cons #\C (%cons #\D (%cons #\E (%cons #\F digits)))))))))))))

     
   ;; Special characters
   ;; These will never be in a symbol
   (%define 'special (%%list #\( #\) #\Space))

   ;; Convert a digit character to a digit
   (%define 'char-to-digit (%lambda char-to-digit (ch)
				    (%sub (%char-to-int ch) 48)))

   ;; Is the character something we want in our symbol?
   (%define 'isalpha? (%lambda isalpha? (ch)
			       (%if (member ch special %char-eq?)
				    %nil
				    (%if (member ch digits %char-eq?)
					 %nil
					 %t))))

   ;; Convert a 
   (%define 'parse-integer* (%lambda parse-integer* (list num radix)
				     (%if list


					  (parse-integer* (%cdr list) (%add (%mul num radix) (char->digit (%car list))) radix)
					  num)))
   (%define 'parse-integer (%lambda parse-integer (list)
				    (parse-integer* list 0 10)))

   ;; Is the character a whitespace
   (%define 'whitespace? (%lambda whitespace? (ch)
				  (or3 (%char-eq? ch #\Space)
				       (%char-eq? ch #\Return)
				       (%char-eq? ch #\Newline))))

   ;; Length of a list
   (%define 'length (%lambda length (list)
			     (%if list
				  (1+ (length (%cdr list)))
				  0)))
	      
   ;; Convert a list to an array
   (%define 'list->string* (%lambda list->string* (list str pos)
				    (%if list
					 (%progn
					  (%array-set str pos (%car list))
					  (list->string* (%cdr list) str (1+ pos)))
					 str)))
   (%define 'list->string (%lambda list->string (list)
				   (let ((str (%make-array (length list) #\Space)))
				     (list->string* list str 0))))

   ;; Skip whitespace characters from an input stream
   (%define 'skip-whitespace (%lambda skip-whitespace (s)
				      (let ((ch (s (%quote peek-char))))
					(%if (%eq? ch 'eos)
					     ch
					     (%if (whitespace? ch)
						  (%progn
						   (s 'get-char)
						   (skip-whitespace s))
						  ch)))))

   ;; Tokenize a symbol
   (%define 'tokenize-sym (%lambda tokenize-sym (s ch)
				   (%progn
				    (let ((type
					   (%if (member ch digits %char-eq?)
						'integer
						'symbol)))
				      (%define 'tknz
					       (%lambda tknz (s)
							(let ((ch (s 'peek-char)))
							  (%if (%eq? ch 'eos)
							       %nil
							       (%if (whitespace? ch)
								    %nil
								    (%if (isalpha? ch)
									 (%progn
									  (%set! 'type 'symbol)
									  (%cons (s 'get-char)
										 (tknz s)))
									 (%if (member ch digits %char-eq?)
									      (%cons (s 'get-char)
										     (tknz s))
									      %nil)))))))
				      ((%lambda snoc (a b)
						(%cons b a))
				       (let ((lst (%cons ch (tknz s))))
					 ((%if (%eq? type 'integer)
					       parse-integer
					       list->string)
					  lst))
				       type)))))

   ;; Tokenize a string
   (%define 'tokenize-string-rec (%lambda tokenize-string-rec (s)
					  (let ((ch (s 'get-char)))
					    (%if (%char-eq? ch #\") ; XXX: Check for end of stream
						 %nil

						 (%cons ch (tokenize-string-rec s))))))
					    
   (%define 'tokenize-string (%lambda tokenize-string (s)
				      (let ((sl (tokenize-string-rec s)))
					(%cons 'string (list->string sl)))))

   ;; Tokenize a hash object
   (%define 'tokenize-hash-x (%lambda tokenize-hash-x (s)
				      (%progn
				       (%define 'rec (%lambda tokenize-hash-x-rec ()
							      (let ((ch (s 'peek-char)))
								(%if (member ch digits-hex %char-eq?)
								     (%cons (s 'get-char) (rec))
								     %nil))))
				       (parse-integer* (rec) 0 16))))
								
     
   (%define 'tokenize-hash (%lambda tokenize-hash (s)
				    (let ((ch (s 'get-char)))
				      (%if (%char-eq? ch #\\)
					   (%cons 'character (s 'get-char))
					   (%if (%char-eq? ch #\x)
						(%cons 'integer (tokenize-hash-x s))
						(%cons 'error "Unknown hash character"))))))

   ;; Tokenize a stream
   (%define 'tokenize (%lambda tokenize (s)
			       (%progn
				(skip-whitespace s)
				(let ((ch (s 'get-char)))
				  (%if (%eq? ch 'eos)
				       (%cons 'eos %nil)
				       (%if (%char-eq? ch #\()
					    (%cons 'lparen %nil)
					    (%if (%char-eq? ch #\))
						 (%cons 'rparen %nil)
						 (%if (%char-eq? ch #\')
						      (%cons 'quote %nil)
						      (%if (%char-eq? ch #\")
							   (tokenize-string s)
							   (%if (%char-eq? ch #\#)
								(tokenize-hash s)
								(tokenize-sym s ch)))))))))))

   ;; Make a token stream
   (%define 'make-token-stream (%lambda make-token-stream (s)
					(let ((tok %nil))
					  (%lambda token-stream (cmd)
						   (%if (%eq? cmd 'next)
							(%if tok
							     (let ((tok2 tok))
							       (%set! 'tok %nil)
							       tok2)
							     (tokenize s))
							(%if (%eq? cmd 'peek)
							     (%if tok
								  tok
								  (%progn
								   (%set! 'tok (tokenize s))
								   tok))
							     %nil))))))

   ;; Parse a list from a token stream
   (%define 'parse-list (%lambda parse-list (s)
				 (let ((tok (s 'peek)))
				   (let ((token (%car tok)))
				     (%if (%eq? token 'eos)
					  (%error "Parse error, missing rparen at end of stream")
					  (%if (%eq? token 'rparen)
					       (%progn
						(s 'next)
						%nil)
					       (%cons (parse s) (parse-list s))))))))

   ;; Check if the string is a T type
   (%define 'is-t? (%lambda is-t? (str)
			    (%if (%num-eq? (%array-size str) 1)
				 (%if (%char-eq? (%array-get str 0) #\T)
				      %t
				      %nil)
				 %nil)))

   ;; Check if the string s a NIL type
   (%define 'is-nil? (%lambda is-nil? (str)
			      (string=? str "NIL")))

   ;; Uppercase a string
   (%define 'string-upper-rec (%lambda string-upper-rec (orig str i)
				       (%if (%num-eq? i (%array-size orig))
					    str
					    (%progn
					     (%array-set str i (char-upper (%array-get orig i)))
					     (string-upper-rec orig str (1+ i))))))
					 
   (%define 'string-upper (%lambda string-upper (str)
				   (let ((str2 (%make-array (%array-size str) #\a)))
				     (string-upper-rec str str2 0))))
     
   ;; Make a symbol of a string
   ;; T and NIL are "special" symbols
   (%define 'symbolify (%lambda symbolify (sym)
				(%if (%num-eq? (%array-size sym) 1)
				     (%if (is-t? sym)
					  %t
					  (%if (%char-eq? #\. (%array-get sym 0))
					       '%.
					       (intern sym)))
				     (%if (is-nil? sym)
					  %nil
					  (intern sym)))))
   ;; Parse a token stream
   (%define 'parse (%lambda parse (s)
			    (let ((tok (s 'next)))
			      (%if (%eq? (%car tok) 'lparen)
				   (parse-list s)
				   (%if (or3 (%eq? (%car tok) 'integer) (%eq? (%car tok) 'string) (%eq? (%car tok) 'character))
					(%cdr tok)
					(%if (%eq? (%car tok) 'symbol)
					     (symbolify (string-upper (%cdr tok)))
					     (%if (%eq? (%car tok) 'quote)
						  (%cons '%quote (%cons (parse s) %nil)))))))))

   ;; Parse a string into cons cells
   (%define 'read-from-string (%lambda read-from-string (str)
				       (let ((s (make-token-stream (make-string-stream str 0))))
					 (parse s))))

   ;; Write each character in the list to current output
   (%define 'print-list* (%lambda print-list* (list)
				  (%if list
				       (%progn
					(%put-char current-output (%car list))
					(print-list* (%cdr list)))
				       %nil)))

   ;; Print a character
   (%define 'print-char (%lambda print-char (ch)
				 (print-list* (%%list #\# #\\ ch))))


   ;; Check if an array is a string
   (%define 'is-string?-rec (%lambda is-string?-rec (arr i)
				     (%if (%num-eq? i (%array-size arr))
					  %t
					  (%if (%num-eq? (%type (%array-get arr i)) +type-char+)
					       (is-string?-rec arr (1+ i))
					       %nil))))
     
   (%define 'is-string? (%lambda is-string? (arr)
				 (is-string?-rec arr 0)))

   ;; Print a string
   (%define 'print-string-rec (%lambda print-string-rec (arr i)
				       (%if (%num-eq? (%array-size arr) i)
					    %nil
					    (%progn
					     (%put-char current-output (%array-get arr i))
					     (print-string-rec arr (1+ i))))))
     
   (%define 'print-string (%lambda print-string (arr)
				   (%progn
				    (%put-char current-output #\")
				    (print-string-rec arr 0)
				    (%put-char current-output #\"))))

   ;; Print an array
   (%define 'print-array-rec (%lambda print-array-rec (arr i)
				      (%if (%num-eq? (%array-size arr) i)
					   %nil
					   (%progn
					    (print (%array-get arr i))
					    (%put-char current-output #\Space)
					    (print-array-rec arr (1+ i))))))


   (%define 'print-array (%lambda print-array (arr)
					; String is a special type of array
				  (%if (is-string? arr)
				       (print-string arr)
				       (%progn
					(print-list* (%%list #\# #\[))
					(%put-char current-output #\Space)
					(print-array-rec arr 0)
					(%put-char current-output #\])))))

   ;; See if a cons cell really is a list
   (%define 'is-list? (%lambda is-list? (cons)
			       (%if (%num-eq? (%type cons) +type-cons+)
				    (is-list? (%cdr cons))
				    (%if (%num-eq? (%type cons) +type-nil+)
					 %t
					 %nil))))
   ;; Print a list
   (%define 'print-list-rec (%lambda print-list-rec (list)
				     (%progn
				      (print (%car list))
				      (%if (%num-eq? (%type (%cdr list)) +type-nil+)
					   %nil
					   (%progn
					    (%put-char current-output #\Space)
					    (print-list-rec (%cdr list)))))))
				       
   (%define 'print-list (%lambda print-list (list)
				 (%progn
				  (%put-char current-output #\()
				  (print-list-rec list)
				  (%put-char current-output #\)))))
				   
   ;; Print a cons cell
   (%define 'print-cons (%lambda print-cons (cons)
				 (%if (is-list? cons)
				      (print-list cons)
				      (%progn
				       (%put-char current-output #\()
				       (print (%car cons))
				       (%put-char current-output #\Space)
				       (%put-char current-output #\.)
				       (%put-char current-output #\Space)
				       (print (%cdr cons))
				       (%put-char current-output #\))))))

   ;; Print an integer
   (%define 'print-integer-rec (%lambda print-integer-rec (int list)
					(%if (%num-eq? int 0)
					     list
					     (print-integer-rec (%if (%num-eq? *print-base* 10)
								     (%div int 10)
								     (%bitwise-shift int -4))
								(%cons
								 (%if (%num-eq? *print-base* 10)
								      (%mod int 10)
								      (%bitwise-and int #xF))
								 list)))))

					; XXX: Make it an array for direct lookup?
   ;; Integer to digit character mapping
   (%define 'digit->char-map (%%list (%cons 0 #\0)
				     (%cons 1 #\1)
				     (%cons 2 #\2)
				     (%cons 3 #\3)
				     (%cons 4 #\4)
				     (%cons 5 #\5)
				     (%cons 6 #\6)
				     (%cons 7 #\7)
				     (%cons 8 #\8)
				     (%cons 9 #\9)
				     (%cons 10 #\A)
				     (%cons 11 #\B)
				     (%cons 12 #\C)
				     (%cons 13 #\D)
				     (%cons 14 #\E)
				     (%cons 15 #\F)
				     (%cons 10 #\a)
				     (%cons 11 #\b)
				     (%cons 12 #\c)
				     (%cons 13 #\d)
				     (%cons 14 #\e)
				     (%cons 15 #\f)))
   ;; Convert an integer (0 >= n < 10)
   (%define 'digit->char-rec (%lambda digit->char-rec (int list)
				      (%if list
					   (%if (%num-eq? (%car (%car list)) int)
						(%cdr (%car list))
						(digit->char-rec int (%cdr list)))
					   #\?)))
   (%define 'digit->char (%lambda digit->char (int)
				  (digit->char-rec int digit->char-map)))

   ;; Convert a character to a digit [0, F]
   (%define 'char->digit-rec (%lambda digit->char-rec (ch list)
				      (%if list
					   (%if (%char-eq? (%cdr (%car list)) ch)
						(%car (%car list))
						(char->digit-rec ch (%cdr list)))
					   0)))
   (%define 'char->digit (%lambda digit->char (ch)
				  (char->digit-rec ch digit->char-map)))

   (%define 'print-integer (%lambda print-integer (int)
				    (%if (%num-eq? int 0)
					 (print-list* (%if (%num-eq? *print-base* 10)
							   (%%list #\0)
							   (%%list #\# #\x #\0)))
					 (print-list*
					  (let ((start-int (%if (%num-eq? *print-base* 10)
								%nil
								(%%list #\# #\x))))
					    (print-list* start-int)
					    (%if (%less-than? int 0)
						 (%cons #\- (map digit->char (print-integer-rec (%mul (%sub 0 1) int) %nil)))
						 (map digit->char (print-integer-rec int %nil))))))))


   ;; Print a function
   (%define
    'print-function
    (%lambda
     print-function (f)
     (%progn
      (%put-char current-output #\#)
      (%put-char current-output #\()
      (print (function-name f))
      (%put-char current-output #\)))))

   ;; Print a builtin function
   (%define
    'print-builtin
    (%lambda
     print-builtin (b)
     (%progn
      (%put-char current-output #\#)
      (%put-char current-output #\()
      (print (%builtin-name b))
      (%put-char current-output #\)))))


   ;; Print an object
   (%define
    'print
    (%lambda
     print (expr)
     (%if (%num-eq? (%type expr) +type-t+)
	  (%put-char current-output #\T)
	  (%if (%num-eq? (%type expr) +type-nil+)
	       (print-list* (%%list #\N #\I #\L))
	       (%if (%num-eq? (%type expr) +type-char+)
		    (print-char expr)
		    (%if (%num-eq? (%type expr) +type-array+)
			 (print-array expr)
			 (%if (%num-eq? (%type expr) +type-cons+)
			      (print-cons expr)
			      (%if (%num-eq? (%type expr) +type-symbol+)
				   (print-string-rec (%symbol-to-string expr) 0)
				   (%if (%num-eq? (%type expr) +type-int+)
					(print-integer expr)
					(%if (%num-eq? (%type expr) +type-function+)
					     (print-function expr)
					     (%if (%num-eq? (%type expr) +type-builtin+)
						  (print-builtin expr)
						  (%put-char current-output #\#))))))))))))

   ;; Write newline
   (%define 'newline (%lambda newline ()
			      (%progn
			       (%put-char current-output #\Newline)
			       (%put-char current-output #\Return)
			       nil)))
				

   ;; Parse the input from a device
   (%define 'read-from-device (%lambda read-from-device (input-device)
				       (let ((s (make-token-stream (make-device-input-stream input-device))))
					 (parse s))))

   ;; Read line
   (%define 'read-line
	    (%lambda read-line (input-device)
		     (let ((s (make-device-input-stream input-device)))
		       (%define 'rec (%lambda read-line-rec ()
					      (let ((ch (s 'get-char)))
						(%if (or2 (%char-eq? #\Newline ch) (%char-eq? #\Return ch))
						     %nil
						     (%cons ch (rec))))))
		       (skip-whitespace s)
		       (list->string (rec)))))

   ;; Remove backspaced characters
   (%define 'fix-backspace
	    (%lambda fix-backspace (strin)
		     (let ((str (%make-array (%array-size strin) #\Newline)))
		       (let ((size (%array-size strin)))
			 (%define 'rec
				  (%lambda fix-backspace-rec (i j)
					   (%if (%num-eq? j size)
						(%if (%less-than? i j)
						     (%progn
						      (%array-set str i #\Newline)
						      (rec (1+ i) j))
						     str)
						(%if (%char-eq? (%array-get strin j) #\Backspace)
						     (rec (%if (%num-eq? i 0) 0 (1- i)) (1+ j))
						     (%progn
						      (%array-set str i (%array-get strin j))
						      (rec (1+ i) (1+ j)))))))
			 (rec 0 0)))))
							     
								       

     
   ;; Macro system
   ;; Move to nth-lisp file, RSN

   (%define 'macro-functions %nil)
     
   ;; defmacro
   (%define 'defmacro-fn (%lambda %defmacro (name fn)
				  (%set! 'macro-functions
					 (%cons (%cons name fn)
						macro-functions))))

   (%define 'get-macro-fn (%lambda get-macro-fn (name)
				   (%progn
				    (%define 'rec
					     (%lambda get-macro-fn-rec (name list)
						      (%if list
							   (%if (%eq? (%car (%car list)) name)
								(%cdr (%car list))
								(rec name (%cdr list)))
							   %nil)))
				    (rec name macro-functions))))
							    
     
   ;; Tree walker and expander

   (%define 'fix-lambda-arguments
	    (%lambda fix-lambda-arguments (args)
		     (%progn
		      (%define 'rec (%lambda fix-lambda-arguments-rec (args)
					     (%if args
						  (%if (%eq? '%. (%car args))
						       (%car (%cdr args))
						       (%cons (%car args) (rec (%cdr args))))
						  %nil)))
		      (%if (%num-eq? (%type args) +type-cons+)
			   (rec args)
			   args))))

   (%define 'fix-pair
	    (%lambda fix-pair (pair)
		     (%if (is-list? pair)
			  (%if (%num-eq? (length pair) 3)
			       (%if (%eq? '%. (%car (%cdr pair)))
				    (%%list (%car pair) (%car (%cdr (%cdr pair))))
				    pair)
			       pair)
			  pair)))
     
   (%define 'expand-macro
	    (%lambda expand-macro (root)
		     (%if (%num-eq? (%type root) +type-cons+)
			  (let ((mfn (get-macro-fn (%car root))))
			    (%if mfn
				 (expand-macro (mfn root))
				 root))
			  root)))
     
   (%define 'tree-walker
	    (%lambda tree-walker (root)
		     (%if (%num-eq? (%type root) +type-cons+)
			  (%if (%eq? (%car root) '%quote)
			       root
			       (let ((root (expand-macro (fix-pair root))))
				 (%if (%num-eq? (%type root) +type-cons+)
				      (%if (%eq? (%car root) '%lambda)
					   (%cons '%lambda
						  (%cons (%car (%cdr root))
							 (%cons (fix-lambda-arguments (%car (%cdr (%cdr root))))
								(map tree-walker (%cdr (%cdr (%cdr root)))))))
					   (map tree-walker root))
				      root)))
			  root)))

;;; Move this to NTH-Lisp code base
;;; !!!
     
   ;; Lambda macro
   (defmacro-fn 'lambda
       (%lambda 'lambda-macro (root)
		(list '%lambda
		      'anonymous
		      (%car (%cdr root))
		      (%cons '%progn
			     (%cdr (%cdr root))))))

   (defmacro-fn 'named-lambda
       (%lambda 'named-lambda-macro (root)
		(list '%lambda
		      (%car (%cdr root))
		      (%car (%cdr (%cdr root)))
		      (%cons '%progn
			     (%cdr (%cdr (%cdr root)))))))

     
   (defmacro-fn 'progn
       (%lambda 'progn-macro (root)
		(%cons '%progn
		       (%cdr root))))
		  
   (defmacro-fn 'quote
       (%lambda 'quote-macro (root)
		(%cons '%quote
		       (%cdr root))))

   (defmacro-fn 'let
       (%lambda 'let-macro (root)
		(list (%cons 'named-lambda
			     (%cons 'let
				    (%cons (list (%car (%car (%car (%cdr root)))))
					   (%cdr (%cdr root)))))
		      (%car (%cdr (%car (%car (%cdr root))))))))

   (defmacro-fn 'define
       (%lambda 'define-macro (root)
		(list '%define
		      (list '%quote (%car (%cdr root)))
		      (%car (%cdr (%cdr root))))))
   (defmacro-fn 'setq!
       (%lambda 'setq!-macro (root)
		(list '%set!
		      (list '%quote (%car (%cdr root)))
		      (%car (%cdr (%cdr root))))))

   (defmacro-fn 'cond
       (%lambda 'cond-macro (root)
		(%progn
		 (%define 'rec (%lambda 'cond-macro-rec (lst)
					(%if lst
					     (let ((pair (%car lst)))
					       (list '%if
						     (%car pair)
						     (%car (%cdr pair))
						     (rec (%cdr lst))))
					     %nil)))
		 (rec (%cdr root)))))

   (defmacro-fn 'if
       (%lambda 'if-macro (root)
		(list '%if
		      (%car (%cdr root))
		      (%car (%cdr (%cdr root)))
		      (%if (%num-eq? (length (%cdr root)) 2)
			   %nil
			   (%car (%cdr (%cdr (%cdr root))))))))
     
   (defmacro-fn 'or
       (%lambda 'or-macro (root)
		(%progn
		 (%define 'rec (%lambda or-macro-rec (args)
					(%if args
					     (list (list '%lambda 'anonymous (list 'x)
							 (list '%if
							       'x 'x
							       (rec (%cdr args))))
						   (%car args))
					     %nil)))
		 (rec (%cdr root)))))
     
   (defmacro-fn 'and
       (%lambda 'and-macro (root)
		(%progn
		 (%define 'rec (%lambda and-macro-rec (args)
					(%if args
					     (list '%if
						   (%car args)
						   (rec (%cdr args))
						   (%car args))
					     %t)))
		 (rec (%cdr root)))))
     
   ;; Reduce
   (%define 'reduce (%lambda 'reduce (fn init list)
			     (%if list
				  (reduce fn (fn init (%car list)) (%cdr list))
				  init)))

   ;; Make a function that calls reduce with the first argument as the
   ;; init value and the rest of the arguments as the list.
   ;; reducer takes a function that will be used during the reduce  as
   ;; the only input.
   (%define 'reducer (%lambda 'reduce (fn identity)
			      (%lambda 'anonymous-reducer list
				       (%if list
					    (reduce fn (%if identity identity (%car list)) (%if identity list (%cdr list)))
					    identity))))

   (%define '+ (reducer %add 0))
   (%define '- (%lambda sub lst
			(%if (%num-eq? (length lst) 1)
			     (%sub 0 (%car lst))
			     (reduce %sub (%car lst) (%cdr lst)))))
   (%define '* (reducer %mul 1))
   (%define '/ %div)
   (%define 'mod %mod)

   (%define '= %num-eq?)
   (%define '< %less-than?)
   (%define '> (%lambda 'greater-than? (a b)
			(%if (or2 (%num-eq? a b)
				  (%less-than? a b))
			     %nil
			     %t)))
     
   (%define 'car %car)
   (%define 'cdr %cdr)
   (%define 'cons %cons)
   (%define 'set! %set!)
   (%define 'set-car! %set-car!)
   (%define 'set-cdr! %set-cdr!)
   (%define 'make-array %make-array)
   (%define 'array-get %array-get)
   (%define 'array-size %array-size)

   (defun append (li lu)
     (%if li
	 (cons (car li) (append (cdr li) lu))
	 lu))

   (defun null? (dings)
     (%if (%eq? nil dings)
	 %t
	 %nil))


   
;;; !!! END
     
   (%define
    'combine
    (%lambda
     combine (f g)	     ; produces combination of single-argument
					; functions f and g
     (%lambda combination (x) (f (g x)))))

   (%define 'caar (combine car car))
   (%define 'cadr (combine car cdr))
   (%define 'cdar (combine cdr car))
   (%define 'cddr (combine cdr cdr))
   (%define 'cdddr (combine cddr cdr))
   (%define 'caddr (combine cadr cdr))
   (%define 'cadddr (combine caddr cdr))

   (%define 'igorev-state-func-frame car)
   (%define 'igorev-state-condition cadr)
   (%define 'igorev-state-iterations caddr)

   (%define 'igorev-func-frame-func car)
   (%define 'igorev-func-frame-env cadr)
   (%define 'igorev-func-frame-eval-frame caddr)
   (%define 'igorev-func-frame-parent cadddr)

   (%define 'igorev-eval-frame-expr car)
   (%define 'igorev-eval-frame-arg cadr)
   (%define 'igorev-eval-frame-result caddr)
   (%define 'igorev-eval-frame-phase cadddr)
   (%define 'igorev-eval-frame-parent (combine caddr cddr))

   (%define
    'igorev-state-huge-success?
    (%lambda
     igorev-state-huge-success? (state)
     (%eq? (igorev-state-condition state) nil)))

   (%define
    'igorev-state-result
    (%lambda
     igorev-state-result (state)
     (igorev-eval-frame-result
      (igorev-func-frame-eval-frame
       (igorev-state-func-frame state)))))

   (%define
    'igorev-state-expr
    (%lambda
     igorev-state-expr (state)
     (igorev-eval-frame-expr
      (igorev-func-frame-eval-frame
       (igorev-state-func-frame state)))))

   (%define 'igorev-env-local-bindings car)


   (%define
    'function-name
    (%lambda
     function-name (f)
     (%car (%function-data f))))

   (%define
    'function-param-list
    (%lambda
     function-param-list (f)
     (%cadr (%function-data f))))

   (%define
    'function-expr
    (%lambda
     function-expr (f)
     (%caddr (%function-data f))))

   (%define
    'function-env
    (%lambda
     function-end (f)
     (%cadddr (%function-data f))))



   (%define
    'show-error-message
    (%lambda
     show-error-message (state)
     (%progn
      (display "Error: ")
      (print (igorev-state-condition state))
      (display " at ")
      (print (igorev-state-expr state))
      (newline)
      (display " in ")
      (print (igorev-func-frame-func (igorev-state-func-frame state)))
      (newline))))


   (%define
    'display
    (%lambda
     display (str)
     (%progn
      (%define
       'display-rec
       (%lambda
	display-rec (i)
	(%if (%less-than? i (%array-size str))
	     (%progn
	      (%put-char current-output (%array-get str i))
	      (display-rec (1+ i)))
	     nil)))
      (%if (is-string? str)
	   (display-rec 0)
	   (%error (list '%err-type-error str 'string))))))
     
   (defun displine (str)
     (display str)
     (newline)
     nil)



;;    (%define
;;     'new-environment
;;     (%lambda
;;      new-environment (parent)
;;      (%cons %nil parent)))

   (defun new-environment (parent)
     (%cons %nil parent))

   (defun debug (state)
     (displine "Entering debugger")
     (let ((top-fframe (igorev-state-func-frame state)))
       (let ((top-eframe (igorev-func-frame-eval-frame top-fframe)))
	 (dbg-show-fframe top-fframe)
	 (dbg-show-eframe top-eframe)
	 (dbg-repl state top-fframe '() top-eframe '()))))
     
   (defun dbg-show-fframe (f)
     (displine "Current function frame:")
     (display " Function: ")
     (print (igorev-func-frame-func f))
     (newline)
     (display " Local bindings: ")
     (print (igorev-env-local-bindings
	     (igorev-func-frame-env f)))
     (newline))

   (defun dbg-show-eframe (e)
     (displine "Current eval frame:")
     (display " Expr: ")
     (print (igorev-eval-frame-expr e))
     (newline)
     (display " Arg: ")
     (print (igorev-eval-frame-arg e))
     (newline)
     (display " Result: ")
     (print (igorev-eval-frame-result e))
     (newline)
     (display " Phase: ")
     (print (igorev-eval-frame-phase e))
     (newline))

   (defun dbg-show-fstack (frame descendants)
     (defun print-frame (f num is-current)
       (%if is-current (display "(*)") nil)
       (print num)
       (display ": ")
       (print (igorev-func-frame-func f))
       (newline))
     (defun print-frames (frames i)
       (%if frames
	    (%progn
	     (print-frame (car frames) i
			  (%eq? (car frames) frame))
	     (print-frames (cdr frames) (1+ i)))
	    nil))
     (defun collect-frames (frame rest)
       (%if frame
	    (collect-frames (igorev-func-frame-parent frame)
			    (cons frame rest))
	    rest))
     (print-frames (collect-frames frame descendants) 0))

   (defun dbg-show-estack (frame descendants)
     (defun print-frame (f num is-current)
       (%if is-current (display "(*)") nil)
       (print num)
       (display ": ")
       (print (igorev-eval-frame-expr f))
       (newline))
     (defun print-frames (frames i)
       (%if frames
	    (%progn
	     (print-frame (car frames) i
			  (%eq? (car frames) frame))
	     (print-frames (cdr frames) (1+ i)))
	    nil))
     (defun collect-frames (frame rest)
       (%if frame
	    (collect-frames (igorev-eval-frame-parent frame)
			    (cons frame rest))
	    rest))
     (print-frames (collect-frames frame descendants) 0))

   (defun dbg-show-env (fframe)
     (displine "(TODO)"))

   (defun dbg-repl (state fframe fframes-below eframe eframes-below)
     (%define 'continue %t)
     (defun env ()
       (igorev-func-frame-env fframe))
     (defun deval (expr)
       (%eval expr (env)))
     (defun up ()
       (let ((parent (igorev-func-frame-parent fframe)))
	 (%if parent
	      (%progn
	       (%set! 'fframes-below (cons fframe fframes-below))
	       (%set! 'fframe parent)
	       (%set! 'eframe (igorev-func-frame-eval-frame fframe))
	       (%set! 'eframes-below '())
	       (displine "Moved one function frame up"))
	      (displine "Current function frame is an orphan"))))
     (defun down ()
       (%if fframes-below
	    (%progn
	     (%set! 'fframe (car fframes-below))
	     (%set! 'fframes-below (cdr fframes-below))
	     (%set! 'eframe (igorev-func-frame-eval-frame fframe))
	     (%set! 'eframes-below '())
	     (displine "Moved one function frame down"))
	    (displine "Current function frame is childless")))
     (defun eup ()
       (let ((parent (igorev-eval-frame-parent eframe)))
	 (%if parent
	      (%progn
	       (%set! 'eframes-below (cons eframe eframes-below))
	       (%set! 'eframe parent)
	       (displine "Moved one eval frame up"))
	      (displine "Current eval frame is an orphan"))))
     (defun edown ()
       (%if eframes-below
	    (%progn
	     (%set! 'eframe (car eframes-below))
	     (%set! 'eframes-below (cdr eframes-below))
	     (displine "Moved one eval frame down"))
	    (displine "Current eval frame is childless")))
     (defun show (what)
       (%if (%eq? what 'fframe)
	    (dbg-show-fframe fframe)
	    (%if (%eq? what 'eframe)
		 (dbg-show-eframe eframe)
		 (%if (%eq? what 'env)
		      (dbg-show-env fframe)
		      (%if (%eq? what 'fstack)
			   (dbg-show-fstack fframe fframes-below)
			   (%if (%eq? what 'estack)
				(dbg-show-estack eframe eframes-below)
				(displine "What what?")))))))
     (defun quit ()
       (%set! 'continue %nil))
     (defun read ()
       (display "dbg> ")
       (let ((expr (tree-walker
		    (read-from-string (fix-backspace (read-line current-input))))))
	 (newline)
	 expr))
     (defun eval/print (expr)
       (let ((state (%eval-partial
		     (%make-eval-state expr
				       (new-environment (%current-environment)))
		     0)))
	 (%if (igorev-state-huge-success? state)
	      (%progn
	       (display "Result: ")
	       (print (igorev-state-result state))
	       (newline))
	      (show-error-message state))))

     (eval/print (read))
     (%if continue
	  (dbg-repl state fframe fframes-below eframe eframes-below)
	  (displine "Exiting debugger")))
	 


   (defun try (expr)
     (let ((state (%eval-partial
		   (%make-eval-state (tree-walker expr)
				     (%current-environment))
		   0)))
       (%if (igorev-state-huge-success? state)
	    (list 'success (igorev-state-result state))
	    (list 'interrupt (cdr (igorev-state-condition state)) state))))

   (defun catch-fn (handlers expr)
     (defun find-handler (condition handlers)
       (%if handlers
	    (%if ((caar handlers) condition)
		 (cdar handlers)
		 (find-handler condition (cdr handlers)))
	    nil))
     (let ((result (try expr)))
       (%if (%eq? (car result) 'success)
	    (cadr result)
	    (let ((condition (cadr result)))
	      (let ((handler (find-handler condition handlers)))
		(%if handler
		     (handler condition)
		     (%error condition)))))))

   (defmacro-fn
       'catch
       (%lambda
	catch-macro (root)
	(let ((cond-var (cadr root)))
	  (let ((handlers (caddr root)))
	    (let ((body (cdddr root)))
	      (list 'catch-fn
		    (cons
		     'list
		     (map (%lambda
			   catch-macro-create-handler-function (handler)
			   (list 'cons
				 (list '%lambda 'catch-handler-predicate (list cond-var)
				       (car handler))
				 (list '%lambda 'catch-handler-function (list cond-var)
				       (cadr handler))))
			  handlers))
		    (list '%quote (cons '%progn body))))))))
	       
   (defun condition-type (condition)
     (%if (is-list? condition)
	  (car condition)
	  condition))



   (%define '*igorrepl-continue* %t)
   (%define
    'quit
    (%lambda
     quit ()				; make it all go away
     (%set! '*igorrepl-continue* nil)))

   ;; REPL
   (%define 'igorrepl (%lambda igorrepl (n env)
			       (%progn
				(display "IGORrepl: ")
				(let ((state (%make-eval-state
					      (tree-walker
					       (read-from-string (fix-backspace (read-line current-input))))
					      env)))
				  (newline)
				  (let ((state (%eval-partial state 0)))
				    (let ((cond (%car (%cdr state))))
				      (newline)
				      (%if (igorev-state-huge-success? state)
					   (%progn
					    (display "Result: ")
					    (print (igorev-state-result state)))
					   (%progn
					    (show-error-message state)
					    (debug state)))
				      (newline)
				      (%if *igorrepl-continue*
					   (%if (%num-eq? n 1)
						%t
						(igorrepl (%if (%num-eq? n 0) 0 (1- n)) env))
					   nil)))))))
	      


   ;;(intern-symbols %symbol-table)

   (display "boot program $Rev: 1441 $")
   (newline)
  
   (%define
    'looptyloop
    (%lambda
     looptyloop ()
     (let ((state (%make-eval-state '(igorrepl 0 (new-environment (%current-environment)))
				    (%current-environment))))
       (let ((new-state (%eval-partial state 0)))
	 (%if (igorev-state-huge-success? new-state)
	      (%progn
	       (display "Happy Happy Joy Joy")
	       (newline))
	      (%progn
	       (newline)
	       (display "ERROR IN TOP-LEVEL REPL")
	       (newline)
	       (show-error-message new-state)
	       (looptyloop)))))))
   (looptyloop)
))

