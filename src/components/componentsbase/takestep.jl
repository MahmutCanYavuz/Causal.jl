# This file includes stepping of abstract types.

import ....Jusdl.Connections: launch, Bus, release, isreadable
import ....Jusdl.Utilities: write!

using DifferentialEquations
using Sundials

##### Input-Output reading and writing.
"""
    readtime(comp::AbstractComponent)

Returns current time of `comp` from its `trigger` link.

!!! note 
    To read time of `comp`, `comp` must be launched. See also: [`launch(comp::AbstractComponent)`](@ref).
"""
readtime(comp::AbstractComponent) = take!(comp.trigger)

"""
    readstate(comp::AbstractComponent)

Returns the state of `comp` if `comp` is `AbstractDynamicSystem`. Otherwise, returns `nothing`. 
"""
readstate(comp::AbstractComponent) = typeof(comp) <: AbstractDynamicSystem ? comp.state : nothing

"""
    readinput(comp::AbstractComponent)

Returne the input value of `comp` if the `input` of `comp` is `Bus`. Otherwise, returns `nothing`.

!!! note 
    To read input value of `comp`, `comp` must be launched. See also: [`launch(comp::AbstractComponent)`](@ref)
"""
function readinput(comp::AbstractComponent)
    typeof(comp) <: AbstractSource && return nothing
    typeof(comp.input) <: Bus ? take!(comp.input) : nothing
end

"""
    writeoutput(comp::AbstractComponent, out)

Writes `out` to the output of `comp` if the `output` of `comp` is `Bus`. Otherwise, does `nothing`.
"""
function writeoutput(comp::AbstractComponent, out)
    typeof(comp) <: AbstractSink && return nothing  
    typeof(comp.output) <: Bus ? put!(comp.output, out) : nothing
end

"""
    computeoutput(comp, x, u, t)

Computes the output of `comp` according to its `outputfunc` if `outputfunc` is not `nothing`. Otherwise, `nothing` is done. `x` is the state, `u` is the value of input, `t` is the time. 
"""
function computeoutput end
computeoutput(comp::AbstractSource, x, u, t) = comp.outputfunc(t)
computeoutput(comp::AbstractStaticSystem, x, u, t) =  
    typeof(comp.outputfunc) <: Nothing ? nothing : comp.outputfunc(u, t)
function computeoutput(comp::AbstractDynamicSystem, x, u, t)
    typeof(comp.outputfunc) <: Nothing && return nothing
    typeof(u) <: Nothing ? comp.outputfunc(x, u, t) : comp.outputfunc(x, map(ui -> t -> ui, u), t) 
end
    # typeof(comp.outputfunc) <: Nothing ? nothing : comp.outputfunc(x, constructinput(comp, u, t), t)
computeoutput(comp::AbstractSink, x, u, t) = nothing

"""
    evolve!(comp::AbstractSource, u, t)

Does nothing. `u` is the value of `input` and `t` is time.

    evolve!(comp::AbstractSink, u, t) 

Writes `t` to time buffer `timebuf` and `u` to `databuf` of `comp`. `u` is the value of `input` and `t` is time.

    evolve!(comp::AbstractStaticSystem, u, t)

Writes `u` to `buffer` of `comp` if `comp` is an `AbstractMemory`. Otherwise, `nothing` is done. `u` is the value of `input` and `t` is time. 
    
    evolve!(comp::AbstractDynamicSystem, u, t)

Solves the differential equation of the system of `comp` for the time interval `(comp.t, t)` for the inital condition `x` where `x` is the current state of `comp` . `u` is the input function defined for `(comp.t, t)`. The `comp` is updated with the computed state and time `t`. See also: [`update!(comp::AbstractDynamicSystem, sol, u)`](@ref)
"""
function evolve! end
evolve!(comp::AbstractSource, u, t) = nothing
evolve!(comp::AbstractSink, u, t) = (write!(comp.timebuf, t); write!(comp.databuf, u); nothing)
evolve!(comp::AbstractStaticSystem, u, t) = typeof(comp) <: AbstractMemory ? write!(comp.buffer, u) : nothing
function evolve!(comp::AbstractDynamicSystem, u, t)
    # For DDESystems, the problem for a time span of (t, t) cannot be solved. 
    # Thus, there will be no evolution in such a case.
    comp.t == t && return comp.state  

    # Advance the system and update the system.
    advance!(comp, u, t)
    updatetime!(comp)
    updatestate!(comp)

    # Return comp state
    comp.state
end

function advance!(comp::AbstractDynamicSystem, u, t)
    interpolator = comp.integrator.sol.prob.p
    update_interpolator!(interpolator, u, t)
    step!(comp.integrator, t - comp.t, true)
    update_interpolator!(interpolator)
end
update_interpolator!(interp::Nothing) = nothing
update_interpolator!(interp::Nothing, u, t) = nothing
update_interpolator!(interp::Interpolant) = (interp.tinit = interp.tfinal; interp.coefinit = interp.coeffinal)
update_interpolator!(interp::Interpolant, u, t) = (interp.tfinal = t; interp.coeffinal = u)

updatetime!(comp) = (comp.t = comp.integrator.t)
updatestate!(comp) = (comp.state = comp.integrator.u)

##### Task management
"""
    takestep(comp::AbstractComponent)

Reads the time `t` from the `trigger` link of `comp`. If `comp` is an `AbstractMemory`, a backward step is taken. Otherwise, a forward step is taken. See also: [`forwardstep`](@ref), [`backwardstep`](@ref).
"""
function takestep(comp::AbstractComponent)
    t = readtime(comp)
    # t === missing && return t
    t === NaN && return t
    typeof(comp) <: AbstractMemory ? backwardstep(comp, t) : forwardstep(comp, t)
end

"""
    forwardstep(comp, t)

Makes `comp` takes a forward step.  The input value `u` and state `x` of `comp` are read. Using `x`, `u` and time `t`,  `comp` is evolved. The output `y` of `comp` is computed and written into the output bus of `comp`. 
"""
function forwardstep(comp, t)
    u = readinput(comp)
    x = evolve!(comp, u, t)
    y = computeoutput(comp, x, u, t)
    writeoutput(comp, y)
    comp.callbacks(comp)
    return t
end


"""
    backwardstep(comp, t)

Reads the state `x`. Using the time `t` and `x`, computes and writes the ouput value `y` of `comp`. Then, the input value `u` is read and `comp` is evolved.  
"""
function backwardstep(comp, t)
    x = readstate(comp)
    y = computeoutput(comp, x, nothing, t)
    writeoutput(comp, y)
    u = readinput(comp)
    xn = evolve!(comp, u, t)
    comp.callbacks(comp)
    return t
end


"""
    launch(comp::AbstractComponent)

Returns a tuple of tasks so that `trigger` link and `output` bus of `comp` is drivable. When launched, `comp` is ready to be driven from its `trigger` link. See also: [`drive(comp::AbstractComponent, t)`](@ref)
"""
function launch(comp::AbstractComponent)
    outputtask = if !(typeof(comp) <: AbstractSink)  # Check for `AbstractSink`.
        if !(typeof(comp.output) <: Nothing)  # Check for `Terminator`.
            @async while true 
                val = take!(comp.output)
                # all(val .=== missing) && break
                all(val .=== NaN) && break
            end
        end
    end
    triggertask = @async begin 
        while true
            # takestep(comp) === missing && break
            takestep(comp) === NaN && break
            put!(comp.handshake, true)
        end
        typeof(comp) <: AbstractSink && close(comp)
    end
    return triggertask, outputtask
end

"""
    drive(comp::AbstractComponent, t)

Writes `t` to the `trigger` link of `comp`. When driven, `comp` takes a step. See also: [`takestep(comp::AbstractComponent)`](@ref)
"""
drive(comp::AbstractComponent, t) = put!(comp.trigger, t)

"""
    approve(comp::AbstractComponent)

Read `handshake` link of `comp`. When not approved or `false` is read from the `handshake` link, the task launched for the `trigger` link of `comp` gets stuck during `comp` is taking step.
"""
approve(comp::AbstractComponent) = take!(comp.handshake)

"""
    release(comp::AbstractComponent)

Releases the `input` and `output` bus of `comp`.
""" 
function release(comp::AbstractComponent)
    typeof(comp) <: AbstractSource  || typeof(comp.input) <: Nothing    || release(comp.input)
    typeof(comp) <: AbstractSink    || typeof(comp.output) <: Nothing   || release(comp.output)
    return 
end


"""
    terminate(comp::AbstractComponent)

Closes the `trigger` link and `output` bus of `comp`.
"""
function terminate(comp::AbstractComponent)
    typeof(comp) <: AbstractSink || typeof(comp.output) <: Nothing || close(comp.output)
    close(comp.trigger)
    return 
end

##### SubSystem interface
"""
    launch(comp::AbstractSubSystem)

Launches all subcomponents of `comp`. See also: [`launch(comp::AbstractComponent)`](@ref)
"""
launch(comp::AbstractSubSystem) = launch.(comp.components)

"""
    takestep(comp::AbstractSubSystem)

Makes `comp` to take a step by making each subcomponent of `comp` take a step. See also: [`takestep(comp::AbstractComponent)`](@ref)
"""
function takestep(comp::AbstractSubSystem)
    t = readtime(comp)
    # t === missing && return t
    t === NaN && return t
    foreach(takestep, comp.components)
    approve(comp) ||  @warn "Could not be approved in the subsystem"
    put!(comp.handshake, true)
end

"""
    drive(comp::AbstractSubSystem, t)

Drives `comp` by driving each subcomponent of `comp`. See also: [`drive(comp::AbstractComponent, t)`](@ref)
"""
drive(comp::AbstractSubSystem, t) = foreach(component -> drive(component, t), comp.components)

"""
    approve(comp::AbstractSubSystem)

Approves `comp` by approving each subcomponent of `comp`. See also: [`approve(comp::AbstractComponent)`](@ref)
"""
approve(comp::AbstractSubSystem) = all(approve.(comp.components))


""" 
    release(comp::AbstractSubSystem)

Releases `comp` by releasing each subcomponent of `comp`. See also: [`release(comp::AbstractComponent)`](@ref)
"""
function release(comp::AbstractSubSystem)
    foreach(release, comp.components)
    typeof(comp.input) <: Bus && release(comp.input)
    typeof(comp.output) <: Bus && release(comp.output)
end

"""
    terminate(comp::AbstractSubSystem)

Terminates `comp` by terminating each subcomponent of `comp`. See also: [`terminate(comp::AbstractComponent)`](@ref)
"""
terminate(comp::AbstractSubSystem) = foreach(terminate, comp.components)
