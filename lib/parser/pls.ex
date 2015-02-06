
defmodule Parser.PLS do

	def parse(file) do
		parseLine file, []
	end

	defp parseLine(file, data) do
		case IO.read file, :line do
			:eof -> data
			line -> case Regex.run ~r/File\d+=(.*)[\r?\n]?/, line do
				[^line, url] -> parseLine file, [url | data]
				_ 			 -> parseLine file, data
			end
		end
	end

end
