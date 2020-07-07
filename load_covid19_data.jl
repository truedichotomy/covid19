#using Pkg
#Pkg.activate(ENV["HOME"] * "/.julia/environments/" * "covid19")
if (ENV["HOME"] * "/GitHub/covid19" in LOAD_PATH) == false
    push!(LOAD_PATH, pwd());
end

#Pkg.update()
#ENV["PYTHON"] = ENV["CONDA_PYTHON_EXE"]
#]add CSV HTTP GitHub DataFrames PyCall PyPlot Plots Dates Statistics TimeSeries MLJ XGBoost Measurements LsqFit NCDatasets Glob JSON3 Tables Pandas FileIO CSVFiles Missings JLD2 OnlineStats CUDAnative CuArrays
#Pkg.build("PyCall")

using Plots, Statistics, Shapefile, WebIO, DataFrames, Glob
plotly()

## Load CENSUS TIGER/Line Shapefile Data
function load_county_data(countyshppath = "/Users/gong/Box/Data/CENSUS/tl_2019_us_county/tl_2019_us_county.shp")
    return countytable = Shapefile.Table(countyshppath);
end

## Load COVID-19 Data
import COVID19
(covid19g, covid19us) = COVID19.load_data();

country = [covid19us[i].country for i in 1:length(covid19us)];
fips = [covid19us[i].fips for i in 1:length(covid19us)];
county = [covid19us[i].county for i in 1:length(covid19us)];
state = [covid19us[i].province_state for i in 1:length(covid19us)];
ustate = unique(state);
mfips = deepcopy(fips);
strfips = string.(fips);
terrind = findall(0 .<= mfips .< 100);
mfips[terrind] = mfips[terrind] .* 1000;
gind = findall(mfips .>= 0);
mfips[gind] = mfips[gind] .+ 100000;
strfips = [string(mfips[i])[2:end] for i in 1:length(mfips)];
statefips = [strfips[i][1:2] for i in 1:length(strfips)];

countytable = load_county_data();
ctcensusfips = countytable.STATEFP .* countytable.COUNTYFP;
ctaland = countytable.ALAND;
ctawater = countytable.AWATER;
ctname = countytable.NAME;

countyarea = zeros(length(strfips));
for i = 1:length(strfips)
    if parse(Int,strfips[i][1:2]) <= 59
        fipsind = findall(strfips[i] .== ctcensusfips);
        countyarea[i] = ctaland[fipsind[1]];
    end
end

## Calculating Cases per population/area
#strfips[1:end-110] .* state[1:end-110]
#sort(censusfips)[1:end-90]