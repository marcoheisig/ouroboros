(defsystem :ouroboros
  :description "Bringing SBCL to Python and vice versa."
  :author "Marco Heisig <marco@heisig.xyz"
  :license "MIT"
  :depends-on
  ("alexandria"
   "bordeaux-threads"
   "cffi"
   "closer-mop"
   "named-readtables"
   "trivial-garbage")

  :components
  ((:static-file "gencore")
   (:file "packages")
   (:file "pyobject")
   (:file "foreign")
   (:file "bootstrap")
   (:file "generic-functions")
   (:file "mirror-into-lisp")
   (:file "mirror-into-python")
   (:file "high-level")
   (:file "methods")
   (:file "python")
   (:file "convert")
   (:file "lispify")
   (:file "pythonize")
   (:file "ouroboros")))
