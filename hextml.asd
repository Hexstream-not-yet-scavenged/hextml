(asdf:defsystem #:hextml

  :author "Jean-Philippe Paradis <hexstream@gmail.com>"

  ;; See the UNLICENSE file for details.
  :license "Public Domain"

  :description "This library makes it easy to build a representation of HTML as lisp objects, which you can then inspect/transform/output. There is an included optimizer and compiler which produces highly efficient code. A lot of code which would normally be considered \"dynamic\" is treated as if it was \"static\" (ex: basic branching and looping)."

  :depends-on (#:com.hexstreamsoft.lib
	       #:com.hexstreamsoft.lib.shared-html-css
	       #:hexttp-config
	       #:defmacro-system
	       #:puri)

  :version "0.1"
  :serial cl:t
  :components ((:file "package")
	       (:file "annotation")
               (:file "html-node")
               (:file "html-id")
               (:file "html-if")
               (:file "html-do")
               (:file "var-finder")
               (:file "parse")
               (:file "hextml-macro")
               (:file "hextml-macro-declaration")
               (:file "build")
               (:file "output")
               (:file "rewrite")
               (:file "resolve")
               (:file "optimize")
               (:file "render")
               (:file "compile")
               (:file "load")))
