using Documenter, Jusdl
# using DocumenterLaTeX

DocMeta.setdocmeta!(Jusdl, :DocTestSetup, :(using Jusdl); recursive=true)

makedocs(
    modules = [Jusdl], 
    sitename = "Jusdl",
    pages = [
        "Home" => "index.md",
        "Utilities" => [
            "manual/utilities/callback.md",
            "manual/utilities/buffers.md"
            ], 
        "Connections" => [
            "manual/connections/link.md",
            "manual/connections/bus.md",
            ],
        "Components" => [
            "Sources" => [
                "manual/components/sources/clock.md",
                "manual/components/sources/generators.md",
                ],
            "Sinks" => [
                "manual/components/sinks/sinks.md",
                "manual/components/sinks/writer.md",
                "manual/components/sinks/printer.md",
                "manual/components/sinks/scope.md",
                ],
            "Systems" => [
                "StaticSystems" => [
                    "StaticSystems" => "manual/components/systems/staticsystems/staticsystems.md",
                    "Subsystem" => "manual/components/systems/staticsystems/subsystem.md",
                    "Network" => "manual/components/systems/staticsystems/network.md",
                    ],
                "DynamicSystems" => [
                    "DiscreteSystem" => "manual/components/systems/dynamicsystems/discretesystem.md",
                    "ODESystem" => "manual/components/systems/dynamicsystems/odesystem.md",
                    "DAESystem" => "manual/components/systems/dynamicsystems/daesystem.md",
                    "RODESystem" => "manual/components/systems/dynamicsystems/rodesystem.md",
                    "SDESystem" => "manual/components/systems/dynamicsystems/sdesystem.md",
                    "DDESystem" => "manual/components/systems/dynamicsystems/ddesystem.md",
                    ],
                ],
            ],
        "Plugins" => "manual/plugins/plugins.md",
        "Models" => [
            "manual/models/taskmanager.md",
            "manual/models/simulation.md",
            "manual/models/model.md",
            ],
    ],
    # format=DocumenterLaTeX.LaTeX()  # Uncomment this option to generate pdf output.
)  # end makedocs
