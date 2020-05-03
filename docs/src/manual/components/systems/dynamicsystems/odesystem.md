# ODESystem

## Basic Operation of ODESystem 
When an `ODESystem` is triggered, it reads its current time from its `trigger` link, reads its `input`, solves its differential equation and computes its output. Let us observe the basic operation of `ODESystem`s with a simple example. 

We first construct an `ODESystem`. Since an `ODESystem` is represented by its state equation and output equation, we need to define those equations.
```@repl ode_ex 
using Jusdl # hide 
sfunc(dx,x,u,t) = (dx .= -0.5x)
ofunc(x, u, t) = x
```
Let us construct the system 
```@repl ode_ex 
ds = ODESystem(sfunc, ofunc, [1.], 0., Inport(1), Outport(1))
```
Note that `ds` is a single input single output `ODESystem` with an initial state of `[1.]` and initial time `0.`. To drive, i.e. trigger `ds`, we need to launch it.
```@repl ode_ex
oport, iport, trg, hnd = Outport(1), Inport(1), Outpin(), Inpin{Bool}()
connect(oport, ds.input) 
connect(ds.output, iport) 
connect(trg, ds.trigger) 
connect(ds.handshake, hnd)
task = launch(ds)
task2 = @async while true 
    all(take!(iport) .=== NaN) && break 
    end
```
When launched, `ds` is ready to driven. `ds` is driven from its `trigger` link. Note that the `trigger` link of `ds` is writable. 
```@repl ode_ex 
ds.trigger.link
```
Let us drive `ds` to the time of `t` of `1` second.
```@repl ode_ex 
put!(trg, 1.)
```
When driven, `ds` reads current time of `t` from its `trigger` link, reads its input value from its `input`, solves its differential equation and computes its output values and writes its `output`. So, for the step to be continued, an input values must be written. Note that the `input` of `ds` is writable,
```@repl ode_ex 
ds.input[1].link
```
Let us write some value. 
```@repl ode_ex 
put!(oport, [5.])
```
At this point, `ds` completed its step and put `true` to its `handshake` link to signal that its step is succeeded.
```@repl ode_ex 
hnd.link
```
To complete the step and be ready for another step, we need to approve the step by reading its `handshake`. 
```@repl ode_ex 
take!(hnd)
```
At this point, `ds` can be driven further. 
```@repl ode_ex 
for t in 2. : 10.
    put!(trg, t)
    put!(oport, [t * 10])
    take!(hnd)
end
```
Note that all the output value of `ds` is written to its `output`bus,
```@repl ode_ex 
iport[1].link.buffer
```
When we launched `ds`, we constructed a `task` and the `task` is still running.
```@repl ode_ex 
task
task2
```
To terminate the `task` safely, we need to `terminate` `ds` safely.
```@repl ode_ex
put!(trg, NaN)
put!(ds.output, [NaN])
```
Now, the state of the `task` is done. 
```@repl ode_ex 
task
task2
```
So, it is not possible to drive `ds`.

## Mutation in State Function in ODESystem 
Consider a system with the following ODE
```math 
\begin{array}{l}
    \dot{x} = f(x, u, t) \\
    y = g(x, u, t) \\
\end{array}
```
where ``x \in R^d, y \in R^m, u \in R^p``. To construct and `ODESystem`,  The signature of the state function `statefunc` must be of the form 
```julia 
function statefunc(dx, x, u, t)
    dx .= ... # Update dx
end
```
Note that `statefunc` *does not construct* `dx` but *updates* `dx` and does not return anything.  This is for [performance reasons](https://docs.juliadiffeq.org/latest/basics/faq/#faq_performance-1). On the contrary, the signature of the output function `outputfunc` must be of the form,
```julia 
function outputfunc(x, u, t)
    y = ... # Compute y
    return y
end
```
Note the output value `y` is *computed* and *returned* from `outputfunc`. `y` is *not updated* but *generated* in the `outputfunc`.

## Full API
```@autodocs
Modules = [Jusdl]
Pages   = ["odesystems.jl"]
Order = [:type, :function]
```