@time include("COVID19.jl")
@time COVID19.load_data_from_web("./");
@time COVID19.load_data_from_nyt("./");
@time include("load_covid19_data.jl")
@time include("plot_covid19.jl")
@time include("map_covid19.jl")
#@time include("map_covid19_animate.jl")