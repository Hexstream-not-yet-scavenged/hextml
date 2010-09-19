(in-package #:hextml-test)

#+nil(defmacro define-html-test (name (stream-var &rest rest)
			    output-form build-form output-expected)
  (if (eq build-form :same)
      (setf build-form output-form))
  (let ((name (hextest-extend-name '#:html_ name)))
    (once-only (output-expected)
      `(deftest ,name ,rest
	 (hextest-assert (string= (with-output-to-string (,stream-var)
				    (output-html (,stream-var)
				      ,output-form))
				  ,output-expected))
	 ,@(if (not (eq build-form :skip))
	       (list `(hextest-assert (string= (with-output-to-string (,stream-var)
						 (render-html (make-instance 'html-renderer)
							      (build-html
								,build-form)
							      ,stream-var))
					       ,output-expected))))
	 (hextest-assert (string= ))))))

#+nil(define-multidef-macro define-html-tests (stream-var &rest rest)
    (definitions (name output-form build-form build-expected output-expected))
  `(progn ,@(definitions `(define-html-test ,name (,stream-var ,@rest)
			    ,output-form ,build-form ,build-expected ,output-expected))))

#+nil(define-html-tests (stream)
    (code (dotimes (i 3)
	    (princ i stream))
	  :skip
	  "012")
  (nothing nil nil "")
  (text "Trivial." :same
	"Trivial.")
  (empty-tag (:test) :same
	     "<test />")
  (empty-string-tag (:test "") :same
		    "<test></test>")
  (tag-and-text (:tag "Text") :same
		"<tag>Text</tag>")
  (parent-and-child (:parent (:child "Nesting test.")) :same
		    "<parent><child>Nesting test.</child></parent>")
  ((parent-and-children parent-and-child)
   (:parent (:child1 "Child1 text.")
	    (:child2 "Child2 text.")
	    (:child3 "Child3 text.")) :same
   "<parent><child1>Child1 text.</child1><child2>Child2 text.</child2><child3>Child3 text.</child3></parent>")
  #+nil((bof code)
	(:top-level :tl-attribute "tl-value"
		    (:nested :nested-attribute "nested-attribute-value"
			     "Nested First"
			     "Nested Second"
			     (iter (for i below 3)
				   (collect (:surprise (princ i stream))))
			     (:nested-again))
		    "Some Text."
		    (:br))
	"LOL"))