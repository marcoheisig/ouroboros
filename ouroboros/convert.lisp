(in-package #:ouroboros)

(defgeneric convert (object strategy)
  (:argument-precedence-order strategy object)
  (:documentation
   "Converts the supplied object using some strategy.  The strategy should be an
instance of a class that describes the exact nature of the conversion, or the
name of such a class.")
  (:method (object strategy)
    (convert-object strategy object))
  (:method (object (strategy symbol))
    (convert object (make-instance strategy))))

(defgeneric convert-object-to-dummy (strategy object)
  (:documentation
   "Converts the supplied object to a dummy object whose slots need not be
converted further.  Used to temporarily fill slots that contain a circular
reference.")
  (:method (strategy object)
    '.dummy-object.))

(defgeneric convert-slot (strategy object slot-specifier slot-value)
  (:documentation
   "Converts the value of the specified slot of the supplied object.  In case the
slot contains a circular reference, returns the result of a call to
CONVERT-OBJECT-TO-DUMMY and arranges that a suitable slot update is later
passed to FINALIZE-CONVERSION."))

(defgeneric register-converted-object (strategy object conversion)
  (:documentation
   "Declare that the conversion of the supplied object is known, although possibly
not yet fully initialized.  Registering a converted object this way before
converting its slots allows for more efficient handling of circularities.")
  (:method (strategy object conversion)
    (values)))

(defgeneric finalize-conversion (strategy object converted-object slot-updates)
  (:documentation
   "Apply the specified slot updates in such a way that each
specified slot of the converted object holds the converted slot value.  This
generic function is invoked whenever an object contains at least one unresolved
circular reference."))

(defgeneric slot-update-original-value (slot-update)
  (:documentation
   "The object that used to be stored in that slot and that ought to be converted."))

(defgeneric slot-update-converted-value (slot-update)
  (:documentation
   "The value of that slot after conversion."))

(defgeneric slot-update-specifier (slot-update)
  (:documentation
   "An arbitrary object that describes the slot that is to be updated to the
slot update's converted value."))

(defclass slot-update ()
  ((%original-value
    :initarg :original-value
    :initform (alexandria:required-argument :original-value)
    :reader slot-update-original-value)
   (%converted-value
    :accessor slot-update-converted-value)
   (%specifier
    :initarg :specifier
    :initform (alexandria:required-argument :speficier)
    :reader slot-update-specifier)))

;;; Convert Once

(defclass convert-once ()
  ()
  (:documentation
   "Convert the supplied object, but don't convert any of its slots."))

(defmethod convert-slot
    (strategy object slot-specifier slot-value)
  slot-value)

;;; Convert Tree

(defclass convert-tree ()
  ()
  (:documentation
   "Convert the supplied object, its slots, and the slots thereof, but don't
check for circularity or multiply referenced objects."))

(defmethod convert-slot
    ((strategy convert-tree) object slot-specifier slot-value)
  (declare (ignore object slot-specifier))
  (convert-object strategy slot-value))

;;; Convert Graph

(defclass convert-graph ()
  ()
  (:documentation
   "Convert the supplied object and its children in a way that properly handles
 circularity and multiply referenced objects."))

(defvar *convert-graph-conversion-in-progress-marker* nil
  "An opaque object that is used for marking a conversion that is still in
process.")

(defvar *convert-graph-table* nil
  "A hash table, mapping from objects to either the conversion-in-progress marker
or the result of the conversion.")

(defvar *convert-graph-slot-updates* nil
  "A hash table, mapping from not-yet-finalized objects to their list of pending
slot updates.")

(defmethod convert :around
    (object (strategy convert-graph))
  (let ((*convert-graph-conversion-in-progress-marker* (list '.conversion-in-progress.))
        (*convert-graph-table* (make-hash-table :test #'eq))
        (*convert-graph-slot-updates* (make-hash-table :test #'eq)))
    (call-next-method)))

(defmethod convert :after
    (object (strategy convert-graph))
  (declare (ignore object))
  (maphash
   (lambda (object slot-updates)
     ;; Look up the converted value of the object being finalized.
     (multiple-value-bind (converted-object presentp)
         (gethash object *convert-graph-table*)
       (when (not presentp)
         (error "Attempting to update an object that has never been converted."))
       ;; Determine the converted value of each slot update instance.
       (dolist (slot-update slot-updates)
         (multiple-value-bind (converted-value presentp)
             (gethash (slot-update-original-value slot-udpate)
                      *convert-graph-table*)
           (when (not presentp)
             (error "Attempting to update a slot that has never been converted."))
           (setf (slot-update-converted-value slot-update)
                 converted-value)))
       ;; Finalize the object.
       (finalize-conversion strategy object converted-object slot-updates)))
   *convert-graph-slot-updates*))

(defmethod convert-object :before
    ((strategy convert-graph) object)
  (setf (gethash object *convert-graph-table*)
        *convert-graph-conversion-in-progress-marker*))

(defmethod convert-object :around
    ((strategy convert-graph) object)
  (let ((converted-object (call-next-method)))
    (register-converted-object strategy object converted-object)
    converted-object))

(defmethod convert-slot
    ((strategy convert-graph)
     object
     slot-specifier
     slot-value)
  (multiple-value-bind (converted presentp)
      (gethash value *convert-graph-table*)
    (cond
      ;; If there is no cache entry, convert it and then update the table to
      ;; the result of the conversion.
      ((not presentp)
       (convert-object strategy value))
      ;; If the child is already being converted, we are dealing with a
      ;; circular reference.  If so, return a dummy object for now and ensure
      ;; that slot is being patched later.
      ((eq converted *convert-graph-conversion-in-progress-marker*)
       (push (make-instance 'slot-update
               :original-value slot-value
               :specifier slot-specifier)
             (gethash object *convert-graph-slot-updates* '()))
       (convert-object-to-dummy strategy slot-value))
      ;; Otherwise the object has already been converted and we can simply
      ;; return the result of that conversion.
      (t value))))

(defmethod register-converted-object
    ((strategy convert-graph) object conversion)
  (setf (gethash object *convert-graph-table*)
        conversion))

(defmethod finalize-conversion
    ((strategy convert-graph) object converted-object slot-updates)
  (error "Don't know how to finalize ~S in this context."
         converted-object))
