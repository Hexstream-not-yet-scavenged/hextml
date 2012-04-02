(cl:defpackage #:hextml
  (:use #:cl
        #:com.hexstreamsoft.lib
        #:com.hexstreamsoft.lib.shared-html-css
        #:hexttp-config
        #:puri)
  (:export #:hextml-annotation
	   #:hextml-annotation-target
	   #:make-hextml-annotation
	   #:hextml-annotation-p

           #:html-node
	   #:html-node-type
	   #:html-node-attributes
	   #:html-node-children
	   #:html-node-p
	   #:make-html-node
	   #:with-html-node-readers

           #:html-id
	   #:html-id-id
	   #:make-html-id
	   #:html-id-p
	   #:html-id=
	   #:html-id-concatenate
	   #:html-id-canonicalize
	   #:html-id-to-string

           #:html-if
	   #:html-if-condition
	   #:html-if-then
	   #:html-if-else
	   #:html-if-p
	   #:make-html-if
	   #:all-eq
	   #:eval-html-if-condition
	   #:transform-html-if

           #:html-do
	   #:html-do-var
	   #:html-do-reference
	   #:html-do-html
	   #:html-do-p
	   #:make-html-do

           #:find-vars
	   #:vars-find

           #:*hextml-stream*
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
	   #:output-html

           #:*html-context*
	   #:html-rewriter
	   #:rewrite-html
	   #:html-rewrite

           #:html-resolver

           #:html-optimizer
	   #:optimize-html
	   #:html-optimize
	   #:html-optimize-attribute-value

           #:*prologue*
	   #:html-renderer
	   #:render-html
	   #:render-html-to-string
	   #:html-render

           #:html-compiler
	   #:compile-html
	   #:html-compile

           #:template-env
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
	   #:make-template-env-subreference

           #:load-i18n-file))
