# Rejected Ideas

The ideas listed here were either rejected or postponed for further
re-consideration or re-design.

## Root Object

The _root object_ served as a globally referencable state. From
simulation dynamics perspective it was no different to any other object. The
only difference with other objects was that the root object could be referenced
explicitly by a symbol `ROOT`. Objects were able to react with the root object
through binary selectors where one of the selector operands was a root object.

From the original proposal:

> There might be situations where we need to consider a global state in a
> simulation. For that purpose there is one special object that we call _root_.
> It is the only object that can be explicitly globally referenced. Every
> simulation has a root object, event-though it might be unused. Default root
> object is empty, has no properties and no slots.

The idea was rejected because we want to work with local interactions only.
Having a global state would open possibility to compromise the local
interaction principle.

## Counters

_Counters_ were quantitative properties of an object. The quantity stored is a
number of instances of countable quality associated with the object. A counter
can be imagined as a container able to hold multiple copies of the same tag.
The only difference is that the _counter_ is a static property of an object.

Counters, as originally designe, were static properties can not be
dis-associated from neither associated with an object during run time. Counters
can be changed by incrementing or decrementing their values. Counters can be
cleared to be zero and they can be tested whether they are zero.

Counters were temporarily rejected because they can be partially implemented
through existing mechanisms. Whether counters should remain in the model or not
is still open for dicsussion and more research is needed.

