using Pkg
Pkg.activate(ENV["HOME"] * "/.julia/environments/" * "covid19")
Pkg.add(PackageSpec(url="https://github.com/kouketsu/GSW.jl", rev="master"))
Pkg.add(PackageSpec(url="https://github.com/JuliaGeo/GeoDatasets.jl", rev="master"))
Pkg.add("IJulia"); Pkg.build("IJulia"); using IJulia
Pkg.add("PyPlot")
Pkg.add("PyCall")
Pkg.add("Conda")
Pkg.add("Plots")
Pkg.add("CSV")
Pkg.add("XLSX")
Pkg.add("Glob")
Pkg.add("HTTP")
Pkg.add("DataFrames")
Pkg.add("Missings")
Pkg.add("FileIO")
Pkg.add("JLD2")
Pkg.add("Dates")
Pkg.add("Pandas")
Pkg.add("NCDatasets")
Pkg.add("Statistics")
Pkg.add("NaNMath")
Pkg.add("JSON3")
Pkg.add("OnlineStats")
Pkg.add("TimeSeries")
Pkg.add("Measurements")
Pkg.add("Distances")
Pkg.add("DifferentialEquations")
Pkg.add("BenchmarkTools")
Pkg.add("DelimitedFiles")

#;conda install matplotlib
#;conda install -c conda-forge cmocean gsw
#;conda install --channel conda-forge erddapy

using Conda
#Conda.add("matplotlib")
#Conda.add("cmocean",channel="conda-forge")
#Conda.add("gsw",channel="conda-forge")