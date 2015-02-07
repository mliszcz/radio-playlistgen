defmodule Radio.Mixfile do
	use Mix.Project

	def project do [
		app: :radio,
		version: "0.0.1",
		elixir: "~> 1.0",
		name: "radio-playlistgen",
		source_url: "https://github.com/mliszcz/radio-playlistgen",
		deps: deps,
		test_coverage: [tool: ExCoveralls] ]
	end

	def application do [
		applications: [:logger, :inets],
		env: [playlists: %{}, timeout: 2000] ]
	end

	defp deps do [
			{:excoveralls, "~> 0.3", only: :dev},
			{:dialyze, "~> 0.1", only: :dev},
			{:earmark, "~> 0.1", only: :dev},
			{:ex_doc, "~> 0.6", only: :dev} ]
	end
end
