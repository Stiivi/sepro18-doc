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




