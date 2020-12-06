import COVID19
COVID19.load_data_from_web();
include("load_covid19_data.jl")
include("plot_covid19.jl")
include("map_covid19.jl")
include("map_covid19_animate.jl")