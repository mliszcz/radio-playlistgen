
defmodule Builder do
	import Enum

	@typep playlist_entry :: %{title: String.t, file: String.t}

	@spec build([playlist_entry]) :: String.t
	def build(entries) do
		ent = entries
			|> with_index
			|> map(fn {e,i} -> {e,i+1} end)
			|> map(&format/1)
		~s"""
		[playlist]
		NumberOfEntries=#{length ent}
		Version=2
		#{ent}
		"""
	end

	@spec format({playlist_entry, pos_integer}) :: String.t
	defp format({%{title: t, file: f}, id}) do
		~s"""
		File#{id}=#{f}
		Title#{id}=#{t}
		Length#{id}=-1
		"""
	end

end
