# Language

For the Sepro system we propose a domain specific modeling language. The
language convers three aspects of the model: object prototypes, initial graph
structures and simlator or observer related information.

## Model and Model Objects

The model is a list of model objects: symbol definitions, actuators and
structures.

_model_ = { _model_object_ }

_model_object_ = _symbol_definition_ | _unary_actuator_ | _binary_actuator_ | _structure_

## Symbols

The _symbol_ is an identifier that can contain letters, decimal digits or the
underscore `_` character. It can not start with a digit. For example `open`,
`next`, `site_a`, `site_b`.

Each symbol in the model represents an instance of a type. There can be only
one type associated with a symbol within the model. Type of a symbol can be
specified explicitly or is determined by the compiler from the first use of the
symbol in the model. Use of a symbol for different types results in an error.
For example if a symbol is used as a tag it can not be used to label a
relationship between objects.

Examples of explicity symbol definitions:

```sepro
DEF TAG open
DEF TAG closed
DEF SLOT next
DEF SLOT site_a
```

Grammar:

_symbol_definition_ = `"DEF"` _symbol_type_ _symbol_
_symbol_type_ = `"SLOT"` | `"TAG"` | `"STRUCT"` | `"ACTUATOR"`

When an indirect symbol needs to be specified we use the `.` (dot) symbol
qualification:

_qualified_symbol_ = [_symbol_ `"."`] _symbol_


## Structures

Structure is a definition of a group of objects - a subgraph, that can be used
to initialize the world. Structure contains list of objects and bindings (edges).

_struct_ = `"STRUCT"` _symbol_ { _struct_item_ }

_struct_item_ = _object_ | _binding_

Structure objects have identifiers that are valid withing the scope of the
structure. The identifiers are used to refer to objects in the structure
binding specification.

_object_ = `"OBJ"` _symbol_ `"("` { _symbol_ } `")"`

The bindings within structure can refer to objects within the same structure:

_binding_ = `"BIND"` _symbol_ `"."` _symbol_ `"TO"` _symbol_

Example:

```sepro
STRUCT triangle
    OBJ a (node)
    OBJ b (node)
    OBJ c (node)
    BIND a.next -> b
    BIND b.next -> c
    BIND c.next -> a
```

## Worlds

_World_ is a container specifying initial state of the simulation. It can be
thought as a list of "ingredients of the simulation primordial soup". 

In the language more worlds can be specified in the model, despite only one
world being used as a starting state of the system. If more worlds are
specified then the one with name `main` is used if not specified explicitly
otherwise.

_world_ = `"WORLD"` _symbol_ { _world_item_ }

_world_item_ = _integer_  _symbol_

For example the following world will yield 10 copies of structure _jar_ and 10
objects (out of structure) with tag _lid_:

```sepro
WORLD main
    10 jar
    10 (lid)
```

## Actuators

_selector_ = `"ALL"` | `"("` { _symbol_presence_ } `")"`

_symbol_presence_ = [`"!"`] _qualified_symbol_

_unary_actuator_ = `"ACT"` _symbol_ `"WHERE"` _selector_ { _unary_transition_ }

_unary_transition_ = `"IN"` _unary_subject_ { _modifier_ }

_unary_subject_ = `"THIS"` [`"."` _symbol_] | _symbol_

_modifier_ = `"BIND"` _symbol_ `"TO"` _qualified_symbol_ | `"UNBIND"` _symbol_ |
`"SET"` _symbol_ | `"UNSET"` _symbol

_binary_actuator_ = `"REACT"` _symbol_ `"WHERE"` _selector_ `"ON"` _selector_ {
_binary_transition_ }

_binary_transition_ = `"IN"` _binary_subject_ { _modifier_ }

_binary_subject_ = (`"LEFT"` | `"RIGHT"`) [`"."` _symbol_]


