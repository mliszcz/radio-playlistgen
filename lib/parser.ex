
defmodule Parser do

	def parse(fileName) do
		case File.open fileName, [:utf8] do
			{:ok, file} ->
				res = parseLine file, []
				File.close file
				res
			{:error, _} -> []
		end
	end

	defp parseLine(file, data) do
		case IO.read file, :line do
			:eof -> data
			line -> case Regex.run ~r/File\d+=(.*)[\r?\n]?/, line do
				[^line, url] -> parseLine file, [url | data]
				_ -> parseLine file, data
			end
		end
	end

end
