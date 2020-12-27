include("COVID19.jl")
COVID19.load_data_from_web("./");
COVID19.load_data_from_nyt("./");
include("load_covid19_data.jl")
include("plot_covid19.jl")
include("map_covid19.jl")
include("map_covid19_animate.jl")