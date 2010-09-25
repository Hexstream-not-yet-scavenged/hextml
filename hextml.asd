;;;; -*- mode: lisp -*-

(in-package #:cl-user)
(defpackage #:hextml.system
  (:use #:cl #:asdf))
(in-package #:hextml.system)


(defsystem hextml
  :author "Hexstream"
  :depends-on (iterate
	       com.hexstreamsoft.lib
	       com.hexstreamsoft.lib.shared-html-css
	       hexttp-config
	       defmacro-system
	       puri)
  :components ((:file "package")
	       (:file "annotation" :depends-on (package))
	       (:file "html-node" :depends-on (package))
	       (:file "html-id" :depends-on (package))
	       (:file "html-if" :depends-on (package))
	       (:file "html-do" :depends-on (package))
	       (:file "var-finder" :depends-on (package html-node html-if html-do))
	       (:file "parse" :depends-on (package html-node))
	       (:file "hextml-macro" :depends-on (package))
	       (:file "hextml-macro-declaration" :depends-on (package html-node html-id html-if html-do hextml-macro))
	       (:file "build" :depends-on (package html-node parse
						   hextml-macro hextml-macro-declaration))
	       (:file "output" :depends-on (package html-node parse
						   hextml-macro hextml-macro-declaration))
	       (:file "rewrite" :depends-on (package annotation html-node html-if html-do))
	       (:file "resolve" :depends-on (package html-node rewrite html-if html-do))
	       (:file "optimize" :depends-on (package annotation html-node html-id html-if html-do))
	       (:file "render" :depends-on (package annotation html-node html-id html-if html-do))
	       (:file "compile" :depends-on (package annotation html-node html-id html-if html-do render))
	       (:file "load" :depends-on (package build))))
