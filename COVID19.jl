module COVID19
# This code loads COVID19 data from https://github.com/CSSEGISandData/COVID-19
#
# https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv
# https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv
# https://github.com/CSSEGISandData/COVID-19/blob/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv

using CSV, HTTP

export confirmed, death, recovered

function load_covid19()
    covid19url_confirmed = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Confirmed.csv"
    covid19url_death = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Deaths.csv"
    covid19url_recovered = "https://raw.githubusercontent.com/CSSEGISandData/COVID-19/master/csse_covid_19_data/csse_covid_19_time_series/time_series_19-covid-Recovered.csv"

    covid19path_confirmed = ENV["HOME"] * "/Box/Data/COVID19/covid19_confirmed.csv"
    covid19path_death = ENV["HOME"] * "/Box/Data/COVID19/covid19_death.csv"
    covid19path_recovered = ENV["HOME"] * "/Box/Data/COVID19/covid19_recovered.csv"

    io = open(covid19path_confirmed, "w")
    r = HTTP.request("GET", covid19url_confirmed, response_stream=io)
    close(io)
    io = open(covid19path_death, "w")
    r = HTTP.request("GET", covid19url_death, response_stream=io)
    close(io)
    io = open(covid19path_recovered, "w")
    r = HTTP.request("GET", covid19url_recovered, response_stream=io)
    close(io)

    confirmed = CSV.read(covid19path_confirmed);
    death = CSV.read(covid19path_death);
    recovered = CSV.read(covid19path_recovered);

    return confirmed, death, recovered
end

(confirmed,death,recovered) = load_covid19()

end
