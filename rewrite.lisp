(in-package #:hextml)

(defvar *html-context* nil)

(defclass html-rewriter ()
  ())

(defun rewrite-list (rewriter list)
  (mapcar (fmask #'html-rewrite ? (rewriter ?))
	  list))

(defun rewrite-html (rewriter element)
  (let ((*html-context* *html-context*))
    (html-rewrite rewriter element)))

(defgeneric html-rewrite (rewriter element))

(defmethod html-rewrite ((rewriter html-rewriter) anything)
  anything)

(defmethod html-rewrite ((rewriter html-rewriter) (annotation hextml-annotation))
  (make-hextml-annotation (html-rewrite rewriter (hextml-annotation-target annotation))))

(defmethod html-rewrite ((rewriter html-rewriter) (node html-node))
  (with-html-node-readers () node
    (let ((*html-context* (push node *html-context*)))
      (make-instance 'html-node
		     :type (html-rewrite rewriter type)
		     :attributes (loop for (attribute . value) in attributes
				       collect (cons attribute
						     (html-rewrite rewriter value)))
		     :children (rewrite-list rewriter children)))))

(defmethod html-rewrite ((rewriter html-rewriter) (list list))
  (rewrite-list rewriter list))

(defmethod html-rewrite ((rewriter html-rewriter) (html html-if))
  (make-html-if (html-if-condition html)
		(rewrite-html rewriter (html-if-then html))
		(rewrite-html rewriter (html-if-else html))))

(defmethod html-rewrite ((rewriter html-rewriter) (html html-do))
  (make-html-do (html-do-var html)
		(html-do-reference html)
		(rewrite-html rewriter (html-do-html html))))
