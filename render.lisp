(in-package #:hextml_render)

(defclass html-renderer (template-env-mixin)
  ())

(defmethod shared-initialize :after ((renderer html-renderer) slot-names
				     &key (template-env nil template-env-supplied-p))
  (if template-env-supplied-p
      (check-type template-env template-env)))

(defun render-html (renderer element stream)
  (html-render renderer element stream))

(defun render-html-to-string (renderer element)
  (with-output-to-string (str)
    (render-html renderer element str)))

(defgeneric html-render (renderer element stream))

(defmethod html-render ((renderer html-renderer) (function symbol) stream)
  (funcall function renderer stream))

(defmethod html-render ((renderer html-renderer) (function function) stream)
  (funcall function renderer stream))

(defmethod html-render ((renderer html-renderer) (annotation hextml-annotation) stream)
  (html-render renderer (hextml-annotation-target annotation) stream))

(defmethod html-render ((renderer html-renderer) (node html-node) stream)
  (with-html-node-readers () node
    (format stream "<~A" type)
    (render-html-attributes renderer attributes stream)
    (if (null children)
	(write-string " />" stream)
	(progn
	  (write-char #\> stream)
	  (mapc (fmask #'html-render ? (renderer ? stream))
		children)
	  (format stream "</~A>" type)))))

(defmethod html-render ((renderer html-renderer) (html-id html-id) stream)
  (write-string (html-id-to-string html-id) stream))

(defmethod html-render ((renderer html-renderer) (string string) stream)
  (declare (ignore renderer))
  (princ string stream))

(defmethod html-render ((renderer html-renderer) (number number) stream)
  (declare (ignore renderer))
  (princ number stream))

(defmethod html-render ((renderer html-renderer) (nothing null) stream)
  (declare (ignore renderer nothing stream)))

(defmethod html-render ((renderer html-renderer) (list list) stream)
  (mapc (fmask #'html-render ? (renderer ? stream))
	list))

(defmethod html-render ((renderer html-renderer) (uri uri) stream)
  (declare (ignore renderer))
  (princ uri stream))

(defmethod html-render ((renderer html-renderer) (ref template-env-reference) stream)
  (html-render renderer (resolve-template-env-reference ref (template-env renderer)) stream))

(defun render-html-attributes (renderer attribute-alist stream)
  (let ((env (template-env renderer)))
    (doalist (attribute value attribute-alist)
	     (if (html-if-p value)
		 (let ((html (if (eval-html-if-condition renderer
							 (html-if-condition value))
				 (html-if-then value)
				 (html-if-else value))))
		   (when html
		     (format stream " ~A=\"" attribute)
		     (html-render renderer html stream)
		     (write-char #\" stream)))
		 (etypecase attribute
		   (string (let ((real-value (real-attribute-value renderer value env)))
			     (if real-value (format stream " ~A=\"~A\"" attribute real-value))))
		   ((eql quote) (html-render renderer value stream)))))))

(defun real-attribute-value (renderer value template-env)
  (etypecase value
    (function (funcall renderer value))
    (template-env-reference (real-attribute-value renderer
						  (resolve-template-env-reference value
										  template-env)
						  template-env))
    (t value)))

(defmethod html-render ((renderer html-renderer) (html html-if) stream)
  (let ((branch (if (eval-html-if-condition renderer (html-if-condition html))
		    (html-if-then html)
		    (html-if-else html))))
    (if branch
	(html-render renderer branch stream))))

(defmethod html-render ((renderer html-renderer) (html html-do) stream)
  (let ((var (html-do-var html)))
    (dolist (item (resolve-template-env-reference (html-do-reference html)
						  (template-env renderer)))
      (html-render (make-instance 'html-renderer
				  :template-env
				  (make-instance 'template-env
						 :parent (template-env renderer)
						 :bindings (list (cons var item))))
		   (html-do-html html) stream))))
