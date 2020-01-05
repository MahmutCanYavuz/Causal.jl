# This file contains the links to connect together the tools of DsSimulator.

import Base: put!, take!, RefValue, close, isready, eltype, isopen, isreadable, iswritable

"""
    Pin() 

Constructs a `Pin`. A `Pin` is the auxilary type to monitor connection status of `Links`. See [`Link`](@ref)
"""
struct Pin
    id::UUID
    Pin() = new(uuid4())
end

"""
    Link{T}([ln::Int=64]) where T 

Constructs a `Link` with element type `T` and buffer length `ln`. The buffer element type of `T` and mode is `Cyclic`.
"""
mutable struct Link{T}
    buffer::Buffer{Cyclic, T}
    channel::Channel{T}
    leftpin::Pin
    rightpin::Pin
    callbacks::Vector{Callback}
    id::UUID
    master::RefValue{Link{T}}
    slaves::Vector{RefValue{Link{T}}}
    Link{T}(ln::Int=64) where {T} = new{Union{Missing, T}}(Buffer(T, ln), Channel{Union{Missing, T}}(0), Pin(), Pin(),
        Callback[], uuid4(), RefValue{Link{Union{Missing,T}}}(), Vector{RefValue{Link{Union{Missing, T}}}}()) 
end
Link(ln::Int=64) = Link{Float64}(ln)

eltype(link::Link{T}) where T = T

show(io::IO, link::Link) = print(io, 
    "Link(state:$(isopen(link) ? :open : :closed), eltype:$(eltype(link)), hasmaster:$(isassigned(link.master)), ", 
    "numslaves:$(length(link.slaves)), isreadable:$(isreadable(link)), iswritable:$(iswritable(link)))")

##### Link reading writing.
"""
    put!(link::Link, val)

Puts `val` to `link`. `val` is handed over to the `channel` of `link`. `val` is also written in to the `buffer` of `link`.

!!! warning
    `link` must be writable to put `val`. See [`launch`](@ref)
"""
function put!(link::Link, val) 
    write!(link.buffer, val)
    isempty(link.slaves) || foreach(junc -> put!(junc[], val), link.slaves)
    put!(link.channel, val)
    link.callbacks(link)
    return val
end

"""
    take!(link::Link)

Take an element from `link`.

!!! warning 
    `link` must be readable to take value. See [`launch`](@ref)
"""
function take!(link::Link)
    val = take!(link.channel)
    link.callbacks(link)
    return val
end

"""
    close(link)

Closes `link`. All the task bound the `link` is also terminated safely.
"""
function close(link::Link)
    channel = link.channel
    isempty(channel.cond_take.waitq) || put!(link, missing)   # Terminate taker task 
    isempty(channel.cond_put.waitq) || collect(link.channel)   # Terminater putter task 
    # isopen(link.channel) && close(link.channel)  # Close link channel if it is open.
    return 
end 

##### Auxilary functions to launch links.
### The `taker` and `puter` functions are just used for troubleshooting purpose.
function taker(link::Link)
    while true
        val = take!(link)
        val isa Missing && break  # Poison-pill the tasks to terminate safely.
        @info "Took " val
    end
end

function putter(link::Link, vals)
    for val in vals
        put!(link, val)
    end
end

##### State check of link.
"""
    open(link::Link)

Returns `true` if `link` is open. A `link` is open if its `channel` is open.
"""
isopen(link::Link) = isopen(link.channel) 

"""
    isreadable(link::Link)

Returns `true` if `link` is readable. When `link` is readable, data can be read from `link` with `take` function.
"""
isreadable(link::Link) = !isempty(link.channel.cond_put)

"""
    writable(link::Link)

Returns `true` if `link` is writable. When `link` is writable, data can be written into `link` with `put` function.
"""
iswritable(link::Link) = !isempty(link.channel.cond_take) 

"""
    isfull(link::Link)

Returns `true` if the `buffer` of `link` is full.
"""
isfull(link::Link) = isfull(link.buffer)

"""
    isconnected(link1, link2)

Returns `true` if `link1` is connected to `link2`. The order of the arguments are not important.
"""
isconnected(link1::Link, link2::Link) = 
    link2 in [slave[] for slave in link1.slaves] || link1 in [slave[] for slave in link2.slaves]

"""
    hasslaves(link::Link)

Returns `true` if `link` has slave links.
"""
hasslaves(link::Link) = !isempty(link.slaves)

"""
    hasmaster(link::Link)

Returns `true` if `link` has a master link.
"""
function hasmaster(link::Link) 
    try
        _ = link.master.x
    catch UnderVarError
        return false
    end
    return true
end

"""
    getmaster(link::Link)

Returns the `master` of `link`.
"""
getmaster(link::Link) = hasmaster(link) ? link.master[] : nothing

"""
    getslaves(link::Link)

Returns the `slaves` of `link`.
"""
getslaves(link::Link) = [slave[] for slave in link.slaves]

"""
    snapshot(link::Link)

Returns all the data of the `buffer` of `link`.
"""
snapshot(link::Link) = link.buffer.data

##### Connecting and disconnecting links
"""
    connect(master::Link, slave::Link)

Connects `master` to `slave`. When connected, the flow is from `master` to `slave`.

# Example 
```jldoctest 
julia> l1 = Link();

julia> l2 = Link();

julia> isconnected(l1, l2)
false

julia> connect(l1, l2)

julia> isconnected(l1, l2)
true
```
"""
function connect(master::Link, slave::Link)
    isconnected(master, slave) && (@warn "$master and $slave are already connected."; return)
    slave.leftpin = master.rightpin  # NOTE: The data flows through the links from left to right.
    push!(master.slaves, Ref(slave))
    slave.master = Ref(master) 
    return 
end

"""
    connect(master::AbstractVector{<:Link}, slave::AbstractVector{<:Link})

Connect `master` links to `slave` links by applying one-to-one matching of `master` links to `slave` links.
"""
function connect(master::AbstractVector{<:Link}, slave::AbstractVector{<:Link})
    foreach(pair -> connect(pair[1], pair[2]), zip(master, slave))
end

"""
    connect(links...)

Connect each link of `links` in the form of a path.

# Example 
```jldoctest
julia> l1, l2, l3 = Link(), Link(), Link();

julia> isconnected(l1, l2)
false

julia> isconnected(l2, l3)
false

julia> connect(l1, l2, l3)

julia> isconnected(l1, l2)
true

julia> isconnected(l2, l3)
true
```
"""
function connect(links::Link...)
    for i = 1 : length(links) - 1
        connect(links[i], links[i + 1])
    end
end

"""
    UnconnectedLinkError <: Exception

Exception thrown when the links are not connected to each other.
"""
struct UnconnectedLinkError <: Exception
    msg::String
end
Base.showerror(io::IO, err::UnconnectedLinkError) = print(io, "UnconnectedLinkError:\n $(err.msg)")

"""
    findflow(link1::Link, link2::Link)

Returns a tuple of (`masterlink`, `slavelink`) where `masterlink` is the link that drives the other and `slavelink` is the link that is driven by the other.
"""
function findflow(link1::Link, link2::Link)
    isconnected(link1, link2) || throw(UnconnectedLinkError("$link1, and $link2 are not connected."))
    link2 in [slave[] for slave in link1.slaves] ? (link1, link2) : (link2, link1)
end

"""
    disconnect(link1::Link, link2::Link)

Disconnects `link1` and `link2`. The order of arguments is not important. 
"""
function disconnect(link1::Link{T}, link2::Link{T}) where T
    master, slave = findflow(link1, link2)
    slaves = master.slaves
    deleteat!(slaves, findall(linkref -> linkref[] == slave, slaves))
    slave.master = RefValue{Link{T}}()
    slave.leftpin = Pin()
    return
end

"""
    insert(master::Link, slave::Link, new::Link)

Inserts the `new` link between the `master` link and `slave` link. The `master` is connected to `new`, and `new` is connected to `slave`.
"""
function insert(master::Link, slave::Link, new::Link)
    if isconnected(master, slave)
        master, slave = findflow(master, slave)
        disconnect(master, slave)
    else
        master, slave = master, slave
    end
    connect(master, new)
    connect(new, slave)
    return
end

# release(masterlink::Link) = foreach(slavelinkref -> disconnect(masterlink, slavelinkref[]), masterlink.slaves)
"""
    release(link::Link)

Release all the slave links of `link`. That is, all the slave links of `link` is disconnected.
"""
function release(link::Link)
    while !isempty(link.slaves)
        disconnect(link, link.slaves[1][])
    end
end

##### Launching links.
"""
    launch(link::Link)

Constructs a `taker` task and binds it to `link`.
"""
function launch(link::Link) 
    task = @async taker(link)
    bind(link.channel, task)
    task
end

"""
    launch(link:Link)

Constructs a `putter` task and binds it to `link`.
"""
function launch(link::Link, valrange)
    task = @async putter(link, valrange) 
    bind(link.channel, task) 
    task
end
function launch(link::Link, taskname::Symbol, valrange)
    msg = "`launch(link, taskname, valrange)` has been deprecated."
    msg *= "Use `launch(link)` to launch taker task, `launch(link, valrange)` to launch putter task"
    @warn msg
end
