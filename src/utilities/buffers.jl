# This file constains the Buffer for data buffering.

import Base: getindex, setindex!, size, read, isempty, setproperty!, fill!, length, eltype, firstindex, lastindex

##### Buffer modes
"""
    BufferMode 

Abstract type for buffer mode. Subtypes of `BufferMode` is `CyclicMode` and `LinearMode`.
"""
abstract type BufferMode end

"""
    CyclicMode <: BufferMode

Abstract type of cyclic buffer modes. See [`Cyclic`](@ref)
"""
abstract type CyclicMode <: BufferMode end 

"""
    LinearMode <: BufferMode 

Abstract type of linear buffer modes. See [`Normal`](@ref), [`Lifo`](@ref), [`Fifo`](@ref)
"""
abstract type LinearMode <: BufferMode end  

"""
    Cyclic <: CyclicMode

Cyclic buffer mode. The data is written to buffer until the buffer is full. When the buffer is full, new data is written by overwriting the data available in the buffer starting from the beginning of the buffer. When the buffer is read, the element written last is returned and the returned element is not deleted from the buffer.
"""
struct Cyclic <: CyclicMode end 

"""
    Normal <: LinearMode

LinearMode buffer mode. The data is written to buffer until the buffer is full. When it is full, no more data is written to the buffer. When read, the data written last is returned and the returned data is not deleted from the internal container of the buffer. 
"""
struct Normal <: LinearMode end

"""
    Lifo <: LinearMode

Lifo (Last-in-first-out) buffer mode. This type of buffer is a *last-in-first-out* buffer. Data is written to the buffer until the buffer is full. When the buffer is full, no more element can be written into the buffer. When read, the last element written into buffer is returned. The returned element is deleted from the buffer.
"""
struct Lifo <: LinearMode end 

"""
    Fifo <: LinearMode

Fifo (First-in-last-out) buffer mode. This type of buffer is a *first-in-first-out* buffer. The data is written to the buffer until the buffer is full. When the buffer is full, no more element can be written into the buffer. When read, the first element written into the buffer is returned. The returned element is deleted from the buffer. 
"""
struct Fifo <: LinearMode end 


##### Buffer
"""
    Buffer{M}(::Type{T}, ln::Int) where {M, T} 

Constructs a `Buffer` of length `ln` with element type of `T`. `M` is the mode of the `Buffer` that determines how data is to read from and written into the `Buffer`.  There exists for different buffer modes: 

* `Normal`: See [`Normal`](@ref)

* `Cyclic`: See [`Cyclic`](@ref)

* `Lifo`: See [`Lifo`](@ref)

* `Fifo`: See [`Fifo`](@ref)

The default mode for `Buffer` is `Cyclic` and default element type is `Float64`.

    Buffer(::Type{T}, ln::Int) where T 

Constructs a `Buffer` of length `ln` and with element type of `T`. The mode of the buffer is `Cyclic`.

    Buffer{M}(ln::Int) where M

Constructs a `Buffer` of length of `ln` and with mode `M`. `M` can be `Normal`, `Cyclic`, `Fifo` and `Lifo`. The element type of the `Buffer` is `Float64`.

    Buffer(ln::Int) 

Constructs a `Buffer` of length `ln` with mode `Cyclic` and element type of `Float64`.
"""
mutable struct Buffer{M<:BufferMode, T}
    data::Vector{T}
    index::Int 
    state::Symbol 
    callbacks::Vector{Callback}
    id::UUID
    Buffer{M}(::Type{T}, ln::Int) where {M, T} = new{M, Union{Missing, T}}(fill!(Vector{Union{Missing,T}}(undef, ln),
         missing), 1, :empty, Callback[], uuid4())
end
Buffer(::Type{T}, ln::Int) where T = Buffer{Cyclic}(T, ln)
Buffer{M}(ln::Int) where M = Buffer{M}(Float64, ln)
Buffer(ln::Int) = Buffer(Float64, ln)

show(io::IO, buf::Buffer)= print(io, 
    "Buffer(mode:$(mode(buf)), eltype:$(eltype(buf)), length:$(length(buf)), index:$(buf.index), state:$(buf.state))")


##### Buffer info.
mode(buf::Buffer{M, T}) where {M, T} = M
eltype(buf::Buffer{M, T}) where {M, T} = T

##### AbstractArray interface.
eltype(buf::Buffer) = eltype(buf.data)
length(buf::Buffer) = length(buf.data)
size(buf::Buffer) = size(buf.data)
getindex(buf::Buffer, idx::Vararg{Int, N}) where N = buf.data[idx...]
getindex(buf::Buffer, idx::UnitRange) = buf.data[idx]
getindex(buf::Buffer, idx::Vector{Int}) =  buf.data[idx]
getindex(buf::Buffer, idx::UnitRange{Int}) = buf.data[idx]
getindex(buf::Buffer, ::Colon) = buf.data[:]
setindex!(buf::Buffer, val, inds::Vararg{Int, N}) where N = (buf.data[inds...] = val)
setindex!(buf::Buffer, val, idx::Vector{Int}) = buf.data[idx] = val
setindex!(buf::Buffer, val, idx::UnitRange{Int}) = buf.data[idx] = val
setindex!(buf::Buffer, val, ::Colon) = buf.data[:] = val
firstindex(buf::Buffer) = 1
lastindex(buf::Buffer) = length(buf)  # For indexing like bus[end]

##### Buffer state control and check.
"""
    isempty(buf::Buffer)

Returns `true` if `buf` is empty.
"""
isempty(buf::Buffer) = buf.state == :empty

"""
    isfull(buf::Buffer)

Returns `true` if `buf` is full.
"""
isfull(buf::Buffer) = buf.state == :full
function setproperty!(buf::Buffer, name::Symbol, val::Int)
    if name == :index
        val < 1 && error("Buffer index cannot be less than 1.")
        setfield!(buf, name, val)
        if val == 1
            buf.state = :empty
        elseif val > size(buf.data, 1)
            buf.state = :full
        else
            buf.state = :nonempty
        end
    end
end

##### Writing into buffers
resetindex(buf::Buffer) = setfield!(buf, :index, %(buf.index, size(buf.data, 1)))
checkindex(buf::Buffer) = isfull(buf) && resetindex(buf)
writelinear(buf::Buffer{M, T}, val) where {M, T} = 
    isfull(buf) ? (@warn "Buffer is full.") : (buf[buf.index] = val; buf.index +=1)
writecylic(buf::Buffer{M, T}, val) where {M, T} = (buf[buf.index] = val; buf.index += 1; checkindex(buf))
# writeinto(buf::Buffer{M, T}, val) where{M<:LinearMode, T} = writelinear(buf, val)
# writeinto(buf::Buffer{M, T}, val) where{M<:CyclicMode, T} = writecylic(buf, val)

"""
    write!(buf::Buffer{M, T}, val) where {M, T}

Writes `val` into `buf`. Writing is carried occurding the mode `M` of `buf`. See [`Normal`](@ref), [`Cyclic`](@ref), [`Lifo`](@ref), [`Fifo`](@ref) for buffer modes. 

# Example 
```jldoctest 
julia> buf = Buffer(3)
Buffer(mode:Cyclic, eltype:Union{Missing, Float64}, length:3, index:1, state:empty)

julia> buf.data  # Initailly all the elements of `buf` is missing.
3-element Array{Union{Missing, Float64},1}:
 missing
 missing
 missing

julia> write!(buf, 3.)
3.0

julia> buf.data
3-element Array{Union{Missing, Float64},1}:
 3.0     
  missing
  missing
```
"""
function write!(buf::Buffer{M, T}, val) where {M, T}
    # writeinto(buf, val)
    if buf isa Buffer{<:Cyclic, T} where T 
        writecylic(buf, val)
    else
        writelinear(buf, val)
    end
    buf.callbacks(buf)
    val
end
write!(buf::Buffer{M, T}, val::AbstractArray{Missing}) where {M, T} = write!(buf, missing)

"""
    fill!(buf::Buffer{M, T}, val::T) where {M,T}

Writes `val` into `buf` until `buf` is full.
"""
fill!(buf::Buffer{M, T}, val::T) where {M, T} = foreach(i -> write!(buf, val), 1 : length(buf))

##### Reading from buffers
readfrom(buf::Buffer{M, T}) where {M<:Union{Normal, Cyclic}, T} = buf.data[buf.index - 1]
function readfrom(buf::Buffer{M, T}) where {M<:Fifo, T}
    val = buf.data[1]
    buf.data .= circshift(buf.data, -1)
    buf.data[end] = missing
    buf.index -= 1
    val
end
function readfrom(buf::Buffer{M, T}) where {M<:Lifo, T}
    val = buf.data[end]
    buf.data[end] = missing
    buf.index -= 1
    val
end

"""
    read(buf::Buffer)

Reads an element from `buf`. Reading is performed according to the mode of `buf`. See [`Normal`](@ref), [`Cyclic`](@ref), [`Lifo`](@ref), [`Fifo`](@ref) for buffer modes. 

# Example
```jldoctest
julia> buf = Buffer{Fifo}(3)
Buffer(mode:Fifo, eltype:Union{Missing, Float64}, length:3, index:1, state:empty)

julia> for val in 1 : 3. 
       write!(buf, val)
       @show buf.data
       end 
buf.data = Union{Missing, Float64}[1.0, missing, missing]
buf.data = Union{Missing, Float64}[1.0, 2.0, missing]
buf.data = Union{Missing, Float64}[1.0, 2.0, 3.0]

julia> for i in 1 : 3 
       item = read(buf)
       @show (item, buf.data)
       end
(item, buf.data) = (1.0, Union{Missing, Float64}[2.0, 3.0, missing])
(item, buf.data) = (2.0, Union{Missing, Float64}[3.0, missing, missing])
(item, buf.data) = (3.0, Union{Missing, Float64}[missing, missing, missing])
```
"""
function read(buf::Buffer) 
    isempty(buf) && error("Buffer is empty")
    val = readfrom(buf)
    buf.callbacks(buf)
    val
end

##### Accessing buffer data
"""
    content(buf, [flip=true])

Returns the current data of `buf`. If `flip` is `true`, the data to be returned is flipped. 
"""
function content(buf::Buffer; flip::Bool=true)
    val = buf[1 : buf.index - 1]
    flip ? reverse(val, dims=1) : val
end

snapshot(buf::Buffer) = buf.data

##### Calling buffers.
(buf::Buffer)() = read(buf)
