;;;; cos-pprint.scm --- pretty-print definitions for COS
;;;; Copyright (C) 2005, 2009 Red Hat, Inc.
;;;; This file is part of CGEN.
;;;; See file COPYING.CGEN for details.

;;; To use this with pprint.scm:
;;;
;;;   (load "pprint.scm")
;;;   (load "cos-pprint.scm")
;;;
;;; You must load this file second, so it can redefine the ELIDE? and
;;; ELIDED-NAME hooks.
;;;
;;; See the documentation in pprint.scm for details.

(define (elide? obj)
  (or (object? obj) (class? obj)))

(define (elided-name obj)
  (cond ((class? obj) `(class ,(class-name obj)))
	((object? obj)
	 `(object ,(class-name (object-class obj))
		  ,@(if (method-present? obj 'get-name)
			(list (send obj 'get-name))
			'())))
	(else (error "unexpected elided object"))))
