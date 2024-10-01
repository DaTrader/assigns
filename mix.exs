defmodule Assigns.MixProject do
  use Mix.Project

  @source_url "https://github.com/DaTrader/assigns"

  def project do
    [
      app: :assigns,
      version: "0.2.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Assigns is a library enabling abbreviation of assign/update function wrapper definitions.",
      package: package(),

      # Docs
      name: "Assigns",
      source_url: @source_url,
      docs: [
        main: "Assigns", # The main page in the docs
        extras: [ "README.md", "CHANGELOG.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [ :logger]
    ]
  end

  defp deps do
    [
      { :dialyxir, "~> 1.2", only: [ :dev, :test], runtime: false},
      { :ex_doc, "~> 0.34", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: [ "DaTrader"],
      licenses: [ "MIT"],
      links: %{ github: @source_url},
      files: ~w(lib test .formatter.exs mix.exs README.md LICENSE.md CHANGELOG.md)
    ]
  end
end
