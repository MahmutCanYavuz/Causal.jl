# This file constains the callbacks for event monitoring.

mutable struct Callback{C, A}
    condition::C       
    action::A     
    enabled::Bool
    id::UUID
    Callback(condition::C, action::A) where {C, A} = new{C, A}(condition, action, true, uuid4()) 
end

show(io::IO, clb::Callback) = print(io, "Callback(condition:$(clb.condition), action:$(clb.action))")

##### Callback controls
enable!(clb::Callback) = clb.enabled = true
disable!(clb::Callback) = clb.enabled = false
isenabled(clb::Callback) = clb.enabled

##### Callback calls
(clb::Callback)(obj) = clb.enabled && clb.condition(obj) ?  clb.action(obj) : nothing
@inbounds (clbs::Vector{Callback})(obj) = foreach(clb -> clb(obj), clbs)

##### Adding callbacks
addcallback(obj, callback::Callback, priority::Int=1) = (insert!(obj.callbacks, priority, callback); obj)
deletecallback(obj, idx::Int) = (delete!(obj.callbacks, idx); obj)
