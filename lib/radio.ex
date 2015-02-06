
defmodule Radio do

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

	@infty 999999999
	def generate(
			playlists 	\\ Application.get_env(:radio, :playlists),
			timeout 	\\ Application.get_env(:radio, :timeout)
		) do

		# these crappy streams are slow as fuck
		# only rmfon services respond in <200ms

		playlists

			|> Enum.map(fn {title, location} ->
				{title, Task.async fn -> grab_stream(location, timeout) end }
			end)
			|> Enum.map(fn {title, task} ->
				{title, Task.await(task, @infty) }
			end)
			|> Enum.filter(fn {t, f} ->
				case f do
					{:ok, _} -> true
					{:error, r} ->
						Logger.log(:error, "#{t}: #{r}")
						false
				end
			end)
			|> Enum.map(fn {t,{:ok,f}} -> %{title: t, file: f} end)
			|> Builder.build
	end
end
