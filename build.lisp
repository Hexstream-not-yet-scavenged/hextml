(in-package #:hextml)

(defmacro build-html (&body forms)
  (if (cdr forms)
      `(list ,@(mapcar #'html-build forms))
      (html-build (car forms))))

(defvar *string-to-marker* nil)

(defun html-build (form)
  (let ((form (hextml-macroexpand-1 form)))
    (cond ((stringp form)
	   (let ((found (assoc form *string-to-marker* :test #'string=)))
	     (if found `',(cdr found) form)))
	  ((or (atom form)
	       (not (listp (cdr form))))
	   form)
	  ((noprocess-form-p form)
	   (second form))
	  ((stringp (car form))
	   (destructuring-bind (key &rest template) form
	     (if (not template)
		 (setf template (list key)))
	     (let* ((marker (gensym (format nil "~A-MARKER" (string-upcase key))))
		    (*string-to-marker* (acons key marker *string-to-marker*)))
	       `(make-template-env-subreference ,key (list ,@(mapcar #'html-build template))
						',marker))))
	  ((tag-form-p form)
	   (html-build-node (cdr form)))
	  ((html-node-form-p form)
	   (html-build-node form))
	  (t (mapcar #'html-build form)))))

(defun html-build-node (form)
  (multiple-value-bind (type attributes children) (destructure-html-node-form form)
    `(make-instance 'html-node
      :type ,type
      :attributes (list
		   ,@(mapalist (lambda (attribute value)
				 `(cons ,attribute
					,(cond ((and (consp value)
						     (eq (first value) 'boolean))
						`(make-html-if ,(second value)
							       ,(lif ((html (cddr value)))
								     `(list ,@(mapcar #'html-build
										      html))
								     attribute)))
					;lazy shortcut alert!
					       (t (html-build value)))))
			     attributes))
      :children (list ,@(mapcar #'html-build children)))))

