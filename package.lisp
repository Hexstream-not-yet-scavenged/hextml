(in-package #:cl-user)

(defpackage #:hextml_annotation
  (:use #:cl
	#:com.hexstreamsoft.lib)
  (:export #:hextml-annotation
	   #:hextml-annotation-target
	   #:make-hextml-annotation
	   #:hextml-annotation-p))

(defpackage #:hextml_html-node
  (:use #:cl
	#:com.hexstreamsoft.lib)
  (:export #:html-node
	   #:html-node-type
	   #:html-node-attributes
	   #:html-node-children
	   #:html-node-p
	   #:make-html-node
	   #:with-html-node-readers))

(defpackage #:hextml_html-id
  (:use #:cl
	#:com.hexstreamsoft.lib)
  (:export #:html-id
	   #:html-id-id
	   #:make-html-id
	   #:html-id-p
	   #:html-id=
	   #:html-id-concatenate
	   #:html-id-canonicalize
	   #:html-id-to-string))

(defpackage #:hextml_html-if
  (:use #:cl
	#:com.hexstreamsoft.lib
	#:com.hexstreamsoft.lib.shared-html-css
	#:hexttp-config)
  (:export #:html-if
	   #:html-if-condition
	   #:html-if-then
	   #:html-if-else
	   #:html-if-p
	   #:make-html-if
	   #:all-eq
	   #:eval-html-if-condition
	   #:transform-html-if))

(defpackage #:hextml_html-do
  (:use #:cl
	#:com.hexstreamsoft.lib
	#:com.hexstreamsoft.lib.shared-html-css
	#:hexttp-config)
  (:export #:html-do
	   #:html-do-var
	   #:html-do-reference
	   #:html-do-html
	   #:html-do-p
	   #:make-html-do))

(defpackage #:hextml_var-finder
  (:use #:cl
	#:com.hexstreamsoft.lib
	#:com.hexstreamsoft.lib.shared-html-css
	#:hextml_html-node
	#:hextml_html-if
	#:hextml_html-do)
  (:export #:find-vars
	   #:vars-find))

(defpackage #:hextml_front
  (:use #:cl
	#:com.hexstreamsoft.lib
	#:com.hexstreamsoft.lib.shared-html-css
	#:hextml_html-node
	#:hextml_html-id
	#:hextml_html-if
	#:hextml_html-do
	#:defmacro-system)
  (:export #:*hextml-stream*
	   #:define-hextml-macro
	   #:hextml-macroexpand-1
	   #:html-noprocess
	   #:html-if
	   #:html-when
	   #:html-unless
	   #:html-cond
	   #:declare-html-noprocess
	   #:tag
	   #:env
	   #:html-dyn
     
	   #:build-html
	   #:html-build
	   
	   #:output-html))

(defpackage #:hextml_rewrite
  (:use #:cl
	#:com.hexstreamsoft.lib
	#:hextml_annotation
	#:hextml_html-node
	#:hextml_html-if
	#:hextml_html-do)
  (:export #:*html-context*
	   #:html-rewriter
	   #:rewrite-html
	   #:html-rewrite))

(defpackage #:hextml_resolve
  (:use #:cl
	#:com.hexstreamsoft.lib
	#:com.hexstreamsoft.lib.shared-html-css
	#:hextml_rewrite
	#:hextml_html-node
	#:hextml_html-if
	#:hextml_html-do
	#:puri)
  (:export #:html-resolver))

(defpackage #:hextml_optimize
  (:use #:cl
	#:com.hexstreamsoft.lib
	#:com.hexstreamsoft.lib.shared-html-css
	#:hexttp-config
	#:puri
	#:hextml_annotation
	#:hextml_html-node
	#:hextml_html-id
	#:hextml_html-if
	#:hextml_html-do)
  (:export #:html-optimizer
	   #:optimize-html
	   #:html-optimize
	   #:html-optimize-attribute-value))

(defpackage #:hextml_render
  (:use #:cl
	#:com.hexstreamsoft.lib
	#:com.hexstreamsoft.lib.shared-html-css
	#:hexttp-config
	#:hextml_annotation
	#:hextml_html-node
	#:hextml_html-id
	#:hextml_html-if
	#:hextml_html-do
	#:puri)
  (:export #:*prologue*
	   #:html-renderer
	   #:render-html
	   #:render-html-to-string
	   #:html-render))

(defpackage #:hextml_compile
  (:use #:cl
	#:com.hexstreamsoft.lib
	#:com.hexstreamsoft.lib.shared-html-css
	#:hextml_annotation
	#:hextml_html-node
	#:hextml_html-id
	#:hextml_html-if
	#:hextml_html-do
	#:hextml_render
	#:puri)
  (:export #:html-compiler
	   #:compile-html
	   #:html-compile))

(defpackage #:hextml_elements
  (:use #:cl
	#:com.hexstreamsoft.lib
	#:com.hexstreamsoft.lib.shared-html-css)
  (:export #:template-env
	   #:template-env-reference
	   #:template-env-reference-key
	   #:template-env-reference-resolve-when
	   #:resolve-template-env-reference
	   #:template-env-reference-to-id
	   #:template-env-reference-concatenate

	   #:template-env-subreference-marker
	   #:template-env-subreference-marker-target
	   #:template-env-subreference
	   #:template-env-subreference-key
	   #:template-env-subreference-template
	   #:make-template-env-subreference))

(defpackage #:hextml_load
  (:use #:cl
	#:com.hexstreamsoft.lib
	#:hextml_front)
  (:export #:load-i18n-file))

(com.hexstreamsoft.lib:define-grouping-package #:hextml
    (#:hextml_html-node
     #:hextml_html-id
     #:hextml_html-if
     #:hextml_html-do
     #:hextml_var-finder
     #:hextml_front
     #:hextml_rewrite
     #:hextml_resolve
     #:hextml_optimize
     #:hextml_render
     #:hextml_compile
     #:hextml_elements
     #:hextml_load))
