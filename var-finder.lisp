(in-package #:hextml_var-finder)

(defun find-vars (html)
  (delete-duplicates (vars-find html)
		     :test #'equal))

(defgeneric vars-find (html)
  (:documentation "Returns a fresh list of vars"))

(defmethod vars-find (anything)
  nil)

(defmethod vars-find ((html html-node))
  (nconc (vars-find (mapcar #'cdr (html-node-attributes html)))
	 (mapcan #'vars-find (html-node-children html))))

(defun vars-find-html-if-condition (condition)
  (etypecase condition
    (atom nil)
    ((cons (eql env)) (list (second condition)))
    ((cons (eql funcall)) (vars-find-html-if-condition (second condition)))
    (cons (mapcan #'vars-find-html-if-condition (cdr condition)))))

(defmethod vars-find ((html html-if))
  (nconc (vars-find-html-if-condition (html-if-condition html))
	 (vars-find (html-if-then html))
	 (vars-find (html-if-else html))))

(defmethod vars-find ((html html-do))
  (nconc (list (html-do-reference html))
	 (delete (html-do-var html)
		 (vars-find (html-do-html html))
		 :test #'equal)))

(defmethod vars-find ((html list))
  (mapcan #'vars-find html))

(defmethod vars-find ((ref template-env-reference))
  (list (template-env-reference-key ref)))
