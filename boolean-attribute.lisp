(in-package #:hextml_html-node)

(defclass boolean-attribute ()
  ((attribute :initarg :attribute
	      :reader boolean-attribute-attribute
	      :type string)
   (value :initarg :value
	  :reader boolean-attribute-value
	  :initform nil)
   (ref :initarg :ref
	:reader boolean-attribute-ref)))

(define-type-predicate boolean-attribute)

(defmethod shared-initialize :before ((boolean boolean-attribute) slot-names
				      &key attribute (value nil value-supplied-p))
  (check-type attribute string)
  (if value-supplied-p
      (check-type value (or null string))))

(defmethod print-object ((boolean boolean-attribute) stream)
  (print-unreadable-object (boolean stream :type t)
    (format stream "~A if ~A~@[ contains ~A~]"
	    (boolean-attribute-attribute boolean)
	    (boolean-attribute-ref boolean)
	    (boolean-attribute-value boolean))))