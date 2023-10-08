defmodule AliyunOpenApiSdk.MixProject do
  use Mix.Project

  def project do
    [
      app: :aliyun_open_api_sdk,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
      {:tesla, "~> 1.5"},
      {:calendar, "~> 1.0.0"},
      {:elixir_uuid, "~> 1.2"},
      {:ecto, "~> 3.10"},
      {:jason, "~> 1.2"}
    ]
  end
end
