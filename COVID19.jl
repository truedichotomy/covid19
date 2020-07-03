module COVID19
# This code loads COVID19 data from https://github.com/CSSEGISandData/COVID-19
#
# COVID19:
# https://github.com/CSSEGISandData/COVID-19/tree/master/csse_covid_19_data/csse_covid_19_time_series
#
# FIPS: 
# https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/UID_ISO_FIPS_LookUp_Table.csv

using CSV, DataFrames, Dates

export load_data_from_web, load_data

mutable struct COVID19data
    country::AbstractString
    province_state::AbstractString
    county::AbstractString
    key::AbstractString
    fips::Int
    lat::AbstractFloat
    lon::AbstractFloat
    population::Int
    time::Array{Date}
    confirmed::Array{Int}
    death::Array{Int}
    #recovered::Array{Int}
end

function load_data_from_web(datadir = ENV["HOME"] * "/Box/Data/COVID19/")
    #datadir = ENV["HOME"] * "/Box/Data/COVID19/";

    # data source: https://github.com/nytimes/covid-19-data
    covid19nyt_url_county = "https://github.com/nytimes/covid-19-data/raw/master/us-counties.csv";
    covid19nyt_url_state = "https://github.com/nytimes/covid-19-data/raw/master/us-states.csv";
    covid19nyt_path_county = datadir * "covid19nyt_county.csv";
    covid19nyt_path_state = datadir * "covid19nyt_state.csv";

    download(covid19nyt_url_county, covid19nyt_path_county);
    download(covid19nyt_url_state, covid19nyt_path_state);

    covid19url_confirmed_US = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"
    covid19url_confirmed_global = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_global.csv"
    covid19url_death_US = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_US.csv"
    covid19url_death_global = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_deaths_global.csv"
    covid19url_recovered_global = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_recovered_global.csv"
    covid19url_fips = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/UID_ISO_FIPS_LookUp_Table.csv"

    covid19path_confirmed_US = datadir * "covid19_confirmed_US.csv"
    covid19path_confirmed_global = datadir * "covid19_confirmed_global.csv"
    covid19path_death_US = datadir * "covid19_death_US.csv"
    covid19path_death_global = datadir * "covid19_death_global.csv"
    covid19path_recovered_global = datadir * "covid19_recovered_global.csv"
    covid19path_fips = datadir * "UID_ISO_FIPS_LookUp_Table.csv"

    download(covid19url_confirmed_US, covid19path_confirmed_US)
    download(covid19url_confirmed_global, covid19path_confirmed_global)
    download(covid19url_death_US, covid19path_death_US)
    download(covid19url_death_global, covid19path_death_global)
    download(covid19url_recovered_global, covid19path_recovered_global)
    download(covid19url_fips, covid19path_fips)

#=     io = open(covid19path_confirmed, "w")
    r = HTTP.request("GET", covid19url_confirmed, response_stream=io)
    close(io)
    io = open(covid19path_death, "w")
    r = HTTP.request("GET", covid19url_death, response_stream=io)
    close(io)
    io = open(covid19path_recovered, "w")
    r = HTTP.request("GET", covid19url_recovered, response_stream=io)
    close(io) =#

    confirmed_US = DataFrame!(CSV.File(covid19path_confirmed_US));
    death_US = DataFrame!(CSV.File(covid19path_death_US));
    confirmed_global = DataFrame!(CSV.File(covid19path_confirmed_global));
    death_global = DataFrame!(CSV.File(covid19path_death_global));
    recovered_global = DataFrame!(CSV.File(covid19path_recovered_global));
    fipstable = DataFrame!(CSV.File(covid19path_fips));

    return confirmed_US, death_US, confirmed_global, death_global, recovered_global, fipstable
end

#function load_covid19(confirmed_US::Any,death_US::Any,confirmed_global::Any,death_global::Any,fipstable::Any)
function load_data(datadir = ENV["HOME"] * "/Box/Data/COVID19/")
    (confirmed_US, death_US, confirmed_global, death_global, recovered_global, fipstable) = load_data_from_web(datadir)

    # defining the time
    t0 = Date("2020-01-22")
    ndays = Dates.today() - t0;
    t = collect(t0 : Day(1) : Dates.today());

    # specifying the first column in the data where the time series start
    c0_global = 5;
    c0_US = 12;

    # loading global COVID19 time series data
    latg = confirmed_global[:,3];
    long = confirmed_global[:,4];
    country = confirmed_global[:,2];
    province_state = collect(Missings.replace(confirmed_global[:,1],""));

    covid19global = COVID19data[];
    for i = 1:size(latg)[1]
        covid19global = push!(covid19global, COVID19data(country[i], province_state[i], "", province_state[i] * " ," * country[i], -9999, latg[i], long[i], -9999, t, confirmed_global[i,5:end], death_global[i,5:end]));
    end

    # loading the US COVID19 time series
    latus = confirmed_US[:,9];
    lonus = confirmed_US[:,10];
    countryUS = confirmed_US[:,8];
    province_stateUS = collect(Missings.replace(confirmed_US[:,7],""));
    fips = collect(Missings.replace(confirmed_US[:,5],-9999));
    county = collect(Missings.replace(confirmed_US[:,6],""));
    key = confirmed_US[:,11];

    covid19us = COVID19data[];
    for i = 1:size(latus)[1]
        covid19us = push!(covid19us, COVID19data(countryUS[i], province_stateUS[i], county[i], key[i], fips[i], latus[i], lonus[i], death_US[i,12], t, confirmed_US[i,12:end], death_US[i,12:end]));
    end

    return covid19global, covid19us
end

# Usage:
#import COVID19
#(covid19g, covid19us) = COVID19.load_data();
end
