;;;; -*- mode: lisp -*-

(in-package #:cl-user)
(defpackage #:hextml-test.system
  (:use #:cl #:asdf))
(in-package #:hextml-test.system)


(defsystem hextml-test
  :author "Hexstream"
  :depends-on (cl-hexstream
	       hextest
	       hextml)
  :components ((:file "package")
	       (:file "main" :depends-on (package))))
