
defmodule Radio do

	def locations do
		%{
			"RMF FM" 	=> "/home/michal/Documents/radio/nuked_rmffm.pls",
			"RMF MAXXX" => "/home/michal/Documents/radio/nuked_rmfmaxxx.pls"
		}
	end

	def gen(timeout \\ 200) do
		locations
			|> Enum.map(fn {t,f} -> {t, Parser.parse f} end)
			|> Enum.map(fn {t,f} -> {t, async_check(f, timeout) } end)
			|> Enum.map(fn {t,f} -> {t, await_check(f, timeout) } end)
			|> Enum.filter(fn {t, f} ->
					if f == nil, do: (IO.puts "#{t} unreachable!")
					f != nil
				end)
			|> Enum.map(fn {t,f} -> %{title: t, file: f} end)
			|> Builder.build
			# |> IO.inspect
			|> IO.puts
	end

	defp async_check(urls, timeout) do
		Task.async fn ->
			urls |> Enum.find &(Checker.check(&1, timeout))
		end
	end

	defp await_check(task, timeout) do
		Task.await(task, 2*timeout)
	end
end
