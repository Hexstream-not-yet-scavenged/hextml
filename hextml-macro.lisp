(in-package #:hextml_front)

(define-macro-system
    *hextml-macro-functions*
    hextml-macro-function
  define-hextml-macro
  hextml-macroexpand-1)

(defmacro declare-html-noprocess (operator)
  `(define-hextml-macro ,operator (&rest forms)
    `(html-noprocess (,',operator ,@,'forms))))

(defun expand-caselike (operator keyform cases)
  `(,operator ,keyform
	      ,@(iter (for (condition . body) in cases)
		      (collect `((html-noprocess ,condition) ,@body)))))

(defun expand-letlike (operator bindings body)
  `(,operator ,(iter (for binding in bindings)
		     (collect (if (consp binding)
				  (cons `(html-noprocess ,(car binding))
					(cdr binding))
				  `(html-noprocess ,binding))))
	      ,@body))
