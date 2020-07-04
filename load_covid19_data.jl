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

## Load COVID-19 Data
import COVID19
(covid19g, covid19us) = COVID19.load_data();

country = [covid19us[i].country for i in 1:length(covid19us)];
fips = [covid19us[i].fips for i in 1:length(covid19us)];
county = [covid19us[i].county for i in 1:length(covid19us)];
state = [covid19us[i].province_state for i in 1:length(covid19us)];
ustate = unique(state);

## Load CENSUS TIGER/Line Shapefile Data
function load_county_data(countyshppath = "/Users/gong/Box/Data/CENSUS/tl_2019_us_county/tl_2019_us_county.shp")
    return countytable = Shapefile.Table(countyshppath);
end

countytable = load_county_data();
censusfips = countytable.STATEFP .* countytable.COUNTYFP;
aland = countytable.ALAND;
awater = countytable.AWATER;
countyname = countytable.NAME;

mfips = deepcopy(fips);
strfips = string.(fips);
terrind = findall(0 .<= mfips .< 100);
mfips[terrind] = mfips[terrind] .* 1000;
gind = findall(mfips .>= 0);
mfips[gind] = mfips[gind] .+ 100000;
strfips = [string(mfips[i])[2:end] for i in 1:length(mfips)];
statefips = [strfips[i][1:2] for i in 1:length(strfips)];

## Calculating Cases per population/area

## calculate per state and total confirmed for US
tind = 1:length(covid19us[1].confirmed);
t = covid19us[1].time[tind];
totalconfirmed = zeros(length(t));
stateconfirmed = Array{Any}(undef, length(ustate));
for si = 1:length(ustate)
    #display(ustate[si])
    ind = findall((country .== "US") .& (state .== ustate[si]));
    #confirmed = Array{Any}(undef,length(ind));
    confirmed = [Float64.(covid19us[ind[i]].confirmed) for i in 1:length(ind)];
    stateconfirmed[si] = Float64.(deepcopy(confirmed[1]));
    for i = 2:length(confirmed)
        stateconfirmed[si] .= stateconfirmed[si] .+ confirmed[i];
    end
    totalconfirmed .= totalconfirmed .+ stateconfirmed[si];
    #display(totalconfirmed)
end
ind0 = findall(totalconfirmed .== 0);
totalconfirmed[ind0] .= NaN

## calculate per county case counts for specific state
state_of_interest = "Virginia"
ind = findall(state .== state_of_interest);
countyconfirmed = [Float64.(covid19us[ind[i]].confirmed) for i in 1:length(ind)];
statetotalconfirmed = Float64.(deepcopy(countyconfirmed[1]));
for i = 2:length(countyconfirmed)
    statetotalconfirmed .= statetotalconfirmed .+ countyconfirmed[i];
end
ind0 = findall(statetotalconfirmed .== 0);
statetotalconfirmed[ind0] .= NaN;
tindstate = 1:length(covid19us[ind[1]].confirmed);
tstate = covid19us[ind[1]].time[tind];
