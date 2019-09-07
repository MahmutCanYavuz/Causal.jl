# This file constains the callbacks for event monitoring.

mutable struct Callback{C, A}
    condition::C       
    action::A     
    enabled::Bool
    id::UUID
end
Callback(condition, action) = Callback(condition, action, true, uuid4())

##### Callback controls
enable!(clb::Callback) = clb.enabled = true
disable!(clb::Callback) = clb.enabled = false

##### Callback calls
(clb::Callback)(obj) = clb.enabled && clb.condition(obj) ?  clb.action(obj) : nothing
@inbounds (clbs::Vector{Callback})(obj) = foreach(clb -> clb(obj), clbs)

##### Adding callbacks
addcallback(obj, callback::Callback, priority::Int) = insert!(obj.callbacks, priority, callback)
deletecallback(obj, idx::Int) = delete!(obj.callbacks, idx)
