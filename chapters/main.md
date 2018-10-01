Inspired by biochemistry.

# Introduction


Objective of this project is to test alternative approach for simulation of
network problems, examine possibility of purely qualitative approach,
find primitives of non-conventional computation of network problem solving and
develop a simulator prototype and set of models that demonstrate the system.

# System Design Principles

Development of a system for modeling network complexity is non-trivial as
assumptions based on our more sophisticated knowledge might start creeping into
the design process. Such assumption creep can corrupt the system and therefore
the outcome of the models. As we don't foresee yet how the ultimate design
looks like, we will use evolutionary iterative approach to the design process.
To stay on track, we constrain our evolutionary process by design principles:

- _Completeness and clarity of model description_. The model described by the
  system has to be complete and should not require other information than the
  system specification to be understood.
- _Minimal set of assumptions._ Assumptions for behaviour or structure should
  be kept to minimum. System should provide only primitives and basic
  mechanisms from which more complex behavior or structure is to be composed.
  The primitives should be as simple as possible. New features should be
  evaluated carefully whether they can't be implemented using existing
  mechanisms. If they can, they should be omitted.
- _No explicit control flow._ There should be no mechanisms in the system that
  would guarantee model creators control flow (evaluation order) in atomic way.
  Model-specific order should always be vulnerable for potential interference
  from another model that might be composed.
- _Iterative simulation._ Modeled system's state changes iteratively through
  state transitions.  Absolute time (number of steps) is not observable to the
  model.
- _Parallel._ All components of the model are assumed to operate in parallel
  fashion even though the system's implementation might be fully or partially
  serial.  Effects of serial computation to the simulation result is considered
  an inevitable error of the concrete implementation of the system. Model
  results should carry the information about the nature of the computation
  engine.



# The Model

The modeled universe comprises of a system's state and description of the
system's dynamics. The state is a graph where we call nodes _objects_ which
have qualitative properties associated with them. The system's dynamics is a
collection of rules describing system's behavior called _actuators_.

To be able to refer to particular components of the model in a human readable
form we use _symbols_. Each symbol can refer to either particular component of
the model or a type of component.

Definition

: Model is a tuple $(S, T, A, G)$ where $S$ is a set of symbols, $T$ is a
symbol type table, $A$ is a collection of actuators and $G$ is a graph
representing system's state.

![Model](images/model)

Definition

: Symbol table $T$ is a mapping between a symbol and it's type:
$$T:=s\rightarrow t|s\in{S},t=\begin{cases}\text{tag}\\\text{slot}\\\text{actuator}\end{cases}$$
  We say that a symbol $s^t$ is of type $t$ when $s^t\in{S}\wedge T(s^t)=t$.
  Set of symbols $S^t$ is a set where each symbol is of type $t$.

_Object_ is indivisible entity representing an instance of relevant concept
within simulated universe. It is a carrier of qualitative properties - _tags_.
State of an object is denoted by a set of tags.

Definition

: Object graph $G$ is labeled oriented multigraph of objects (edges) and relationships
(vertices) $(O,R)$. Relationship is a tuple $\{s^\text{slot},o\}$ where
$s^\text{slot}\in S$ and $o\in O$


Definition

: Object's qualitative state is a set of symbols $\{t_1, t_2, ..., t_n\} | t_i \in S^\text{tag}$.

_Slot_ is a relational property of an objects that references other objects.
Slot is a label of an edge of the object graph. 

![Object tags](images/object-tags){width=20%}

Proposition

: We say that object $o$ has slots $\{s_1, s_2, ..., s_n\}$ if there exist
edges $\{o,s_i\}$.

![Object slots](images/object-slots){width=25%}


Before we proceed with the system's dynamics, we need to define one more
design concept of the system: _local context_.

Definition

: _Local context_ of an object $o$ is a subgraph $G^L\subseteq G$ with all
objects and relationships where object $o$ is the inital vertex.

In other words, local conetxt of an object $o$ is a subgraph within a graph distance of 1 from
the object $o$.

![Local context](images/local-context)


# Model Dynamics

The main concepts for the model dynamics are:

- _Actuator_ is a description of an atomic state transition of objects within the graph
  matching a pattern. It can be thought as an graph rewrite rule.
- _Selector_ is a match pattern or objects subject to transition
- _Transition/Modifier_ is a description of state change affects either object’s state or local
  relationships

Pattern matching or state transitions can happen only within a _local
context_. The _local context_ is an intentional design limitation which
restricts that object state and graph transitions can happen only within
distance of 1 from the selected object. Assumption here is that if we want to
reach an object with larger distance we have to use multiple steps and
therefore be open for interference - which is desired by design.


## Actuators

Actuators can be thought as declarations of graph rewrite rules combined with object state
transitions. They are applied to the whole graph[^2].

[^2]: Here we assume only lowest level of the Sepro model without a constraints
  level. Higher levels as well as constraints are out of scope of this article.

The universe graph can be modified either through a state of an
object or a state of two object in their hypothetical interaction.

_Unary Actuator_ describes transition of object’s state and local relationships based on previous
object’s state. Only object that matches a pattern or it's direct neighbours
can be affected.

![Unary Actuator](images/actuator-unary){width=30%}

_Binary Actuator_ is a conditioned transition of an object as a result of
cartesian product of two objects matching two selector patterns. Either of two
objects can undergo transition based on state of any of the objects in the
cartesian product tuple.

![Binary Actuator](images/actuator-binary){width=30%}

Binary actuator is the only way how a new connections to potentially unrelated
objects (no direct reference) might happen.



### Selector

Selector is a pattern description that matches properties of objects and their
local context. Pattern is a collection of multiple predicates that test
qualitative properties or existence of relationships of an object. An object
matches a selector pattern when:

- a direct predicate matches the object
- an indirect predicate matches object's direct neighbors

The predicates can tets for:

- Tags associated with an object: true if $\text{selector's tags}\subset\text{object’s tags}$
- Tags not associated with an object: true if $\text{object’s tags}\cap\text{selector’s
  tags}=\emptyset$
- Graph contains an edge from a specific slot
- Graph does not contain an edge from a specific slot

### State Modifiers

State modifiers (further just _modifiers_) are descriptions of graph state
transitions that operate on objects and their neighbors within their local
context. Assumed modifiers are non-divisable primitives we assume are
sufficient for any state transformations with their combined composition.

The state modifiers are:

- `SET` - associate a set of tags with an object
  $$result=\text{object tags}\cup \text{modifier tags}$$
- `UNSET` - disassociate set of tags with an object
  $$result = \text{object tags} - \text{modifier tags}$$

Graph edge modifiers: 

- `BIND` - bind a slot of an effective object
- `UNBIND` - unbind a slot of an effective object

Binary modifier have limited ability to modify the state by design. Unbinding
in a binary modifier can be achieved by a combination of binary state change
and an unary `UNBIND` modifier. Indirection in the binary modifier can be
achieved by a combination of binary direct subject state change and an unary
modifier.

Note that all state changes beyond distance of 1 from the selected object must be
composed of multiple transitions that propagate through the network.
Susceptibility to being affected by other actuators along the way is intended
design feature.

# Simulation

Actuator principles:

Order of applying actuators is not predetermined. Order of actuators being
applied might affect some simulations

## Control Signaling 

The language gives a possibility to provide signals to the simulator. There are
three kinds of signals: _notify_, _trap_ and _halt_. The _notify_ and _trap_
signals can carry a set of tags associated with them to provide more
information to the signal handlers.

- `NOTIFY` signals to the simulator and expectes no interruption of the
    simulation. State of the simulation must not be changed by the handler. Use
    case: monitor reached goals; trigger/start/stop measurement; visualize a
    state of interest
- `TRAP` signals and interrupts the simulator, giving it possibility to resume
    the simulation after the signal has been handled. State of the simulation
    might be changed by the handler.  Use case: goal reached and user
    interaction is expected; a product has been created
- `HALT` signals to the simulator to terminate the simulation without
    possibility of resuming it. Use case: invalid state has been reached,
    resuming the simulation might yield non-sensical results; final state has
    been reached and resuming the simulation might affect the result in
    non-meaningful way.

# Example: Linker
