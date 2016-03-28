defmodule Comredis.Mixfile do
  use Mix.Project

  @description """
  Comredis is your comrade for Redis command generation in Elixir.
  """

  def project do
    [app: :comredis,
     version: "0.0.3",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     name: "Comredis",
     description: @description,
     package: package,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [
      {:poison, "~> 2.0"},

      {:earmark, "~> 0.1", only: :dev},
      {:ex_doc, "~> 0.11", only: :dev},

      {:redix, ">= 0.0.0", only: :test},
    ]
  end

  defp package do
    [ maintainers: ["Iuri Fernandes Queiroz"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/iurifq/comredis"} ]
  end
end
