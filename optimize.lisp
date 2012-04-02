(in-package #:hextml)

(defclass html-optimizer ()
  ())

(defmacro with-output-to-accumulator ((accumulator-var) &body body)
  `(let ((,accumulator-var (make-string-output-stream)))
    (unwind-protect (progn
		      ,@body)
      (if ,accumulator-var
	  (close ,accumulator-var)))))


(defun optimize-html (optimizer html)
  (with-optimizer (collect result
		    #'(lambda (thing accumulator)
			(typecase thing
			  ((or string character number uri)
			   (princ thing accumulator))
			  ((satisfies keywordp)
			   (write-string (string-downcase (symbol-name thing))
					 accumulator))))
		    #'identity)
    (let ((*collect* #'collect))
      (html-optimize optimizer html)
      (result))))

(defgeneric html-optimize (optimizer element))

(defmethod html-optimize ((optimizer html-optimizer) (anything t))
  (collect anything))

(defgeneric html-optimize-attribute-value (optimizer value))

(defmethod html-optimize-attribute-value ((optimizer html-optimizer) anything)
  (collect anything))

(defmethod html-optimize-attribute-value ((optimizer html-optimizer) (value list))
  (mapc (fmask #'html-optimize-attribute-value ? (optimizer ?))
	value))

(defmethod html-optimize ((optimizer html-optimizer) (annotation hextml-annotation))
  (html-optimize optimizer (hextml-annotation-target annotation)))

(defmethod html-optimize ((optimizer html-optimizer) (node html-node))
  (with-html-node-readers
      () node
      (cond ((labels ((look (thing)
			(etypecase thing
			  (html-if t)
			  (list (member-if #'look thing))
			  (t nil))))
	       (member-if #'look attributes :key #'cdr))
	     (collect (make-html-node type
				      attributes
				      (list (optimize-html optimizer children)))))
	    (t (collect #\<)
	       (collect type)
	       (doalist (attribute value attributes)
			(cond ((null value)
			       nil)
			      (t
			       (etypecase attribute
				 (string
				  (collect " ")
				  (collect attribute)
				  (collect "=\"")
				  (html-optimize-attribute-value optimizer value)
				  (collect "\""))
				 ((eql quote)
				  (html-optimize optimizer value))))))
	       (when children
		 (collect ">")
		 (mapc (fmask #'html-optimize ? (optimizer ?))
		       children)
		 (collect (format nil "</~A>" type)))
	       (if (null children)
		   (collect " />"))))))

(defmethod html-optimize ((optimizer html-optimizer) (html-id html-id))
  (collect (html-id-to-string html-id)))

(defun optimize-html-if-condition (condition)
  (etypecase condition
    (atom condition)
    (cons (if (member-if #'numberp (cdr condition))
	      condition
	      (let* ((operator (car condition))
		     (operands (if (not (eq operator 'env))
				   (mapcar #'optimize-html-if-condition (cdr condition)))))
		(flet ((envp (thing)
			 (and (consp thing) (eq (car thing) 'env))))
		  (case operator
		    (env condition)
		    (funcall `(funcall ,(optimize-html-if-condition (second condition))
				       ,@(cddr condition)))
		    (and (if (member nil operands)
			     nil
			     (let ((operands (delete t operands)))
			       (if operands
				   (if (cdr operands)
				       `(and ,@operands)
				       (first operands))
				   t))))
		    (or (if (member t operands)
			    t
			    (let ((operands (delete nil operands)))
			      (if operands
				  (if (cdr operands)
				      `(or ,@operands)
				      (first operands))
				  nil))))
		    (not (let ((optimized (first operands)))
			   (if (labels ((search-for-envp (thing)
					  (if (envp thing)
					      t
					      (if (consp thing)
						  (some #'search-for-envp thing)))))
				 (search-for-envp optimized))
			       `(not ,optimized)
			       (not optimized))))
		    (t (if (or (functionp operator))
			   (cons operator operands)
			   (if (eq operator 'string=)
			       (cons operator operands)
			       (if (and (consp operator) (eq (car operator) 'access))
				   (let ((operator (second operator)))
				     (if (member-if #'envp operands)
					 (if (apply #'compare-access operator (remove-if #'envp operands))
					     `((access ,operator)
					       ,@(if (eq operator '=)
						     (remove-duplicates operands :test #'equal)
						     operands)))
					 (if (apply #'compare-access operator operands)
					     t nil)))
				   (if (eq operator '=)
				       (if (member-if #'envp operands)
					   (if (apply #'all-eq (remove-if #'envp operands))
					       `(,operator ,@(remove-duplicates operands :test #'equal)))
					   (apply #'all-eq (cdr condition)))
				       (error "dunno what to do...")))))))))))))

(defmethod html-optimize ((optimizer html-optimizer) (html html-if))
  (collect (transform-html-if html
			      (lambda (condition)
				(optimize-html-if-condition condition))
			      (lambda (branch)
				(optimize-html optimizer branch)))))

(defmethod html-optimize ((optimizer html-optimizer) (html html-do))
  (collect (make-html-do (html-do-var html) (html-do-reference html)
			 (optimize-html optimizer (html-do-html html)))))

(defmethod html-optimize-attribute-value ((optimizer html-optimizer) (value html-if))
  (html-optimize optimizer value))

(defmethod html-optimize-attribute-value ((optimizer html-optimizer) (value html-id))
  (html-optimize optimizer value))

(defmethod html-optimize ((optimizer html-optimizer) (list list))
  (mapc (fmask #'html-optimize ? (optimizer ?))
	list))
