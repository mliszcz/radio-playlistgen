
defmodule Radio do

	def playlists do
		%{
			"Polskie Radio Program 1" 	=> {:pls, "http://stream3.polskieradio.pl:8900/listen.pls"}, # FIXME
			"Polskie Radio Program 3" 	=> {:pls, "http://stream3.polskieradio.pl:8904/listen.pls"}, # FIXME
			"RMF FM" 					=> {:pls, "http://www.rmfon.pl/n/rmffm.pls"},
			"RMF MAXXX" 				=> {:pls, "http://www.rmfon.pl/n/rmfmaxxx.pls"},
			"Radio ZET" 				=> {:pls, "http://91.121.179.221:8050/listen.pls"}, # FIXME obtained stream returns strange page
			"Radio ESKA Kraków" 		=> {:pls, "http://acdn.smcloud.net/t046-1.mp3.pls"},
			"Radio WAWA" 				=> {:pls, "http://acdn.smcloud.net/t050-1.mp3.pls"},
			"KRK.FM" 					=> {:m3u, "http://stream4.nadaje.com:11770/test.m3u"},
			"Radiofonia" 				=> {:pls, "http://www.rmfon.pl/n/radiofonia.pls"},
			"Radio Złote Przeboje" 		=> {:pls, "http://www.radio.pionier.net.pl/stream.pls?radio=radio88"} # FIXME
		}
	end

	defp open_file(path) do
		case Regex.match? ~r|http[s]?://.+|, path do 
			true ->
				try do
					case HTTPotion.get path do
						%{status_code: 200, body: body} ->
							case StringIO.open body, [:utf8] do
								{:ok, file} -> {:ok, file, fn -> StringIO.close file end}
								{:error, r} -> {:error, r}
							end
						%{status_code: code} -> {:error, code}
					end
				rescue
					e in HTTPotion.HTTPError -> {:error, e.message}
				end
			false ->
				# assume its local
				case File.open path, [:utf8] do
					{:ok, file} -> {:ok, file, fn -> File.close file end}
					{:error, r} -> {:error, r}
				end
		end
	end

	def gen(timeout \\ 200) do
		playlists
			|> Enum.map(fn {title, {_tpe, path}} -> {title, {_tpe, open_file path}} end)
			|> Enum.filter(fn {t, {_tpe, f}} ->
					case f do
						{:error, r} ->
							(IO.puts "#{t}: #{inspect r}")
							false
						{:ok, _, _} -> true
					end
				end)
			|> Enum.map(fn {t, {tpe,{:ok, file, close}}} ->
					res = case tpe do
						:pls -> Parser.PLS.parse file
						:m3u -> Parser.M3U.parse file
					end
					IO.puts "parsed #{t}: #{inspect res}"
					close.()
					{t, res}
				end)
			|> Enum.map(fn {t,f} -> {t, async_check(f, timeout) } end)
			|> Enum.map(fn {t,f} -> {t, await_check(f, timeout) } end)
			|> Enum.filter(fn {t, f} ->
					if f == nil, do: (IO.puts "#{t}: no stream!")
					f != nil
				end)
			|> Enum.map(fn {t,f} -> %{title: t, file: f} end)
			|> Builder.build
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
