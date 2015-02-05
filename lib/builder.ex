
defmodule Builder do
	import Enum

	def build(entries) do
		ent = entries
			|> with_index
			|> map(fn {e,i} -> {e,i+1} end)
			|> map(&format/1)
		~s"""
		[playlist]
		#{ent}
		NumberOfEntries=#{length ent}
		Version=2
		"""
	end

	defp format({%{title: t, file: f} = entry, id}) do
		~s"""
		File#{id}=#{entry.file}
		Title#{id}=#{entry.title}
		Length#{id}=-1
		"""
	end

end
