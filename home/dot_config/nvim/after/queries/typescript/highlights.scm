; extends

;; const foo = 1
(lexical_declaration
  "const"
  (variable_declarator
    name: (identifier) @variable.const)
  (#set! "priority" 125))

;; const { a, b: c, ...rest } = obj
(lexical_declaration
  "const"
  (variable_declarator
    name: (object_pattern
      (shorthand_property_identifier_pattern) @variable.const
      (pair_pattern
        value: (identifier) @variable.const)?
      (rest_pattern
        (identifier) @variable.const)?))
  (#set! "priority" 125))

;; const [a, b = 1, ...rest] = arr
(lexical_declaration
  "const"
  (variable_declarator
    name: (array_pattern
      (identifier) @variable.const
      (assignment_pattern
        left: (identifier) @variable.const)?
      (rest_pattern
        (identifier) @variable.const)?))
  (#set! "priority" 125))
