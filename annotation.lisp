(in-package #:hextml_annotation)

(defclass hextml-annotation ()
  ((target :initarg :target
	   :reader hextml-annotation-target
	   :initform (error "annotation target required"))))

(define-type-predicate hextml-annotation)

(defun make-hextml-annotation (target)
  (make-instance 'hextml-annotation :target target))

(defmethod print-object ((annotation hextml-annotation) stream)
  (write (hextml-annotation-target annotation) :stream stream))