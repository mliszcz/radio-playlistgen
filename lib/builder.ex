
defmodule Builder do
	import Enum

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

	defp format({%{title: t, file: f}, id}) do
		~s"""
		File#{id}=#{f}
		Title#{id}=#{t}
		Length#{id}=-1
		"""
	end

end
