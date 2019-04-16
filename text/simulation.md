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


