
defmodule Radio do

	def locations do
		%{
			"RMF FM" 	=> "/home/michal/Documents/radio/rmffm.pls",
			"RMF MAXXX" => "/home/michal/Documents/radio/rmfmaxxx.pls"
		}
	end

	def gen do
		locations
			|> Enum.map(fn {t,f} -> {t, Parser.parse f} end)
			|> Enum.map(fn {t,f} -> {t, Enum.find(f, &Checker.check/1)} end)
			|> Enum.filter(fn {_, f} -> f != nil end)
			|> Enum.map(fn {t,f} -> %{title: t, file: f} end)
			|> Builder.build
			|> IO.inspect
			|> IO.puts
	end
end
