(in-package #:hextml_resolve)

(defclass html-resolver (html-rewriter template-env-mixin)
  ())

(defmethod html-rewrite ((resolver html-resolver) (uri uri))
  (princ-to-string uri))

(defmethod html-rewrite ((resolver html-resolver) (ref template-env-reference))
  (ecase (template-env-reference-resolve-when ref)
    (:early (lif ((value (resolve-template-env-reference ref (template-env resolver))))
		 (html-rewrite resolver value)
		 (error "Tried to resolve template-env-reference ~A early ~
                        but it was not found in the template-env of the resolver."
			(template-env-reference-key ref))))
    (:rendering ref)))

(defmethod html-rewrite ((resolver html-resolver) (subref template-env-subreference))
  )

(defmethod html-rewrite ((resolver html-resolver) (marker template-env-subreference-marker))
  )

(defun resolve-html-if-condition (template-env condition)
  (etypecase condition
    ((cons (eql env))
     (multiple-value-bind (value foundp) (resolve-template-env-reference (second condition)
									 template-env)
       (if foundp value condition)))
    (atom condition)
    (cons (cons (car condition)
		(mapcar (fmask #'resolve-html-if-condition ? (template-env ?))
			(cdr condition))))))

(defmethod html-rewrite ((resolver html-resolver) (html html-if))
  (transform-html-if html
		     (lambda (condition)
		       (resolve-html-if-condition (template-env resolver) condition))
		     (lambda (branch)
		       (rewrite-html resolver branch))))

(defmethod html-rewrite ((resolver html-resolver) (html html-do))
  (make-html-do (html-do-var html) (html-do-reference html)
		(rewrite-html resolver (html-do-html html))))