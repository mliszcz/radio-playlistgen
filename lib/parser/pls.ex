
defmodule Parser.PLS do

	@spec parse(pid) :: [String.t]
	def parse(file) do
		parseLine file, []
	end

	@spec parseLine(pid, [String.t]) :: [String.t]
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
