(in-package #:ouroboros.internals)

(defmacro define-pycallable (name lambda-list)
  `(progn
     (defgeneric ,name ,lambda-list
       (:generic-function-class lispifying-generic-function))
     (cffi:defcallback ,name pyobject
         ,(loop for item in lambda-list
                collect
                `(,item pyobject))
       (mirror-into-python
        (,name
         ,@(loop for item in lambda-list
                 collect
                 `(mirror-into-lisp ,item)))))))

(define-pycallable __repr__ (object))

(define-pycallable __str__ (object))

;;; Comparisons

(defgeneric __lt__ (object-1 object-2)
  (:generic-function-class lispifying-generic-function))

(defgeneric __le__ (object-1 object-2)
  (:generic-function-class lispifying-generic-function))

(defgeneric __eq__ (object-1 object-2)
  (:generic-function-class lispifying-generic-function))

(defgeneric __ne__ (object-1 object-2)
  (:generic-function-class lispifying-generic-function))

(defgeneric __gt__ (object-1 object-2)
  (:generic-function-class lispifying-generic-function))

(defgeneric __ge__ (object-1 object-2)
  (:generic-function-class lispifying-generic-function))

(defgeneric __hash__ (object)
  (:generic-function-class lispifying-generic-function))

(cffi:defcallback __hash__ :uint
    ((object pyobject))
  (__hash__ (mirror-into-lisp object)))

(cffi:defcallback __richcmp__ pyobject
    ((o1 pyobject)
     (o2 pyobject)
     (cmp :int))
  (let ((a (mirror-into-lisp o1))
        (b (mirror-into-lisp o2)))
    (ecase cmp
      (0 (__lt__ a b))
      (1 (__le__ a b))
      (2 (__eq__ a b))
      (3 (__ne__ a b))
      (4 (__gt__ a b))
      (5 (__ge__ a b)))))

;;; Sequence and Mapping Methods

(defgeneric __len__ (object)
  (:generic-function-class lispifying-generic-function))

(cffi:defcallback __len__ :ssize
    ((pyobject pyobject))
  (__len__ (mirror-into-lisp pyobject)))

(define-pycallable __getitem__ (object key))

(cffi:defcallback __sq_getitem__ :pointer
    ((pyobject pyobject)
     (index :ssize))
  (handler-case
      (mirror-into-python
       (__getitem__ (mirror-into-lisp pyobject) index))
    ((or #-sbcl type-error
         #+sbcl sb-kernel:index-too-large-error
         sb-int:invalid-array-index-error)
      ()
      (with-global-interpreter-lock-held
        (pyerr-set-none (mirror-into-python (find-class 'python:index-error)))
        (cffi:null-pointer)))))

(define-pycallable __setitem__ (object index value))

(cffi:defcallback __setitem__ :int
    ((pyobject pyobject)
     (pyindex pyobject)
     (pyvalue pyobject))
  (__setitem__ (mirror-into-lisp pyobject)
               (mirror-into-lisp pyindex)
               (mirror-into-lisp pyvalue))
  (values 0))

(cffi:defcallback __sq_setitem__ :int
    ((pyobject pyobject)
     (index :ssize)
     (pyvalue pyobject))
  (__setitem__ (mirror-into-lisp pyobject)
               index
               (mirror-into-lisp pyvalue))
  (values 0))

(defgeneric __contains__ (object value)
  (:generic-function-class lispifying-generic-function))

(cffi:defcallback __contains__ :bool
    ((pyobject pyobject)
     (pyvalue pyobject))
  (__contains__ (mirror-into-lisp pyobject)
                (mirror-into-lisp pyvalue)))

;;; Number Methods

(define-pycallable __abs__ (object))

(define-pycallable __add__ (object-1 object-2))

(define-pycallable __and__ (object-1 object-2))

(defgeneric __bool__ (object)
  (:generic-function-class lispifying-generic-function))

(cffi:defcallback __bool__ :bool
    ((object pyobject))
  (__bool__ (mirror-into-lisp object)))

(define-pycallable __divmod__ (object-1 object-2))

(define-pycallable __float__ (object))

(define-pycallable __floordiv__ (object-1 object-2))

(define-pycallable __index__ (object))

(define-pycallable __iadd__ (object-1 object-2))

(define-pycallable __iand__ (object-1 object-2))

(define-pycallable __ifloordiv__ (object-1 object-2))

(define-pycallable __ilshift__ (object-1 object-2))

(define-pycallable __imul__ (object-1 object-2))

(define-pycallable __ior__ (object-1 object-2))

(define-pycallable __ipow__ (object-1 object-2 object-3))

(define-pycallable __imod__ (object-1 object-2))

(define-pycallable __irshift__ (object-1 object-2))

(define-pycallable __isub__ (object-1 object-2))

(define-pycallable __itruediv__ (object-1 object-2))

(define-pycallable __ixor__ (object-1 object-2))

(define-pycallable __int__ (object))

(define-pycallable __invert__ (object))

(define-pycallable __lshift__ (object-1 object-2))

(define-pycallable __mul__ (object-1 object-2))

(define-pycallable __neg__ (object))

(define-pycallable __or__ (object-1 object-2))

(define-pycallable __pos__ (object))

(define-pycallable __pow__ (object-1 object-2 object-3))

(define-pycallable __mod__ (object-1 object-2))

(define-pycallable __rshift__ (object-1 object-2))

(define-pycallable __sub__ (object-1 object-2))

(define-pycallable __truediv__ (object-1 object-2))

(define-pycallable __xor__ (object-1 object-2))
