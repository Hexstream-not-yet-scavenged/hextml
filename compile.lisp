(in-package #:hextml_compile)

(defclass html-compiler ()
  ())

(defun compile-html (compiler element)
  (html-compile compiler element))

(defgeneric html-compile (compiler element))

(defmethod html-compile ((compiler html-compiler) anything)
  (lambda (renderer stream)
    (html-render renderer anything stream)))

(defmethod html-compile ((compiler html-compiler) (function function))
  (lambda (renderer stream)
    (funcall function renderer stream)))

(defmethod html-compile ((compiler html-compiler) (annotation hextml-annotation))
  (html-compile compiler (hextml-annotation-target annotation)))

(defmethod html-compile ((compiler html-compiler) (node html-node))
  (with-readers ((type html-node-type)
		 (attributes html-node-attributes)
		 (children html-node-children))
      node
    (let ((attributes-generator (make-html-attributes-generator compiler attributes))
	  (child-generators (mapcar (fmask #'html-compile ? (compiler ?))
				    children)))
      (if child-generators
	  (lambda (renderer stream)
	    (format stream "<~A" type)
	    (funcall attributes-generator renderer stream)
	    (write-char #\> stream)
	    (dolist (child-generator child-generators)
	      (funcall child-generator renderer stream))
	    (format stream "</~A>" type))
	  (lambda (renderer stream)
	    (format stream "<~A" type)
	    (funcall attributes-generator renderer stream)
	    (write-string " />" stream))))))

(defmethod html-compile ((compiler html-compiler) (html-id html-id))
  (html-compile compiler (html-id-to-string html-id)))

(defmethod html-compile ((compiler html-compiler) (html html-if))
  (with-readers ((condition html-if-condition)
		 (then html-if-then)
		 (else html-if-else)) html
    (let ((compiled-then (if then
			     (html-compile compiler then)))
	  (compiled-else (if else
			     (html-compile compiler else))))
      (lambda (renderer stream)
	
	(let ((branch (if (eval-html-if-condition renderer condition)
			  compiled-then
			  compiled-else)))
	  (if branch
	      (funcall branch renderer stream)))))))

(defmethod html-compile ((compiler html-compiler) (html html-do))
  (let ((var (html-do-var html))
	(reference (html-do-reference html))
	(compiled (html-compile compiler (html-do-html html))))
    (lambda (renderer stream)
      (dolist (item (resolve-template-env-reference reference
						    (template-env renderer)))
	(funcall compiled
		 (make-instance 'html-renderer
				:template-env
				(make-instance 'template-env
					       :parent (template-env renderer)
					       :bindings (list (cons var item))))
		 stream)))))

(defmethod html-compile ((compiler html-compiler) (str string))
  (lambda (renderer stream)
    (declare (ignore renderer))
    (write-string str stream)))

(defmethod html-compile ((compiler html-compiler) (nothing null))
  (lambda (&rest whatever)
    (declare (ignore whatever))
    nil))

(defmethod html-compile ((compiler html-compiler) (list list))
  (let ((compiled (mapcar (fmask #'html-compile ? (compiler ?))
			  list)))
    (lambda (renderer stream)
      (dolist (compiled compiled)
	(funcall compiled renderer stream)))))

(defmethod html-compile ((compiler html-compiler) (uri uri))
  (html-compile compiler (princ-to-string uri)))

(defmethod html-compile ((compiler html-compiler) (ref template-env-reference))
  (lambda (renderer stream)
    (html-render renderer (resolve-template-env-reference ref (template-env renderer))
		 stream)))

(defun make-html-attributes-generator (compiler attribute-alist)
  (let ((compiled
	 (mapcar (destructuring-lambda ((attribute . value))
		   (let ((attribute attribute))
		     (if (html-if-p value)
			 (html-compile compiler
				       (flet ((bof (branch)
						(lif ((html (funcall branch value)))
						     (list (format nil " ~A=\"" attribute)
							   html
							   "\""))))
					 (make-html-if (html-if-condition value)
						       (bof #'html-if-then)
						       (bof #'html-if-else))))
			 (if (labels ((look (thing)
					(etypecase thing
					  (html-if t)
					  (list (member-if #'look thing))
					  (t nil))))
			       (look value))
			     (html-compile compiler
					   (list (format nil " ~A=\"" attribute)
						 value
						 "\""))
			     (etypecase attribute
			       (string
				  (let ((compiled-value (html-compile compiler value)))
				    (lambda (renderer stream)
				      (format stream " ~A=\"" attribute)
				      (funcall compiled-value renderer stream)
				      (write-char #\" stream))))
			       ((eql quote)
				  (html-compile compiler value)))))))
		 attribute-alist)))
    (lambda (renderer stream)
      (dolist (compiled compiled)
	(funcall compiled renderer stream)))))
