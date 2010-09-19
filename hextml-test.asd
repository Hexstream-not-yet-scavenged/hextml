;;;; -*- mode: lisp -*-

(in-package #:cl-user)
(defpackage #:hextml-test.system
  (:use #:cl #:asdf))
(in-package #:hextml-test.system)


(defsystem hextml-test
  :author "Hexstream"
  :depends-on (cl-hexstream
	       hextml)
  :components ((:file "package")
	       (:file "output" :depends-on (package))))
