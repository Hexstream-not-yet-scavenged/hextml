(in-package #:hextml_front)

(declare-html-noprocess quote)
(declare-html-noprocess build-html)
(declare-html-noprocess output-html)

(define-hextml-macro case (keyform &body cases)
  (expand-caselike 'case keyform cases))

(define-hextml-macro ccase (keyform &body cases)
  (expand-caselike 'ccase keyform cases))

(define-hextml-macro ecase (keyform &body cases)
  (expand-caselike 'ecase keyform cases))

(define-hextml-macro let (bindings &body body)
  (expand-letlike 'let bindings body))

(define-hextml-macro let* (bindings &body body)
  (expand-letlike 'let* bindings body))

(define-hextml-macro env (key &rest other-initargs)
  `(make-instance 'template-env-reference
		  :key ,key
		  ,@other-initargs))

(define-hextml-macro html-dyn (key)
  `(make-instance 'template-env-reference
		  :key ,key
		  :resolve-when :rendering))

(define-hextml-macro html-id (id)
  `(make-html-id ,id))

(define-hextml-macro html-if (condition then &optional else)
  `(make-html-if (html-noprocess ,condition)
		 ,then
		 ,@(if else
		       (list else))))

(define-hextml-macro html-when (condition &body html)
  `(progn (html-if ,condition (list ,@html))))

(define-hextml-macro html-unless (condition &body html)
  `(progn (html-when (list 'not ,condition) ,@html)))

(define-hextml-macro html-cond (&body clauses)
  (labels ((recurse (clauses)
	     (if clauses
		 (destructuring-bind (condition &rest forms) (car clauses)
		   `(html-if ,condition
			     (list ,@forms)
			     ,@(lif ((result (recurse (cdr clauses))))
				    (list result)))))))
    (if clauses
	`(progn ,(recurse clauses)))))

(define-hextml-macro html-do (var reference &body html)
  `(make-html-do ,var ,reference (list ,@html)))