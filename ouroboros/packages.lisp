(cl:in-package #:cl-user)

(defpackage #:ouroboros
  (:use #:closer-common-lisp)
  (:export))

(defpackage #:python
  (:use)
  (:export
   ;; Python Syntax
   "SYNTAX"
   "and"
   ;; "as"
   "assert"
   "async"
   "await"
   "break"
   "case"
   "class"
   "continue"
   "def"
   "del"
   ;; "elif"
   ;; "else"
   ;; "except"
   ;; "finally"
   "for"
   ;; "from"
   ;; "global"
   "if"
   "import"
   "import-from" ;; newly introduced
   "in"
   "is"
   "lambda"
   "let" ;; newly introduced
   "match"
   ;; "nonlocal"
   "not"
   "or"
   "pass"
   "raise"
   "return"
   "try"
   "while"
   "with"
   "yield"
   "..."
   "_"
   "__debug__"
   ;; Built-in Constants
   "False"
   "True"
   "None"
   "NotImplemented"
   "Ellipsis"
   ;; Operators
   "+"
   "-"
   "*"
   "**"
   "/"
   "//"
   "%"
   "@"
   "<<"
   ">>"
   "&"
   "|"
   "^"
   "~"
   ":="
   "<"
   ">"
   "<="
   ">="
   "=="
   "!="
   ;; Operator Macros
   "+="
   "-="
   "*="
   "/="
   "//="
   "%="
   "@="
   "&="
   "|="
   "^="
   ">>="
   "<<="
   "**="
   ;; Built-in Functions
   "abs"
   "aiter"
   "all"
   "anext"
   "any"
   "ascii"
   "bin"
   "bool"
   "breakpoint"
   "bytearray"
   "bytes"
   "callable"
   "chr"
   "classmethod"
   "compile"
   "complex"
   "delattr"
   "dict"
   "dir"
   "divmod"
   "enumerate"
   "eval"
   "exec"
   "filter"
   "float"
   "format"
   "frozenset"
   "getattr"
   "globals"
   "hasattr"
   "hash"
   "help"
   "hex"
   "id"
   "input"
   "int"
   "isinstance"
   "issubclass"
   "iter"
   "len"
   "list"
   "locals"
   "map"
   "max"
   "memoryview"
   "min"
   "next"
   "object"
   "oct"
   "open"
   "ord"
   "pow"
   "print"
   "property"
   "range"
   "repr"
   "reversed"
   "round"
   "set"
   "setattr"
   "slice"
   "sorted"
   "staticmethod"
   "str"
   "sum"
   "super"
   "tuple"
   "type"
   "vars"
   "zip"
   "__import__"
   ))
