(in-package #:hextml_html-node)

(defclass html-node ()
  ((type :initarg :type
	 :reader html-node-type
	 :type string
	 :initform (error "An html-node must have a type")
	 :documentation "The tag type as a string")
   (attributes :initarg :attributes
	       :reader html-node-attributes
	       :type list
	       :initform nil
	       :documentation "The attributes as an alist of (key . value).")
   (children :initarg :children
	     :reader html-node-children
	     :type list
	     :initform nil)))

(defun make-html-node (type attributes children)
  (make-instance 'html-node :type type :attributes attributes :children children))

(define-with-readers-macro html-node ((type html-node-type)
				      (attributes html-node-attributes)
				      (children html-node-children)))

(define-type-predicate html-node)

(defmethod print-object ((node html-node) stream)
  (print-unreadable-object (node stream)
    (with-html-node-readers () node
			    (write-string "html:" stream)
			    (write-string type stream)
			    (let ((id-cons (or (assoc "id" attributes :test #'string=)
					       (assoc "name" attributes :test #'string=))))
			      (when id-cons
				(write-char #\Space stream)
				(princ (cdr id-cons) stream))))))