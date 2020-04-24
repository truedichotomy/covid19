module COVID19
# This code loads COVID19 data from https://github.com/CSSEGISandData/COVID-19
#
# https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series

using CSV, HTTP, DataFrames, Dates

export confirmed, death, recovered, t, lat, lon, country, region

function load_covid19()
    covid19url_confirmed_US = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"
    covid19url_confirmed_global = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
    covid19url_death_US = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv"
    covid19url_death_global = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"
    covid19url_recovered_global = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv"

    covid19path_confirmed_US = ENV["HOME"] * "/Box/Data/COVID19/covid19_confirmed_US.csv"
    covid19path_confirmed_global = ENV["HOME"] * "/Box/Data/COVID19/covid19_confirmed_global.csv"
    covid19path_death_US = ENV["HOME"] * "/Box/Data/COVID19/covid19_death_US.csv"
    covid19path_death_global = ENV["HOME"] * "/Box/Data/COVID19/covid19_death_global.csv"
    covid19path_recovered_global = ENV["HOME"] * "/Box/Data/COVID19/covid19_recovered_global.csv"

    download(covid19url_confirmed_US, covid19path_confirmed_US)
    download(covid19url_confirmed_global, covid19path_confirmed_global)
    download(covid19url_death_US, covid19path_death_US)
    download(covid19url_death_global, covid19path_death_global)
    download(covid19url_recovered_global, covid19path_recovered_global)



#=     io = open(covid19path_confirmed, "w")
    r = HTTP.request("GET", covid19url_confirmed, response_stream=io)
    close(io)
    io = open(covid19path_death, "w")
    r = HTTP.request("GET", covid19url_death, response_stream=io)
    close(io)
    io = open(covid19path_recovered, "w")
    r = HTTP.request("GET", covid19url_recovered, response_stream=io)
    close(io) =#

    confirmed_US = CSV.read(covid19path_confirmed_US);
    death_US = CSV.read(covid19path_death_US);
    confirmed_global = CSV.read(covid19path_confirmed_global);
    death_global = CSV.read(covid19path_death_global);
    recovered_global = CSV.read(covid19path_recovered_global);

    return confirmed_US, death_US, confirmed_global, death_global, recovered_global
end
(confirmed_US,death_US, confirmed_global, death_global, recovered_global) = load_covid19()

t0 = Date("2020-01-22")
ndays = Dates.today() - t0;
t = collect(t0 : Day(1) : Dates.today());

lat = confirmed_global.Lat;
lon = confirmed_global.Long;
country = confirmed_global[:,2];
region = confirmed_global[:,3];

end
