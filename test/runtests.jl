# Made by Pollis (Compose > New Methods > Package and Publish) from method.toml: change the method, not this file.
using Test, CSV, Downloads, Tables, LSTNet

const DATA = joinpath(@__DIR__, "data")

"An input table: a file of the tests, or downloaded from its link into memory."
function input(source; delim = ',', columns = nothing, header = true, skipto = nothing, limit = nothing)
	bytes = startswith(source, r"https?://") ? take!(Downloads.download(source, IOBuffer())) : read(joinpath(DATA, source))
	named = columns === nothing && header
	header = columns !== nothing ? Symbol.(columns) : named ? 1 : false
	rows = (; skipto = something(skipto, named ? 2 : 1), limit)
	file = delim == "whitespace" ? CSV.File(bytes; header, rows..., delim = ' ', ignorerepeated = true, stripwhitespace = true) : CSV.File(bytes; header, rows..., delim = delim == "tab" ? '\t' : only(delim))
	return Tables.columntable(file)
end

"The published table: its row labels and its values as printed, `nothing` where a cell is empty."
function target(file)
	table = CSV.File(joinpath(DATA, "targets", file * ".csv"); types = String, delim = ',')
	columns = Tables.columnnames(table)
	rows = [string(coalesce(row[columns[1]], "")) for row in table]
	values = [let cell = row[column]; cell === missing ? nothing : strip(cell) end for row in table, column in columns[2:end]]
	return rows, string.(columns[2:end]), values
end

"Tests each printed value against the result rounded to the digits printed."
function check(result, file, tolerance)
	rows, columns, values = target(file)
	result = result isa AbstractVecOrMat ? result : Tables.matrix(result)
	result = reshape(result, size(result, 1), :)
	@test size(result) == size(values)
	for i in axes(values, 1), j in axes(values, 2)
		printed = values[i, j]
		(printed === nothing || isempty(printed)) && continue
		mantissa, exponent = occursin(r"[eE]", printed) ? split(printed, r"[eE]") : (printed, "0")
		digits = (occursin('.', mantissa) ? length(split(mantissa, '.')[2]) : 0) - parse(Int, exponent)
		published = parse(Float64, printed)
		computed = round(result[i, j]; digits)
		@testset "$(rows[i]), $(columns[j])" begin
			@test isapprox(computed, published; atol = (tolerance + 1e-6) * 10.0^-digits)
		end
	end
end

@testset "LSTNet" begin
	include("crosstest/tests.jl")
	if "electricity" in ARGS
	@testset "Table 2 (p. 101), Electricity: RSE and CORR of LSTNet-Skip at horizons 3, 6, 12 and 24" begin
		electricity = input("https://raw.githubusercontent.com/laiguokun/multivariate-time-series-data/master/electricity/electricity.txt.gz"; header = false)
		check(table2(electricity, "electricity"), "electricity", 100)
	end
	else
		@info "Not tested: Table 2 (p. 101), Electricity: RSE and CORR of LSTNet-Skip at horizons 3, 6, 12 and 24. To test it: Pkg.test(\"LSTNet\"; test_args = [\"electricity\"])"
	end
	if "exchange" in ARGS
	@testset "Table 2 (p. 101), Exchange-Rate: RSE and CORR of LSTNet-Skip at horizons 3, 6, 12 and 24" begin
		exchange = input("https://raw.githubusercontent.com/laiguokun/multivariate-time-series-data/master/exchange_rate/exchange_rate.txt.gz"; header = false)
		check(table2(exchange, "exchange"), "exchange", 100)
	end
	else
		@info "Not tested: Table 2 (p. 101), Exchange-Rate: RSE and CORR of LSTNet-Skip at horizons 3, 6, 12 and 24. To test it: Pkg.test(\"LSTNet\"; test_args = [\"exchange\"])"
	end
	if "solar" in ARGS
	@testset "Table 2 (p. 101), Solar-Energy: RSE and CORR of LSTNet-Skip at horizons 3, 6, 12 and 24" begin
		solar = input("https://raw.githubusercontent.com/laiguokun/multivariate-time-series-data/master/solar-energy/solar_AL.txt.gz"; header = false)
		check(table2(solar, "solar"), "solar", 100)
	end
	else
		@info "Not tested: Table 2 (p. 101), Solar-Energy: RSE and CORR of LSTNet-Skip at horizons 3, 6, 12 and 24. To test it: Pkg.test(\"LSTNet\"; test_args = [\"solar\"])"
	end
	if "traffic" in ARGS
	@testset "Table 2 (p. 101), Traffic: RSE and CORR of LSTNet-Skip at horizons 3, 6, 12 and 24" begin
		traffic = input("https://raw.githubusercontent.com/laiguokun/multivariate-time-series-data/master/traffic/traffic.txt.gz"; header = false)
		check(table2(traffic, "traffic"), "traffic", 100)
	end
	else
		@info "Not tested: Table 2 (p. 101), Traffic: RSE and CORR of LSTNet-Skip at horizons 3, 6, 12 and 24. To test it: Pkg.test(\"LSTNet\"; test_args = [\"traffic\"])"
	end
end
