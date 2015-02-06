
defmodule Radio do

	def playlists do
		%{
			"Polskie Radio Program 1" 	=> {:pls, "http://stream3.polskieradio.pl:8900/listen.pls"},
			"Polskie Radio Program 3" 	=> {:pls, "http://stream3.polskieradio.pl:8904/listen.pls"},
			"RMF FM" 					=> {:pls, "http://www.rmfon.pl/n/rmffm.pls"},
			"RMF MAXXX" 				=> {:pls, "http://www.rmfon.pl/n/rmfmaxxx.pls"},
			"Radio ZET" 				=> {:pls, "http://91.121.179.221:8050/listen.pls"},
			"Radio ESKA Kraków" 		=> {:pls, "http://acdn.smcloud.net/t046-1.mp3.pls"},
			"Radio WAWA" 				=> {:pls, "http://acdn.smcloud.net/t050-1.mp3.pls"},
			"KRK.FM" 					=> {:m3u, "http://stream4.nadaje.com:11770/test.m3u"},
			"Radiofonia" 				=> {:pls, "http://www.rmfon.pl/n/radiofonia.pls"},
			# "Radio Złote Przeboje" 		=> {:pls, "http://www.radio.pionier.net.pl/stream.pls?radio=radio88"} # seems to be down
			"Radio Złote Przeboje" 		=> {:pls, "http://www.tuba.fm/stream.pls?radio=9&mp3=1"} # 96 kbps stream
		}
	end

	defp open_file(path) when is_binary(path) do
		path |> to_char_list |> open_file
	end

	defp open_file(path) when is_list(path) do
		case Regex.match? ~r|http[s]?://.+|, to_string(path) do 
			true ->
				case :httpc.request(:get, {path, []}, [], [{:body_format, :binary}]) do
					{:ok, {{_, 200, _}, _headers, body}} ->
						case StringIO.open body, [:utf8] do
							{:ok, file} -> {:ok, file, &StringIO.close/1}
							{:error, r} -> {:error, r}
						end
					{:ok, {{_, code, _}, _, _}} -> {:error, code}
					{:error, _} -> {:error, :connection_failed}
				end
			false ->
				# assume its local
				case File.open path, [:utf8] do
					{:ok, file} -> {:ok, file, &File.close/1}
					{:error, r} -> {:error, r}
				end
		end
	end

	defp grab_stream({tpe, path}, timeout) do

		case open_file path do

			{:ok, file, close} ->

				urls = case tpe do
					:pls -> Parser.PLS.parse file
					:m3u -> Parser.M3U.parse file
				end
				close.(file)

				case urls |> Enum.find &(Checker.check(&1, timeout)) do
					nil -> {:error, :no_stream}
					str -> {:ok, str}
				end

			{:error, e} -> {:error, e}
		end
	end

	@long 999999999
	def gen(timeout \\ 2000) do

		# these crappy streams are slow as fuck
		# only rmfon services respond in <200ms

		playlists

			|> Enum.map(fn {title, location} ->
				{title, Task.async fn -> grab_stream(location, timeout) end }
			end)
			|> Enum.map(fn {title, task} ->
				{title, Task.await(task, @long) }
			end)
			|> Enum.filter(fn {t, f} ->
				case f do
					{:ok, _} -> true
					{:error, r} ->
						IO.puts "#{t}: #{r}"
						false
				end
			end)
			|> Enum.map(fn {t,{:ok,f}} -> %{title: t, file: f} end)
			|> Builder.build
			|> IO.puts
	end
end
