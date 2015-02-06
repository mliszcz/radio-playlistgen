
defmodule Parser.M3U do

	def parse(file) do
		parseLine file, []
	end

	defp parseLine(file, data) do
		case IO.read file, :line do
			:eof -> data
			line -> case String.starts_with? line, "#" do
				true -> parseLine file, data
				false ->
					case Regex.run ~r|^(.+)[\r?\n]?$|, line do
						[^line, url] -> parseLine file, [url | data]
						_ 			 -> parseLine file, data
					end
			end
		end
	end

end
