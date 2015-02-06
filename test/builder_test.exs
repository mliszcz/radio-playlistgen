
defmodule BuilderTest do

	use ExUnit.Case

	test "build playlist file" do

		assert Builder.build([
			%{title: "t1", file: "f1"},
			%{title: "t2", file: "f2"}]) == """
		[playlist]
		NumberOfEntries=2
		Version=2
		File1=f1
		Title1=t1
		Length1=-1
		File2=f2
		Title2=t2
		Length2=-1

		"""
	end
end
