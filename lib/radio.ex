
defmodule Radio do
	@moduledoc ~S"""
	Provides function for creating playlist with online streams.
	"""

	@typep file_handle :: {:ok, pid, (pid -> any)}
	@typep failure :: {:error, :file.posix | :connection_failed | pos_integer}

	@spec open_file(String.t) :: file_handle | failure
	defp open_file(path) when is_binary(path) do
		case Regex.match? ~r|http[s]?://.+|, path do 
			true ->
				case :httpc.request(:get, {to_char_list(path), []}, [], [{:body_format, :binary}]) do
					{:ok, {{_, 200, _}, _headers, body}} when is_binary(body) ->
						{:ok, file} = StringIO.open body
						{:ok, file, &StringIO.close/1}
					{:ok, {{_, code, _}, _, _}} -> {:error, code}
					{:error, _} -> {:error, :connection_failed}
				end
			false ->
				# assume its local
				case File.open path, [{:encoding, :utf8}] do
					{:ok, file} -> {:ok, file, &File.close/1}
					{:error, r} -> {:error, r}
				end
		end
	end

	@type playlist_location :: {:pls | :m3u, String.t}
	@spec grab_stream(playlist_location, non_neg_integer) :: {:ok, String.t} | failure | {:error, :no_stream}
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

	@doc """
	Generates playlist with online streams.

	Duplicates and offline sources are removed.

	## Examples
	    iex> Radio.generate( %{
	    iex>   "Radio One" => {:pls, "http://radio.com/listen.pls"},
	    iex>   "Radio Two" => {:m3u, "/home/me/Documents/radio.m3u"}
	    iex> }, 2000)
	    "[playlist]\\nNumberOfEntries=2\\nVersion=2\\n[...]"

	"""
	@spec generate(%{String.t => playlist_location}, non_neg_integer) :: String.t
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
						:ok = Logger.log(:error, "#{t}: #{r}")
						false
				end
			end)
			|> Enum.map(fn {t,{:ok,f}} -> %{title: t, file: f} end)
			|> Builder.build
	end
end
