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

: Model is a tuple $M:=(S, S\rightarrow t, A, G)$ where $S$ is a set of
symbols, $S\rightarrow t$ is a symbol type table where $t$ is a symbol type,
$A$ is a collection of actuators and $G$ is a graph representing system's
state.

![Model](images/model)

Definition

: Symbol table $\S\rightarrow t$ is a mapping between a symbol and it's type:
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

: Object's qualitative state is a set of symbols $\{s^t_1, s^t_2, ..., s^t_n\}
| s^t_i \in S^\text{tag}$.  We will write it as $\text{tags}(o)$

![Object tags](images/object-tags){width=20%}

_Slot_ is a relational property of an objects that references other objects.
Slot is a label of an edge of the object graph. We will use the letter $s$ to
denote a slot.

Proposition

: We say that object $o$ has slots $\{s^s_1, s^s_2, ..., s^s_n\}$ if there exist
edges $\{o,s^s_i\}$. We will write it as $\text{slots}(o)$

![Object slots](images/object-slots){width=25%}


Before we proceed with the system's dynamics, we need to define one more
design concept of the system: _local context_.

Definition

: _Local context_ of an object $o$ is a subgraph $G^L\subseteq G$ with all
objects and relationships where object $o$ is the inital vertex.

In other words, local conetxt of an object $o$ is a subgraph within a graph distance of 1 from
the object $o$.

![Local context](images/local-context)

Before we move on with defition of other concepts, we need to define
how objects in the graph can be reffered to. We need to be able to refer to an
object within the local context relatively to the object being considered for
evalutaion. 

Definition

: _Subject mode_ is a relative reference to an object in the graph given
initial object. 
$$m:=\begin{cases}\text{direct}\\\text{indirect}(s^\text{slot})\end{cases}$$

_Subject mode_ is used to determine which object will be used for pattern
matching in the selector or for applying state transitions. We call the object
that is to be used for evaluation _effective subject_. _Direct_ subject
mode means that the _effective subject_ is the object being evaluated is to be
considered. _Indirect_ subject mode means that the _effective subject_ is the
object which is terminal vertex $o_t$ of the relationship
$\{s^\text{slot},o_t\}$ where the initial vertex is the object being evaluated.


# Model Dynamics


The main concepts for the model dynamics are:

- _Actuator_ is a description of an atomic state transition of objects within the graph
  matching a pattern. 
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

Actuators can be thought as declarations of graph rewrite rules combined with
object state transitions. They are applied to the whole graph[^2]. We assume
that all actuators operate on all objects at once.[^3]

[^2]: Here we assume only lowest level of the Sepro model without a constraints
  level. Higher levels as well as constraints are out of scope of this article.

[^3]: This is idealized assumption which has technical implementation
  limitations that we will discuss later. 

The graph can be modified either through a state of a single object or a state
of two object in their hypothetical interaction.

For observation and controlled simulation purposes the actuators have also a
_control signallig_ associated with them. We will discuss the control mechanism
later.

_Unary Actuator_ describes transition of object’s state and local relationships
based on previous object’s state. Only object that matches a pattern or it's
direct neighbours can be affected.

Language representation of the actuator is:

```
WHERE ... DO ...
```


![Unary Actuator](images/actuator-unary){width=30%}

_Binary Actuator_ is a conditioned transition of an object as a result of
cartesian product of two objects matching two selector patterns. Either of two
objects can undergo transition based on state of any of the objects in the
cartesian product tuple.

Definition

: _Unary actuator_ is a tuple $(\sigma, m\rightarrow T^1, n)$ where
$\sigma$ is a selector, $m$ is subject mode and $T^1$ is unary transition. $n$ is a control
signal (as in "notification").

Model language declaration of a unary actuator is:

```
ACT actuator_name
    WHERE (selector_patterns)
    DO unary_transitions
```



![Binary Actuator](images/actuator-binary){width=30%}

Binary actuator is the only way how a new connections to potentially unrelated
objects (no direct reference) might happen.

Definition

: _Binary actuator_ is a tuple $(\sigma_l, \sigma_r, m_l\rightarrow T^2_l, m_r\rightarrow T^2_r, \Gamma)$
where $\sigma_l$ and $\sigma_r$ are left and right selector respectively,
$T^2_l$ and $T^2_r$ are left and right binary transitions on effective subject
specified by left subject mode $m_l$ and right subject mode $m_r$ respectively.
$n$ is a control signal.

We would use the term _hand_ to refer to the left or right selector or
transition. 


Model language declaration of a binary actuator is:

```
REACT actuator_name
    WHERE (selector_patterns)
        ON (selector_patterns)
        DO binary_transitions
```


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


Definition

: _Selector_ is a patter description
$$\sigma:=\begin{cases}\text{all}\\\text{match}(m\rightarrow \Pi)\end{cases}$$
where $m$ is a subject mode and $\Pi$ is a selector pattern. We say that object
matches a selector when the selector is $\text{all}$ or when the _effective
subjects_ of the object match all the selector patterns $\Pi$.

Definition

: _Symbol presence_ $p$ is a case
$$p:=\begin{cases}\text{present}\\\text{absent}\end{cases}$$.


Definition

: _Selector pattern_ $\Pi$ is a tuple of mappings $(S^t\rightarrow p, S^s\rightarrow p)$ where $p$ is symbol's presence.
An object matches the selector pattern if all of the following are true: 
$$
\begin{aligned}
& \ \{s^t|s^t\rightarrow \text{present}\} \subset \text{tags}(o) \\
\wedge & \ \text{tags}(o) \cap \{s^t|s^t\rightarrow \text{absent}\}=\emptyset \\
\wedge & \ \{s^s|s^s\rightarrow \text{present}\} \subset \text{slots}(o) \\
\wedge & \ \text{slots}(o) \cap \{s^s|s^s\rightarrow \text{absent}\}=\emptyset\end{aligned}
$$


The language representation of the selector pattern is either a word `ALL` or a
list of symbols. Assume we have symbols `open`, `empty` referring to tags and
symbol `next` referring to a slot. For example the selector in the following
actuator matches all objects that have tag `open` set, have no `empty` tag set
and there exists a relationship at slot `next` from the object:

```
WHERE (open, !empty, next) ...
```

All symbols are considered to be in direct subject mode by default. Indirect
subject mode in the selector can be represented by object qualifier "dot"
operator as `indirection.symbol`[^4]. For example:

[^4]: Unlike in common general purpose programming languages, the indirection
  can not be chained as in `deep.deeper.deepest.symbol` due to the _local
  context_ constraint. 

```
WHERE next.open ...
```

The above matches an object where an object referred through slot `next` has a
tag `open` set.

### State Transitions

State transitions (further just _transitions_) are descriptions of qualitative
changes of the object graph. They operate on objects and their neighbors within
their local context.  Proposed transitions are non-divisable primitives we
assume being sufficient for any desired graph state transformations when
composition of the transitions is used.

The concrete object that is subject to transition is called _effective
 subject_ of the transition and is determined by the subject mode in the
actuator.

There are two kinds of transitions: qualitative state of an object and
qualitative state of the graph. The first one operates on object's qualitative
properties - _tags_ and the later operates on graph's relationships.
The tags can be associated or disassociated from an object. The relationships
can be _bound_ and _unbound_ within the local context of the effective subject.

### Unary Transition

Definition

: _Unary transition_ is a tuple
$T^1=(S^\text{tag}\rightarrow p,S^\text{slot}\rightarrow \mu^1)$ where the
first element is a qualitative transition of the effective subject and the
second element is a graph edge change from the effective subject to effective
target as described by the unary target specifier $\mu^1$.

If the $p = \text{present}$ then the $S^\text{tag}$ is associated with the
effective subject.
If the $p = \text{absent}$ then the $S^\text{tag}$ is dissociated with the
effective subject. [^6]

[^6]: Alternative and more readable or understandable way of specifying which
  tags are to be associated or disassociated with an object would be to use two
  sets of tags: _set_ and _unset_. However if the intersection of the sets is
  non-empty, the behaviour would be undefined. Using the mapping we prevent
  such situation from happening by design.

Definition

: _Unary target specifier_ $\mu^1$ is a case:
$$\mu^1:=\begin{cases}
\text{unbind}\\
\text{subject}\\
\text{in\_subject}(S^\text{slot})\\
\text{indirect}(S^\text{slot},S^\text{slot})\\
\end{cases}$$
The $\text{unbind}$ case specifies that the edge from the effective subject is
to be removed. $\text{subject}$ denotes that the target is the effective
subject itself, therefore creating a self-loop. Effective target of
the $\text{in\_subject}$ case is the object referred by the specified slot from
the effective subject. The $\text{indirect}$ effective target is an object
reffered to by the path of two slots from the effective subject.

The above gives us the following potential subject mode combinations for
creating an edge using unary actuator. Let's assume the effective subject
having slots $s$ and $t$, and the object referred to by slot $s$ having slot
$i$, object referred to by slot $t$ having slot $w$.

-----------------------------------------------------------------------------
Effective             Effective                Edge
subject               target
--------------------- ------------------------ ------------------------------
$\text{direct}$       $\text{none}$                 _removed_

$\text{direct}$       $\text{subject}$         $s\rightarrow \text{self}$

$\text{direct}$       $\text{in\_subject}(t)$  $s\rightarrow t$

$\text{direct}$       $\text{indirect}(t, w)$  $s\rightarrow t.w$

$\text{indirect}(i)$  $\text{none}$                 _removed_

$\text{indirect}(i)$  $\text{subject}$         $s.i\rightarrow \text{self}$

$\text{indirect}(i)$  $\text{in\_subject}(t)$  $s.i\rightarrow t$

$\text{indirect}(i)$  $\text{indirect}(t, w)$  _not atomic_
-----------------------------------------------------------------------------

Constraint

: Indirection of effective subject and effective target is not permitted, as
the operation can be achieved by by composing two separate actuators: one for
pulling indirect object closer to the effective subject and second for
performing indirect bind to the pulled-in subject and unbinding the subject.

### Binary Transition

Binary transition is analogous to the unary transition with one difference: the
effective target specifier can specify one of the two "hands" of the selector.

Effective subject of the binary transition is the subject selected by
corresponding hand selector. For the left hand selector $\sigma_l$ the
corresponding transition is $T^2l$ and the effective subject of the transition
is the subject determined by $\sigma_l$. Analogously for the right hand
transition the effective subject is determined by the $\sigma_r$.

Transition hand can affect only qualities of the effective subject on the same
hand similarly to unary transition. Although transition hand can have effective
target from the same hand or from the other hand. This allows us to create new
relationships between objects that are from disconnected parts of the graph. We
refer to the effective subject from the other selector simply as $\text{other}$.

Definition

: _Binary transition_ is a tuple
$T^1=(S^\text{tag}\rightarrow p,S^\text{slot}\rightarrow \mu^2)$ where the
first element is a qualitative transition of the effective subject and the
second element is a graph edge change from the effective subject to effective
target as described by the binary target specifier $\mu^2$.

The first element of the tuple for tags is the same as the mapping in the unary
transition. 

Definition

: _Binary target specifier_ $\mu^2$ is a case:
$$\mu^1:=\begin{cases}
\text{unbind}\\
\text{other}\\
\text{in\_other}(S^\text{slot})\\
\end{cases}$$
The $\text{unbind}$ case specifies that the edge from the effective subject is
to be removed. $\text{other}$ denotes that the target is the effective subject
of the other hand.  Effective target of the $\text{in\_other}$ case is the
object referred by the specified slot from the other hand's effective subject.

Note that there is no indirection in the binary transition as it can be
achieved by composing multiple transitions. Neither there is possibility to
create binding within the same effective subject as it can be achieved by
composing as well [^7].

[^7]: This is a design decision that we are proposing at this stage of system's
  evolution. We have no firm opinion whether bindings within the same hand
  should be allowed or not at this moment.

The following table lists allsubject mode combinations for creating an edge
between objects in the binary actuator. Let's assume the effective subject
on one hand having slots $s$ and $i$, and the effective subject on the other hand
having slot $t$.

-------------------------------------------------------------------------------
Effective             Effective                Edge
subject               target
--------------------- ------------------------ --------------------------------
$\text{direct}$       $\text{none}$                 _removed_

$\text{direct}$       $\text{other}$           $s\rightarrow \text{other}$

$\text{direct}$       $\text{in\_other}(t)$    $s\rightarrow \text{other}.t$

$\text{indirect}(i)$  $\text{none}$                 _removed_

$\text{indirect}(i)$  $\text{other}$           $s.i\rightarrow \text{other}$

$\text{indirect}(i)$  $\text{in\_other}(t)$    $s.i\rightarrow \text{other}.t$
-------------------------------------------------------------------------------


### Transition Modes Summary

The following figure shows all possible graph transitions for edge creation for
both unary and binary actuators:

![Possible graph transitions for edge creation](images/binding-transitions)

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

The simulation is virtually indefinite iterative evaluation of the model's
actuators that operate on system's state.

Given inspiration in biochemistry, the nature of the Sepro system does not
impose any evaluation order of the actuators and selection order of objects.
However, to be able to perform the simulation on Von-Neumann computer
architecture which is sequential, we need to define the order of events in the
simulation, and understand it’s impact on the simulation result. The emphasis
is more on the explicit impact description than on the actual order definition.
The evaluation order is a meta-problem that we are not trying to solve yet, but
we need to propose few solution to start with.

Assumption

: In this evolutionary step of the system we consider the time to be unified
globally. That means that time is the same for every entity of the system.

Having global time of discrete nature, we can refer to each state by global
time reference _t_ and can say that state of the system at time _t_ is
described as a state of objects and bindings at time _t_.

Definition

: Simlation step $\Delta$ is an approximation of system's transition in form of
a function
$$G^{t+1}=\Delta(G^t, M)$$
where $G^0$ is the graph $G$ from the model $M$. 

We have to keep in mind that the $\Delta$ is not a true simulation mechanism,
just an approximation. It is so due to the assumption of global time and potential
effects of linearization.

During the simulation step the following happens:

* Every unary actuator is tested against each object and the associated unary
    transition is applied to the objects that match the actuator's selector.
* For every binary actuator a cartesian product of objects matching left
    selector and right selector is determined and binary transitions are
    applied to their respective effective subjects.
* Control signals are gathered and provided to the simulation controller or
    observer.
    
As mentioned above, the order how the actuators, their evaluation and
application is  executed is left to the concrete implementation of the
simulation engine. The decision whether the simulation is performed in parallel
and what kind of parallelism is used is an implementation choice of the
simulation engine. It has to be remembered that, as mentioned before, the simulation might be
highly sensitive to the order of execution. 

## "Sequential Scan" Simulation Method

Here we propose a simple, quite primitive yet straightforward simulation
method: _Sequential scans with actuators first_. This method performs the
_simulation step_ in a single thread and considers the time to be
system-global.

The simulation step can be described in a pseudo-language as:

```
	FOR actuator IN unary actuators DO:
	    evaluate unary actuator
	
	FOR actuator IN binary actuators DO:
	    evaluate binary actuator
```

We serialise the simulation process by applying the transitions of the system
in the order as given by a lazy selection algorithm described below. The method
is analogous to vertical and horizontal line scan of a CRT screen where an
object can be seen as a point on the screen and where the beam traverses the
points in fixed pattern. One simulation step can be modelled by a single full
scan of the whole screen. Once the beam touches a point on the screen, it does
not go back within the same full screen scan.

The unary actuator scan is depicted in the following figure:

![Unary scan](images/simulation-unary-scan){width=25%}

The evaluation of unary actuator is a single pass through the lazy selection of
objects matching actuator’s predicates:

```
selection := objects matching actuator selector
	
FOR object IN selection DO:
    IF object matches selector:
        apply actuator transitions to object
```

The binary actuator "scans" a cartesian product of the "left" and "right"
selector of the actuator:

![Binary actuator - scan of cartesian
product](images/simulation-binary-scan){width=30%}


The evaluation of the binary selector is as follows:

```pseudo
selection L := GET objects matching left selector of actuator
selection R := GET objects matching right selector of actuator

FOR left IN L DO:
    FOR right IN R DO:
        IF left does not match left selector:
            CONTINUE
        IF right does not match right selector:
            CONTINUE

        apply transition to left and right
```

The inner conditions are to filter out objects that might have been already
modified in the scan pass and might not fit the selection predicates any more.

![Binary actuator - skipping](images/simulation-binary-skip){width=35%}

### Known Issues

The scan method described above has two major factors that influence the the
simulation's outcome:

* Order in which actuators are evaluated.
* Order in which the objects are provided to the filter.

Let’s consider two actuators A and B evaluated in the same order: first A then
B. If an object does not match predicates of A, matches predicate for B and
actuator B modifies the object in a way that it would match actuator A, the
object is not evaluated again with the actuator A. We will call this _actuator
order error_.

Let’s consider order of objects ${o_1,o_2,\ldots,o_n}$ and an actuator that by
evaluating $o_1$ modifies $o_2$ in a way that $o_3$ will not match the actuator’s
predicate (will lose candidacy, will not be visited). If we provide another
order, for example reverse order, then $o_2$ will be visited. We will call this
_object selection order error_.

Here we suggest that how the simulation sub-steps are ordered must be known
fact to the simulator user. 

For further research, it might be interesting to further investigate effect of
ordering to the outcome of certain models. For example:

- Randomization of the actutors, including unary and binary.
- Randomization of the objects for each iteration and actuator.
- Object-first pass: the outer loop is object loop, the inner loops are
    actuator loops.

In a potential virtual laboratory where one might test different kinds of
ordering the controller might provide mechanisms to compare different outcomes
based on the orderings. This investigation is out of scope of this article,
left as an exercise to the reader.


### Parallel Evaluation

Massively parallel evaluation is the ultimate goal of the system as it closely
mimics the behaviour in the real world. By _massively parralel_ we mean one
processing unit per object per actuator observing the relevant context of the
unit-associateid object.

Simplified parallelism can be achieved by splitting the object graph into
smaller parts, performing partial evalutaions and then consolidating the
results. This is a whole are to be explored as it opens many questions, such
as:

* How to synchronise the simulation states?
* How to resolve potential modifier-predicate order conflicts?
* How to consolidate conflicting modifications?
* How the consolidation method affects the outcome of the simulation?
* Which parameters of the simulation configuration affect potential errors of
  the simulation and in which way?

## Control Signaling 

The language gives a possibility to provide signals to the simulator. Signals
are triggered together with activation of the associated actuator. The control
signalling has no direct effect on the model and it's interpretation is given
by the simulator. It can be thought as an action to communicate
unidirectionally with the observer.

There are three kinds of signals: _notify_, _trap_ and _halt_. The _notify_ and
_trap_ signals can carry a set of tags associated with them to provide more
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

# Language

Describe language here

# Example: Linker

Describe the "Linker" example here

# Appendix: Symbols used

-------------------------------------------------------------------------
Symbol
------------ ----------------------------------------------------------------
$A$          actuator

$A^1$        unary actuator

$A^2$        binary actuator

$G$          graph

$\Gamma$     selector

$M$          model

$m$          subject mode

$\mu$        transition target sepcifier

$\mu^1$      unary transition target specifier

$\mu^2$      binary transition target specifier

$n$          signal

$o$          object

$O$          set of objects

$p$          symbol presence

$\Pi$        selector pattern

$R$          set of relationships (graph edges)

$S$          set of symbols

$s$          symbol - any type

$S^t$        set of symbols of type $t$

$s^t$        symbol of type $t$

$\sigma$     selector

$\sigma_l$   selector for left subject

$\sigma_r$   selector for right subject

$t$          symbol type

$T$          transition

$T^1$        unary transition

$T^2$        binary transition

$T^2_l$      binary transition for left target 

$T^2_r$      binary transition for right target
-------------------------------------------------------------------------

Table: Symbols.

