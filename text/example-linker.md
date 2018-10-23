# Example: Linker

We made a simple example for the purpose of demonstration of the language that
we call 'Linker'. The model has two kinds of objects: a `link` node and a
'catalyst' we call `linker`. The linker has two sites: `site_a` and `site_b`. The
objective is to create chains of links when we put the linker and couple of
links into the simulation container.

The proposed process is:

- bind one site of the linker to a free link
- bind another site of the linker to another free link
- when both sites are bound then bind the links together
- release one link and free the site
- continue from binding another link to the free site

The program listing below contains actuators that satisfy the process above.
One might have noticed that the example contains explicit order specified by
transition of the linker through 

```sepro
DEF SLOT site_a
DEF SLOT site_b
DEF SLOT next
DEF TAG linker
DEF TAG link

REACT primer
    WHERE (linker !site_a)
    ON (free link)
    IN LEFT
        BIND site_a TO other
        SET wait_right

    IN RIGHT
        UNSET Free

REACT _wait_right
    WHERE (wait_right)
    ON (free link)
    IN left
        BIND site_b TO other
        UNSET wait_right
        SET chain
    IN right 
        UNSET free

ACT _chain
    WHERE (chain)
    IN this
        UNSET chain
        SET advance
    IN this.site_a
        BIND next TO site_b

ACT _advance
    WHERE (advance)
    IN this
        BIND site_a TO site_b
        UNSET advance
        SET cleanup

ACT _cleanup
    WHERE (cleanup)
    IN this
        BIND site_b TO none
        UNSET cleanup
        SET wait_right

WORLD main
    30 (free link)
    3 (linker)

```



