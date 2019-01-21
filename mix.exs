defmodule Chess.MixProject do
  use Mix.Project

  def project do
    [
      app: :chess,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Chess.Application, []}
    ]
  end

  defp deps do
    [
      {:random_bytes, "~> 1.0"}
    ]
  end
end
