(in-package #:hextml)

(defclass html-if ()
  ((condition :reader html-if-condition)
   (then :initarg :then
	 :reader html-if-then)
   (else :initarg :else
	 :reader html-if-else
	 :initform nil)))

(defmethod shared-initialize :after ((html html-if) slot-names &key condition)
  (setf (slot-value html 'condition) (build-html-if-condition condition)))

(defmethod print-object ((html html-if) stream)
  (print-unreadable-object (html stream :type t)
    (format stream "if ~S then ~S else ~S"
	    (html-if-condition html) (html-if-then html) (html-if-else html))))

(defun make-html-if (condition then &optional else)
  (make-instance 'html-if :condition condition :then then :else else))

(defun html-if-p (object)
  (typep object 'html-if))

(defun all-eq (&rest list)
  (let ((first (first list)))
    (loop for arg in (cdr list)
	  always (eql arg first))))

(defun args-type (args default)
  (let ((types (remove nil (mapcar #'arg-type args))))
    (if types
	(if (apply #'all-eq types)
	    (car types)
	    (error "Type incompatibility: ~S." (mapcar #'cons args (mapcar #'arg-type args))))
	(or default
	    (error "Couldn't determine args-type of args ~S." args)))))

(defun arg-type (arg)
  (typecase arg
    ((or string number) nil)
    (symbol (error "symbols as variables no longer supported in html-if conditions."))
    ((cons (eql env))
     (let ((key (second arg)))
       (if (stringp key)
	   (cdr (assoc key '(("access" . access) ("lang" . lang))
		       :test #'string=)))))
    (access 'access)
    (lang 'lang)
    (t t)))

(defun real-operator (operator args-type)
  (if (and (consp operator)
	   (eq (car operator) 'access))
      operator
      (ecase operator
	(= operator)
	((< <= >= >) (case args-type
		       (access `(access ,operator))
		       (integer operator)
		       (t (error "< <= >= > expect access args-type in html-if condition, not ~S."
				 args-type)))))))

(defun instantiate-arg-from-type (literal type)
  (if (stringp literal)
      (ecase type
	(lang (find-lang literal *config*))
	(access (find-access literal *config*)))
      literal))

(defun build-html-if-condition (condition)
  (etypecase condition
    ((or (and atom (or (not symbol) boolean)) (cons (or (eql env) (eql funcall))))
     condition)
    (symbol (error "symbols as variables no longer supported in html-if conditions."))
    (cons (let ((operator (car condition))
		(args (cdr condition)))
	    (if (or (functionp operator)
		    (member operator '(and or not string= string)))
		(cons operator (mapcar #'build-html-if-condition args))
		(if (eq operator 'member)
		    `(member ,(first args) ,(build-html-if-condition (second args)))
		    (if (eq operator 'funcall)
			`(funcall ,(first args) ,@(mapcar #'build-html-if-condition (cdr args)))
			(let ((args-type (args-type args (if (member operator '(= < <= >= >))
							     'integer))))
			  (cons (real-operator operator args-type)
				(mapcar (fmask #'instantiate-arg-from-type ? (? args-type))
					args))))))))))

(defun eval-html-if-condition (renderer condition)
  (etypecase condition
    (atom condition)
    (cons (let ((operator (car condition)))
	    (case operator
	      (env (multiple-value-bind (value foundp)
		       (resolve-template-env-reference (second condition)
						       (template-env renderer))
		     (if foundp value)))
	      (funcall (funcall (eval-html-if-condition renderer (second condition))
				(third condition)))
	      (and (loop for stuff in (cdr condition)
		      always (eval-html-if-condition renderer stuff)))
	      (or (loop for stuff in (cdr condition)
		     if (eval-html-if-condition renderer stuff) return t))
	      (not (not (eval-html-if-condition renderer (second condition))))
	      (member (member (second condition)
			      (eval-html-if-condition renderer (third condition))
			      :test #'string=))
	      (string (let* ((result (eval-html-if-condition renderer (second condition)))
			     (result (if (consp result) (car result) result)))
			(etypecase result
			  (string result)
			  (integer (princ-to-string result)))))
	      (t (let ((args (mapcar (fmask #'eval-html-if-condition
					    ? (renderer ?)) (cdr condition))))
		   (if (and (consp operator)
			    (eq (car operator) 'access))
		       (apply #'compare-access (second operator) args)
		       (if (eq operator '=)
			   (apply #'all-eq args)
			   (if (eq operator 'string=)
			       (apply #'string= (if (every #'stringp args)
						    args
						    (mapcar #'princ-to-string args)))
			       (apply operator args)))))))))))

(defun transform-html-if (html-if condition-transform branch-transform)
  (let ((condition (funcall condition-transform (html-if-condition html-if))))
    (flet ((then ()
	     (funcall branch-transform (html-if-then html-if)))
	   (else ()
	     (funcall branch-transform (html-if-else html-if))))
      (case condition
	((t) (then))
	((nil) (else))
	(t (make-html-if condition (then) (else)))))))
