var documenterSearchIndex = {"docs":
[{"location":"manual/buffers/#Buffer-1","page":"Buffer","title":"Buffer","text":"","category":"section"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"DocTestSetup  = quote\n    using Jusdl\n    import Utilities: BufferMode, LinearMode, CyclicMode\nend","category":"page"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"Buffer is a primitive to buffer the data. Data can be of any Julia type. Data can be read from and written into a buffer, and the mode of the buffer determines the way to read from and write into the buffers. ","category":"page"},{"location":"manual/buffers/#Buffer-Modes-1","page":"Buffer","title":"Buffer Modes","text":"","category":"section"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"Buffer mode determines the way the data is read from and written into a Buffer. ","category":"page"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"Utilities.BufferMode \nUtilities.LinearMode \nUtilities.CyclicMode","category":"page"},{"location":"manual/buffers/#Jusdl.Utilities.BufferMode","page":"Buffer","title":"Jusdl.Utilities.BufferMode","text":"BufferMode\n\nAbstract type for buffer mode. Subtypes of BufferMode is CyclicMode and LinearMode.\n\n\n\n\n\n","category":"type"},{"location":"manual/buffers/#Jusdl.Utilities.LinearMode","page":"Buffer","title":"Jusdl.Utilities.LinearMode","text":"LinearMode <: BufferMode\n\nAbstract type of linear buffer modes. See Normal, Lifo, Fifo\n\n\n\n\n\n","category":"type"},{"location":"manual/buffers/#Jusdl.Utilities.CyclicMode","page":"Buffer","title":"Jusdl.Utilities.CyclicMode","text":"CyclicMode <: BufferMode\n\nAbstract type of cyclic buffer modes. See Cyclic\n\n\n\n\n\n","category":"type"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"There are four different buffer modes.","category":"page"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"Normal\nCyclic\nLifo \nFifo","category":"page"},{"location":"manual/buffers/#Jusdl.Utilities.Normal","page":"Buffer","title":"Jusdl.Utilities.Normal","text":"Normal <: LinearMode\n\nLinearMode buffer mode. The data is written to buffer until the buffer is full. When it is full, no more data is written to the buffer. When read, the data written last is returned and the returned data is not deleted from the internal container of the buffer. \n\n\n\n\n\n","category":"type"},{"location":"manual/buffers/#Jusdl.Utilities.Cyclic","page":"Buffer","title":"Jusdl.Utilities.Cyclic","text":"Cyclic <: CyclicMode\n\nCyclic buffer mode. The data is written to buffer until the buffer is full. When the buffer is full, new data is written by overwriting the data available in the buffer starting from the beginning of the buffer. When the buffer is read, the element written last is returned and the returned element is not deleted from the buffer.\n\n\n\n\n\n","category":"type"},{"location":"manual/buffers/#Jusdl.Utilities.Lifo","page":"Buffer","title":"Jusdl.Utilities.Lifo","text":"Lifo <: LinearMode\n\nLifo (Last-in-first-out) buffer mode. This type of buffer is a last-in-first-out buffer. Data is written to the buffer until the buffer is full. When the buffer is full, no more element can be written into the buffer. When read, the last element written into buffer is returned. The returned element is deleted from the buffer.\n\n\n\n\n\n","category":"type"},{"location":"manual/buffers/#Jusdl.Utilities.Fifo","page":"Buffer","title":"Jusdl.Utilities.Fifo","text":"Fifo <: LinearMode\n\nFifo (First-in-last-out) buffer mode. This type of buffer is a first-in-first-out buffer. The data is written to the buffer until the buffer is full. When the buffer is full, no more element can be written into the buffer. When read, the first element written into the buffer is returned. The returned element is deleted from the buffer. \n\n\n\n\n\n","category":"type"},{"location":"manual/buffers/#Buffer-Constructors-1","page":"Buffer","title":"Buffer Constructors","text":"","category":"section"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"The Buffer construction is very similar to the construction of arrays in Julia. Just specify the mode, element type and length of the buffer. Here are the main Buffer constructors: ","category":"page"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"Buffer","category":"page"},{"location":"manual/buffers/#Jusdl.Utilities.Buffer","page":"Buffer","title":"Jusdl.Utilities.Buffer","text":"Buffer{M}(::Type{T}, ln::Int) where {M, T}\n\nConstructs a Buffer of length ln with element type of T. M is the mode of the Buffer that determines how data is to read from and written into the Buffer.  There exists for different buffer modes: \n\nNormal: See Normal\nCyclic: See Cyclic\nLifo: See Lifo\nFifo: See Fifo\n\nThe default mode for Buffer is Cyclic and default element type is Float64.\n\nBuffer(::Type{T}, ln::Int) where T\n\nConstructs a Buffer of length ln and with element type of T. The mode of the buffer is Cyclic.\n\nBuffer{M}(ln::Int) where M\n\nConstructs a Buffer of length of ln and with mode M. M can be Normal, Cyclic, Fifo and Lifo. The element type of the Buffer is Float64.\n\nBuffer(ln::Int)\n\nConstructs a Buffer of length ln with mode Cyclic and element type of Float64.\n\n\n\n\n\n","category":"type"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"warning: Warning\nNote that Buffer is one dimensional. That is, the length of the data must be specified when constructing a Buffer. ","category":"page"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"warning: Warning\nNote that when a Buffer is initialized, the internal data of the Buffer is of missing. ","category":"page"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"Let us try some examples. Here are some simple buffer construction.","category":"page"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"using Jusdl # hide\nbuf1 = Buffer{Normal}(Float64, 5)   # Buffer of length `5` with mode `Normal` and element type of `Float64`. \nbuf2 = Buffer{Fifo}(Int, 3)       # Buffer of length `5` with mode `Fifo` and element type of `Int`. \nbuf3 = Buffer(Vector{Int}, 3)       # Buffer of length `5` with mode `Cyclic` and element type of `Vector{Int}`. \nbuf4 = Buffer(Matrix{Float64}, 5)    # Buffer of length `5` with mode `Cyclic` and element type of `Matrix{Float64}`. \nbuf5 = Buffer(5)                    # Buffer of length `5` with mode `Cyclic` and element type of `Float64`.","category":"page"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"Note that the element type of Buffer can be any Julia type, even any user-defined type. Note the following example, ","category":"page"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"using Jusdl #hide \nstruct Object end       # Define a dummy type. \nbuf = Buffer{Normal}(Object, 4)  # Buffer of length `4` with element type `Object`.","category":"page"},{"location":"manual/buffers/#Writing-Data-into-Buffers-1","page":"Buffer","title":"Writing Data into Buffers","text":"","category":"section"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"Writing data into a Buffer is done with write! function.","category":"page"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"write!","category":"page"},{"location":"manual/buffers/#Jusdl.Utilities.write!","page":"Buffer","title":"Jusdl.Utilities.write!","text":"write!(buf::Buffer{M, T}, val) where {M, T}\n\nWrites val into buf. Writing is carried occurding the mode M of buf. See Normal, Cyclic, Lifo, Fifo for buffer modes. \n\nExample\n\njulia> buf = Buffer(3)\nBuffer(mode:Cyclic, eltype:Union{Missing, Float64}, length:3, index:1, state:empty)\n\njulia> buf.data  # Initailly all the elements of `buf` is missing.\n3-element Array{Union{Missing, Float64},1}:\n missing\n missing\n missing\n\njulia> write!(buf, 3.)\n3.0\n\njulia> buf.data\n3-element Array{Union{Missing, Float64},1}:\n 3.0     \n  missing\n  missing\n\n\n\n\n\n","category":"function"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"Recall that when the buffer is full, no more data can be written into the buffer if the buffer mode is of type LinearMode. ","category":"page"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"using Jusdl # hide\nnormalbuf = Buffer{Normal}(3)\nfill!(normalbuf, 1.)\nnormalbuf.data \nwrite!(normalbuf, 1.)","category":"page"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"This situation is the same for Lifo and Fifo buffers, but not the case for Cyclic buffer. ","category":"page"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"using Jusdl # hide\nnormalbuf = Buffer{Cyclic}(3)\nfill!(normalbuf, 1.)\nnormalbuf.data \nwrite!(normalbuf, 3.)\nwrite!(normalbuf, 4.)","category":"page"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"warning: Warning\nSince when a Buffer is constructed, it is empty, no data is written to it. But it is initialized with missing data. Thus, the element type of buffer of type Buffer{M, T} where {M, T} is Union{Missing, T} where T. Benchmarks that has been carried out shows that there is no performance bottle neck is such design since Julia's compiler can compile optimized code for such a small unions. Therefore it is possible to write missing into a buffer of type Buffer{M,T} where {M,T}.","category":"page"},{"location":"manual/buffers/#Reading-Data-from-Buffers-1","page":"Buffer","title":"Reading Data from Buffers","text":"","category":"section"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"Reading data from a Buffer is done with read function.","category":"page"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"read","category":"page"},{"location":"manual/buffers/#Base.read","page":"Buffer","title":"Base.read","text":"read(buf::Buffer)\n\nReads an element from buf. Reading is performed according to the mode of buf. See Normal, Cyclic, Lifo, Fifo for buffer modes. \n\nExample\n\njulia> buf = Buffer{Fifo}(3)\nBuffer(mode:Fifo, eltype:Union{Missing, Float64}, length:3, index:1, state:empty)\n\njulia> for val in 1 : 3. \n       write!(buf, val)\n       @show buf.data\n       end \nbuf.data = Union{Missing, Float64}[1.0, missing, missing]\nbuf.data = Union{Missing, Float64}[1.0, 2.0, missing]\nbuf.data = Union{Missing, Float64}[1.0, 2.0, 3.0]\n\njulia> for i in 1 : 3 \n       item = read(buf)\n       @show (item, buf.data)\n       end\n(item, buf.data) = (1.0, Union{Missing, Float64}[2.0, 3.0, missing])\n(item, buf.data) = (2.0, Union{Missing, Float64}[3.0, missing, missing])\n(item, buf.data) = (3.0, Union{Missing, Float64}[missing, missing, missing])\n\n\n\n\n\n","category":"function"},{"location":"manual/buffers/#AbstractArray-Interface-of-Buffers-1","page":"Buffer","title":"AbstractArray Interface of Buffers","text":"","category":"section"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"A Buffer can be indexed using the similar syntax of arrays in Julia. That is, getindex and setindex! methods can be used with known Julia syntax. i.e. getindex(buf, idx) is equal to buf[idx] and setindex(buf, val, idx) is equal to buf[idx] = val.","category":"page"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"using Jusdl  # hide\nbuf = Buffer(5)\nsize(buf)\nlength(buf)\nfor val in 1 : 5 \n    write!(buf, 2val)\nend \nbuf[1]\nbuf[3:4]\nbuf[[3, 5]]\nbuf[end]\nbuf[1] = 5 \nbuf[3:5] = [7, 8, 9]","category":"page"},{"location":"manual/buffers/#Full-API-1","page":"Buffer","title":"Full API","text":"","category":"section"},{"location":"manual/buffers/#","page":"Buffer","title":"Buffer","text":"fill!\nisempty\nisfull\ncontent","category":"page"},{"location":"manual/buffers/#Base.fill!","page":"Buffer","title":"Base.fill!","text":"fill!(buf::Buffer{M, T}, val::T) where {M,T}\n\nWrites val into buf until buf is full.\n\n\n\n\n\n","category":"function"},{"location":"manual/buffers/#Base.isempty","page":"Buffer","title":"Base.isempty","text":"isempty(buf::Buffer)\n\nReturns true if buf is empty.\n\n\n\n\n\n","category":"function"},{"location":"manual/buffers/#Jusdl.Utilities.isfull","page":"Buffer","title":"Jusdl.Utilities.isfull","text":"isfull(buf::Buffer)\n\nReturns true if buf is full.\n\n\n\n\n\n","category":"function"},{"location":"manual/buffers/#Jusdl.Utilities.content","page":"Buffer","title":"Jusdl.Utilities.content","text":"content(buf, [flip=true])\n\nReturns the current data of buf. If flip is true, the data to be returned is flipped. \n\n\n\n\n\n","category":"function"},{"location":"#Jusdl-1","page":"Jusdl","title":"Jusdl","text":"","category":"section"},{"location":"#","page":"Jusdl","title":"Jusdl","text":"This is the official documentation of Jusdl that enables fast and effective systems simulations together with online and offline data analysis. In Jusdl, it is possible to simulate discrete time and continuous time, static or dynamical systems. In particular, it is possible to simulate dynamical systems modeled by different types of differential equations such as ODE (Ordinary Differential Equation), Random Ordinary Differential Equation (RODE), SDE (Stochastic Differential Equation), DDE (Delay Differential Equation) and DAE (Differential Algebraic Equation), and discrete difference equations. During the simulation, the data flowing through the links of the model can processed online and offline and specialized analyzes can be performed. These analyzes can also be enriched with plugins that can easily be defined using the standard Julia library or various Julia packages. The simulation is done with the parallel evolution of the model components individually and sampling sampling time intervals. The individual evolution of the components allows the simulation of the models including the components that are represented by different kinds of mathematical equations while the parallel evolution of components increases the simulation speed. ","category":"page"},{"location":"#Table-of-Contents-1","page":"Jusdl","title":"Table of Contents","text":"","category":"section"},{"location":"#","page":"Jusdl","title":"Jusdl","text":"Pages = [\n    \"manual/callback.md\"\n    \"manual/buffers.md\"\n    ]","category":"page"},{"location":"manual/callback/#Callback-1","page":"Callback","title":"Callback","text":"","category":"section"},{"location":"manual/callback/#","page":"Callback","title":"Callback","text":"DocTestSetup  = quote\n    using Jusdl\nend","category":"page"},{"location":"manual/callback/#","page":"Callback","title":"Callback","text":"Callbacks are used to monitor the existence of a specific events and if that specific event occurs, some other special jobs are invoked. Callbacks are intended to provide additional monitoring capability to any user-defined composite types. As such, Callbacks are generaly fields of user defined composite types objects. When a Callback is called, if the Callback is enabled and its condition function returns true, then its action function is invoked. ","category":"page"},{"location":"manual/callback/#A-Simple-Example-1","page":"Callback","title":"A Simple Example","text":"","category":"section"},{"location":"manual/callback/#","page":"Callback","title":"Callback","text":"Let's define a test object first that has a field named x of type Int and named callback of type Callback. ","category":"page"},{"location":"manual/callback/#","page":"Callback","title":"Callback","text":"julia> mutable struct TestObject\n       x::Int\n       callback::Callback\n       end","category":"page"},{"location":"manual/callback/#","page":"Callback","title":"Callback","text":"To construct an instance of TestObject, we need to construct a Callback. For that purpose, condition and action function must be defined. For this example, condition checks whether the x field is positive, and action prints a simple message saying that the x field is positive.","category":"page"},{"location":"manual/callback/#","page":"Callback","title":"Callback","text":"julia> condition(testobject) = testobject.x > 0 \ncondition (generic function with 1 method)\n\njulia> action(testobject) = println(\"testobject.x is greater than zero\") \naction (generic function with 1 method)","category":"page"},{"location":"manual/callback/#","page":"Callback","title":"Callback","text":"Now a test object can be constructed","category":"page"},{"location":"manual/callback/#","page":"Callback","title":"Callback","text":"julia> testobject = TestObject(-1, Callback(condition, action))  \nTestObject(-1, Callback{typeof(condition),typeof(action)}(condition, action, true, \"dac6f9eb-6daa-4622-a8fa-623f0f88780c\"))","category":"page"},{"location":"manual/callback/#","page":"Callback","title":"Callback","text":"If the callback is called, no action is performed since the condition function returns false. Note the argument sent to the callback. The instance of the TestObject to which the callback is a bound.","category":"page"},{"location":"manual/callback/#","page":"Callback","title":"Callback","text":"julia> testobject.callback(testobject) ","category":"page"},{"location":"manual/callback/#","page":"Callback","title":"Callback","text":"Now mutate the test object so that condition returns true.","category":"page"},{"location":"manual/callback/#","page":"Callback","title":"Callback","text":"julia> testobject.x = 3   \n3","category":"page"},{"location":"manual/callback/#","page":"Callback","title":"Callback","text":"Now, if the callback is called, since the condition returns true and the callback is enabled, the action is invoked.","category":"page"},{"location":"manual/callback/#","page":"Callback","title":"Callback","text":"julia> testobject.callback(testobject) \ntestobject.x is greater than zero","category":"page"},{"location":"manual/callback/#Full-API-1","page":"Callback","title":"Full API","text":"","category":"section"},{"location":"manual/callback/#","page":"Callback","title":"Callback","text":"Callback\nenable!\ndisable!\nisenabled\naddcallback\ndeletecallback","category":"page"},{"location":"manual/callback/#Jusdl.Utilities.Callback","page":"Callback","title":"Jusdl.Utilities.Callback","text":"Callback(condition, action)\n\nConstructs a Callback from condition and action. The condition and action must be a single-argument functions. condition returns true if the condition it checks occurs, otherwise ite returns false. action is performs the specific action for which the Callback the callback is contructed. A Callback can be called by passing its single argument which is mostly bound to the Callback.\n\nExample\n\njulia> struct Object  # Define a dummy type.\n       x::Int \n       clb::Callback \n       end \n\njulia> cond(obj) = obj.x > 0  # Define callback condition.\ncond (generic function with 1 method)\n\njulia> action(obj) = println(\"Printing the object \", obj) # Define callback action.\naction (generic function with 1 method)\n\njulia> obj = Object(1, Callback(cond, action))  # Construct an `Object` instance with `Callback`.\nObject(1, Callback(condition:cond, action:action))\n\njulia> obj.clb(obj)  # Call the callback bound `obj`.\nPrinting the object Object(1, Callback(condition:cond, action:action))\n\n\n\n\n\n","category":"type"},{"location":"manual/callback/#Jusdl.Utilities.enable!","page":"Callback","title":"Jusdl.Utilities.enable!","text":"enable!(clb::Callback)\n\nEnables clb.\n\n\n\n\n\n","category":"function"},{"location":"manual/callback/#Jusdl.Utilities.disable!","page":"Callback","title":"Jusdl.Utilities.disable!","text":"disable!(clb::Callback)\n\nDisables clb.\n\n\n\n\n\n","category":"function"},{"location":"manual/callback/#Jusdl.Utilities.isenabled","page":"Callback","title":"Jusdl.Utilities.isenabled","text":"isenabled(clb::Callback)\n\nReturns true if clb is enabled. Otherwise, returns false.\n\n\n\n\n\n","category":"function"},{"location":"manual/callback/#Jusdl.Utilities.addcallback","page":"Callback","title":"Jusdl.Utilities.addcallback","text":"addcallback(obj, clb::Callback, priority::Int)\n\nAdds clb to callback vector of obj which is assumed the have a callback list which is a vector of callback.\n\nExample\n\njulia> mutable struct Object \n       x::Int \n       callbacks::Vector{Callback}\n       Object(x::Int) = new(x, Callback[])\n       end \n\njulia> obj = Object(5)\nObject(5, Callback[])\n\njulia> condition(val) = val.x == 5\ncondition (generic function with 1 method)\n\njulia> action(val) = @show val.x \naction (generic function with 1 method)\n\njulia> addcallback(obj, Callback(condition, action))\nObject(5, Callback[Callback(condition:condition, action:action)])\n\njulia> obj.callbacks(obj)\nval.x = 5\n\n\n\n\n\n","category":"function"},{"location":"manual/callback/#Jusdl.Utilities.deletecallback","page":"Callback","title":"Jusdl.Utilities.deletecallback","text":"deletecallback(obj, idx::Int)\n\nDeletes the one of the callbacks of obj at index idx.\n\njulia> struct Object \n       x::Int \n       callbacks::Vector{Callback}\n       end\n\njulia> clb1 = Callback(val -> true, val -> nothing);\n\njulia> clb2 = Callback(val -> false, val -> nothing);\n\njulia> obj = Object(5, [clb1, clb2]);\n\njulia> deletecallback(obj, 2);\n\njulia> length(obj.callbacks) == 1\ntrue\n\n\n\n\n\n","category":"function"}]
}
