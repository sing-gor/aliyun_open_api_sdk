defmodule Mix.Tasks.Aliyun do
  @moduledoc "Printed when the user requests `mix help echo`"
  @shortdoc "Gen Aliyun SDK"

  use Mix.Task
  use Tesla
  alias Mix.AliyunOpenApiSdk.Context
  alias Mix.AliyunOpenApiSdk.ApiContext
  plug(Tesla.Middleware.BaseUrl, "https://next.api.aliyun.com")
  plug(Tesla.Middleware.JSON)

  @impl Mix.Task
  def run(args) do
    Mix.shell().info(args)

    {parsed, _, _} =
      OptionParser.parse(args, strict: [namespace: :string, version: :string, commit: :boolean])

    IO.inspect(parsed)

    case parsed do
      [] -> IO.inspect("The namespace can not be blank")
      [namespace: namespace] -> validate_args(namespace) |> main
      [namespace: namespace, version: version] -> validate_args(namespace, version) |> main
      _ -> :help
    end
  end

  def get_all_project_data() do
    get("/meta/v1/products.json?language=EN_US")
    |> case do
      {:ok, %{status: 200, body: body, headers: headers}} ->
        {:ok, %{:body => body, :headers => headers}}

      {:error, %{status: status, body: body, headers: headers}} ->
        {:error, %{:body => body, :headers => headers, :status => status}}

      other ->
        other
    end
  end

  def get_namespace_data(namespace, versions) do
    IO.inspect("/meta/v1/products/#{namespace}/versions/#{versions}/api-docs.json?language=EN_US")

    get("/meta/v1/products/#{namespace}/versions/#{versions}/api-docs.json?language=EN_US")
    |> case do
      {:ok, %{status: 200, body: body, headers: headers}} ->
        {:ok, %{:body => body, :headers => headers}}

      {:error, %{status: status, body: body, headers: headers}} ->
        {:error, %{:body => body, :headers => headers, :status => status}}

      other ->
        other
    end
  end

  def validate_namespace(body, namesapce) do
    body
    |> Enum.filter(fn x -> x["code"] == namesapce end)
    |> required_data
  end

  def validate_version(item, version) do
    case Enum.member?(item["versions"], version) do
      true -> [item]
      _ -> []
    end
  end

  @spec main(any) :: any
  def main(item) do
    {:ok, %{:body => body}} = get_namespace_data(item["code"], item["defaultVersion"])

    base_item =
      item
      |> Context.new(%{})
      |> Context.make_ex_flie()

    body["apis"]
    |> Enum.map(fn {k, v} -> ApiContext.handle_data(base_item, k, v) end)
  end

  def validate_args(namespace) do
    {:ok, %{:body => body}} = get_all_project_data()

    body
    |> validate_namespace(namespace)
  end

  def validate_args(namesapce, version) do
    {:ok, %{:body => body}} = get_all_project_data()

    body
    |> validate_namespace(namesapce)
    |> validate_version(version)
    |> required_data
    |> Map.put("defaultVersion", version)
  end

  def required_data([]) do
    raise "The namespace or version does not exist. Please consult the Products.md file for help!"
  end

  def required_data([head | _]), do: head
end
