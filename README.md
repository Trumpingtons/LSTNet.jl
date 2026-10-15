# LSTNet.jl

LSTNet: long- and short-term patterns in multivariate time series.

Multivariate time series forecasting with LSTNet-Skip (Lai, Chang, Yang and Liu 2018): a convolution, a GRU, a recurrent-skip GRU and an autoregressive highway, translated from the authors' PyTorch code into Lux and tested against it, on any GPU or the CPU; with the evaluation of the article: the 60/20/20 split, the RSE and CORR at horizons 3, 6, 12 and 24.

Article: Lai, G., Chang, W.-C., Yang, Y. and Liu, H. (2018). Modeling long- and short-term temporal patterns with deep neural networks. In SIGIR '18: The 41st International ACM SIGIR Conference on Research and Development in Information Retrieval, 95-104. [doi:10.1145/3209978.3210006](https://doi.org/10.1145/3209978.3210006)

## Usage

```julia
using LSTNet, CSV, Tables, Downloads
url = "https://raw.githubusercontent.com/laiguokun/multivariate-time-series-data/master/exchange_rate/exchange_rate.txt.gz"
exchange = Tables.columntable(CSV.File(take!(Downloads.download(url, IOBuffer())); header = false))  # read into memory, not saved
s = Split(exchange, 24)  # 60/20/20, each series divided by its largest value, forecasts 24 days ahead
f = forecast(LSTNetSkip(SETTINGS["exchange"]), s)  # trains on a GPU if one is loaded (using CUDA, Metal, ...)
evaluate(s, f.test)
table2(exchange, "exchange")  # LSTNet-Skip's columns of the article's Table 2: RSE and CORR, horizons 3, 6, 12, 24
```

## Vignette

[LSTNet: long- and short-term patterns in multivariate time series](vignette/LSTNet.pdf)

## Tests

The tests compute the published tables below from their data and check every printed value, rounded to the digits printed:

- Table 2 (p. 101), Electricity: RSE and CORR of LSTNet-Skip at horizons 3, 6, 12 and 24 (`test/data/targets/electricity.csv`), tested only when named: `Pkg.test("LSTNet"; test_args = ["electricity"])`
- Table 2 (p. 101), Exchange-Rate: RSE and CORR of LSTNet-Skip at horizons 3, 6, 12 and 24 (`test/data/targets/exchange.csv`), tested only when named: `Pkg.test("LSTNet"; test_args = ["exchange"])`
- Table 2 (p. 101), Solar-Energy: RSE and CORR of LSTNet-Skip at horizons 3, 6, 12 and 24 (`test/data/targets/solar.csv`), tested only when named: `Pkg.test("LSTNet"; test_args = ["solar"])`
- Table 2 (p. 101), Traffic: RSE and CORR of LSTNet-Skip at horizons 3, 6, 12 and 24 (`test/data/targets/traffic.csv`), tested only when named: `Pkg.test("LSTNet"; test_args = ["traffic"])`

They also run the tests of `test/crosstest/tests.jl`.

The data, downloaded from its links when the tests run or kept in `test/data/inputs`:

- `electricity`: <https://raw.githubusercontent.com/laiguokun/multivariate-time-series-data/master/electricity/electricity.txt.gz>, Hourly electricity consumption of 321 clients, 2012-2014, from the UCI ElectricityLoadDiagrams20112014 data, as Lai et al. prepared it (laiguokun/multivariate-time-series-data). Fetched, not kept: the repository has no licence.
- `exchange`: <https://raw.githubusercontent.com/laiguokun/multivariate-time-series-data/master/exchange_rate/exchange_rate.txt.gz>, Daily exchange rates of Australia, Britain, Canada, Switzerland, China, Japan, New Zealand and Singapore, 1990-2016 (laiguokun/multivariate-time-series-data). Fetched, not kept: the repository has no licence.
- `solar`: <https://raw.githubusercontent.com/laiguokun/multivariate-time-series-data/master/solar-energy/solar_AL.txt.gz>, Solar power of 137 photovoltaic plants in Alabama every 10 minutes in 2006, from NREL (laiguokun/multivariate-time-series-data). Fetched, not kept: the repository has no licence.
- `traffic`: <https://raw.githubusercontent.com/laiguokun/multivariate-time-series-data/master/traffic/traffic.txt.gz>, Hourly occupancy rates of 862 San Francisco Bay Area freeway sensors, 2015-2016, from the California Department of Transportation's PeMS (laiguokun/multivariate-time-series-data). Fetched, not kept: the repository has no licence.

Run them with `using Pkg; Pkg.test("LSTNet")`.

Made with [Pollis](https://pollis.org).
