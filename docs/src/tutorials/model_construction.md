# Models and Graphs 

This tutorial illustrates the relation relation between models and graphs. A model consists of components and connections. These components and connections can be associated with a signal-flow graph signifying the topology of the model. In the realm of graph theory, components and connections of a model are associated with nodes and branches of the signal-flow graph. As the model is modified by adding or deleting components or connections, the signal-flow graph of the model is modified accordingly to keep track of topological modifications. By associating a signal-flow graph to a model, any graph-theoretical analysis can be performed. An example to such an analysis is the determination and braking of algebraic loops. 

## [Construction of Models](@id section_header)
In this tutorial, we construct the model with the following block diagram
```@raw html
<center>
    <img src="../../assets/SimpleModel/simplemodel.svg" alt="model" width="60%"/>
</center>
```
and with the following signal-flow graph 
```@raw html
<center>
    <img src="../../assets/SignalFlow/signalflow.svg" alt="model" width="50%"/>
</center>
```

Let's start with an empty [`Model`](@ref).
```@repl model_graph_example 
using Jusdl # hide 
model = Model()
```
We constructed an empty model, i.e., the model has no components and connections. To modify the model, we need to add components and connections to the model. As the model is grown by adding components and connections, the components and connections are added into the model as nodes and branches (see [`Node`](@ref), [`Branch`](@ref)).  Let's add our first component, a [`SinewaveGenerator`](@ref) to the `model`.
```@repl model_graph_example
addnode(model, SinewaveGenerator(), label=:gen)
```
To add components to the `model`, we use [`addnode`](@ref) function. As seen, our node consists of a component, an index, and a label. 
```@repl model_graph_example
node1 = model.nodes[1]
node1.component
node1.idx 
node1.label 
```
Let us add another component, a [`Adder`](@ref), to the model, 
```@repl model_graph_example
addnode(model, Adder((+,-)), label=:adder)
```
and investigate our new node.
```@repl model_graph_example
node2 = model.nodes[2] 
node2.component 
node2.idx
node2.label
```
Note that as new nodes are added to the `model`, they are given an index `idx` and a label `label`. The label is not mandatory, if not specified explicitly, `nothing` is assigned as label. The reason to add components as nodes is to access them through their node index `idx` or `labels`. For instance, we can access our first node by using its node index `idx` or node label `label`. 
```@repl model_graph_example
getnode(model, :gen)    # Access by label
getnode(model, 1)       # Access by index
```
At this point, we have two nodes in our model. Let's add two more nodes, a [`Gain`](@ref) and a [`Writer`](@ref)
```@repl model_graph_example
addnode(model, Gain(), label=:gain)
addnode(model, Writer(), label=:writer)
```
As the nodes are added to the `model`, its graph is modified accordingly.
```@repl model_graph_example
model.graph
```

`model` has no connections. Let's add our first connection by connecting the first pin of the output port of the node 1 (which is labelled as `:gen`) to the first input pin of input port of node 2 (which is labelled as `:adder`). 
```@repl model_graph_example
addbranch(model, :gen => :adder, 1 => 1)
```
The node labelled with `:gen` has an output port having one pin, and the node labelled with `:adder` has an input port of two pins. In our first connection, we connected the first(and the only) pin of the output port of the node labelled with `:gen` to the first pin of the input port of the node labelled with `:adder`.  The connections are added to model as branches, 
```@repl model_graph_example
model.branches
```
A branch between any pair of nodes can be accessed through the indexes or labels of nodes. 
```@repl model_graph_example
br = getbranch(model, :gen => :adder)
br.nodepair 
br.indexpair 
br.links
```
Note the branch `br` has one link(see [`Link`](@ref)). This is because we connected one pin to another pin. The branch that connects ``n`` pins to each other has `n` links. Let us complete the construction of the model by adding other connections. 
```@repl model_graph_example
addbranch(model, :adder => :gain, 1 => 1)
addbranch(model, :gain => :adder, 1 => 2)
addbranch(model, :gain => :writer, 1 => 1)
```

## Usage of Signal-Flow Graph 
The signal-flow graph constructed alongside of the construction of the model can be used to perform any topological analysis. An example to such an analysis is the detection of algebraic loops. For instance, our model in this tutorial has an algebraic loop consisting of the nodes labelled with `:gen` and `gain`. This loop can be detected using the signal-flow graph of the node 
```@repl model_graph_example
loops = getloops(model)
```
We have one loop consisting the nodes with indexes 2 and 3. 

For further analysis on model graph, we use [`LightGraphs`](https://juliagraphs.org/LightGraphs.jl/stable/) package.
```@repl model_graph_example
using LightGraphs 
graph = model.graph 
```
For example, the adjacency matrix of model graph can be obtained. 
```@repl model_graph_example
adjacency_matrix(model.graph)
```
or inneighbors or outneighbors of a node can be obtained.
```@repl model_graph_example
inneighbors(model.graph, getnode(model, :adder).idx)
outneighbors(model.graph, getnode(model, :adder).idx)
```
