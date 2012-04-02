(in-package #:hextml)

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
	      ,@(mapalist (lambda (condition body)
			  `((html-noprocess ,condition) ,@body))
			cases)))

(defun expand-letlike (operator bindings body)
  `(,operator ,(mapcar (lambda (binding)
			 (if (consp binding)
			     (cons `(html-noprocess ,(car binding))
				   (cdr binding))
			     `(html-noprocess ,binding)))
		       bindings)
	      ,@body))
