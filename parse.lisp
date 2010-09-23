(in-package #:hextml_front)

(defun form-with-operator-p (form operator)
  (and (consp form)
       (eq (first form) operator)))

(defun output-html-form-p (form)
  (form-with-operator-p form 'output-html))

(defun build-html-form-p (form)
  (form-with-operator-p form 'build-html))

(defun noprocess-form-p (form)
  (form-with-operator-p form 'html-noprocess))

(defun html-node-form-p (form)
  (and (consp form)
       (keywordp (first form))))

(defun tag-form-p (form)
  (form-with-operator-p form 'tag))

(let ((case-lookup-hack (insert-alist-into-hash '(("viewbox" . "viewBox")
						  ("fullprofile" . "fullProfile")
						  ("textpath" . "textPath")
						  ("clippath" . "clipPath")
						  ("preserveaspectratio" . "preserveAspectRatio"))
						(make-hash-table :test 'equal))))
  (defun canonicalize-to-string (thing)
    (typecase thing
      (string thing)
      ((satisfies keywordp)
       (let ((downcased (string-downcase (symbol-name thing))))
	 (or (gethash downcased case-lookup-hack)
	     downcased)))
      (t thing))))

(defun destructure-html-node-form (form)
  "Returns as 3 values the html-node type as keyword, attributes as alist and body as list"
  (loop with type = (canonicalize-to-string (first form))
	for cons on (rest form) by #'cddr
	for attribute-or-body = (car cons)
	while (or (keywordp attribute-or-body)
		  (eq attribute-or-body 'quote))
	  collect (cons (canonicalize-to-string (first cons))
			(canonicalize-to-string (second cons))) into attributes
	finally (return (values type attributes cons))))
