(in-package #:hextml_html-id)

(defclass html-id ()
  ((id :reader html-id-id)))

(defmethod initialize-instance :before ((html-id html-id) &key id)
  (setf (slot-value html-id 'id)
	(html-id-canonicalize id)))

(defmethod print-object ((html-id html-id) stream)
  (print-unreadable-object (html-id stream :type t)
    (prin1 (html-id-id html-id) stream)))

(defun make-html-id (id)
  (make-instance 'html-id :id id))

(defun html-id-p (candidate)
  (typep candidate 'html-id))

(defun html-id= (first second)
  (equal (html-id-canonicalize first)
	 (html-id-canonicalize second)))

(defun html-id-concatenate (&rest ids)
  (if ids
      (labels ((recurse (ids)
		 (if ids
		     (let ((id (car ids)))
		       (etypecase id
			 (html-id (nconc (recurse (html-id-id id)) (recurse (cdr ids))))
			 ((or string integer) (cons id (recurse (cdr ids))))
			 (cons (nconc (recurse id) (recurse (cdr ids)))))))))
	(let ((result (if (cdr ids)
			  (recurse ids)
			  (let ((id (car ids)))
			    (if (html-id-p id)
				(list (html-id-id id))
				(recurse ids))))))
	  (if (cdr result)
	      result
	      (car result))))
      (error "Must concatenate at least 1 id.")))

(defun html-id-canonicalize (id)
  (html-id-concatenate id))

(defun html-id-to-string (id)
  (let ((id (if (html-id-p id)
		(html-id-id id)
		id)))
    (etypecase id
      (string id)
      (cons (with-output-to-string (string)
	      (iter (for part in id)
		    (if (not (first-time-p))
			(write-char #\_ string))
		    (etypecase part
		      (string (write-string part string))
		      (integer (princ part string))
		      (cons (iter (for subscript in part)
				  (if (not (first-time-p))
				      (write-char #\_ string))
				  (princ subscript string))))))))))