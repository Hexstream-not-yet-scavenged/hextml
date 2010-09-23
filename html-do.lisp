(in-package #:hextml_html-do)

(defclass html-do ()
  ((var :initarg :var
	:reader html-do-var)
   (reference :initarg :reference
	      :reader html-do-reference)
   (html :initarg :html
	 :reader html-do-html)))

(defun html-do-p (candidate)
  (typep candidate 'html-do))

(defun make-html-do (var reference html)
  (make-instance 'html-do :var var :reference reference :html html))
