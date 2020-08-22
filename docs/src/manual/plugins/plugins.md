# Plugins

Plugins are extensions that are used to process online the data flowing through the connections of the model during the simulation. These tools are specialized tools that are used for specialized data processing. In addition to the plugins that are provided by `Causal`, it is also possible to write new plugins that focus on different specialized data processing. The fundamental importance of `Plugin`s is that they make the online simulation data processing possible. 

The `Plugin`s are mostly used with [Sinks](@ref). In `Causal`, the `Sink`s are used to *sink* simulation data flowing through the connections of the model. When a `Sink` is equipped with a proper `Plugin` according to the data processing desired, then the data flowing into the `Sink` is processed. For example, consider that a `Writer` is equipped with a `Lyapunov` plugin. During the simulation, data flowing into the `Writer` is processed to compute the maximum Lyapunov exponent, and these computed maximum Lyapunov exponents are recorded in the file of the `Writer`. Similarly, if a `Printer` is equipped with an `Fft` plugin, then Fast Fourier transform of the data flowing into the `Printer` is printed on the console.

## Data processing via Plugins 
Each `Plugin` must have a `process` function which does the data processing. The first argument of the `process` function is the `Plugin` and the second argument is the data to be processed. Here are some of the methods of `process` function

## Defining New Plugins
New plugins can be defined in `Causal` and having they are defined properly they can work just expected. To define a new plugin, we must first define the plugin type 
```@repl plugin_ex 
using Causal # hide 
struct NewPlugin <: AbstractPlugin
    # Parameters of NewPlugin
end
```

!!! warning
    Note that to the `NewPlugin` is defined to be a subtype of `AbstractPlugin`. This is important for the `NewPlugin` to work as expected.

Since each plugin must have implement a `process` method, and for that  `Causal.process` function must be imported.

```@repl plugin_ex
import Causal.process
function process(plg::NewPlugin, x)
    # Define the process according to plg
end
```
At this point, `NewPlugin` is ready to be used. 

