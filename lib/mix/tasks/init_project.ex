defmodule Mix.Tasks.InitProject do
  @moduledoc "Printed when the user requests `mix help echo`"
  @shortdoc "Gen Aliyun SDK"

  use Mix.Task
  use Tesla
  plug(Tesla.Middleware.BaseUrl, "https://next.api.aliyun.com")
  plug(Tesla.Middleware.JSON)

  @impl Mix.Task
  def run(args) do
    Mix.shell().info(args)
    {parsed, _, _} = OptionParser.parse(args, strict: [namespace: :string, commit: :boolean])
    IO.inspect(parsed, label: "Received args")
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

  def handle_each(each) do

    version = Enum.join(each["versions"], ",")

    "| #{each["code"]} | #{each["name"]} | #{each["defaultVersion"]} | #{each["shortName"]} | #{each["defaultVersion"]}  | #{version} |\n"
  end

  def to_markdown(value) do
    data = "# Lists all of the Aliyun's product.

The table below shows a summary of the contents created by the AliyunSDK generators:

| Code | Title | Description | ShortName | DefaultVersion | Versions |
| ----- | ----- | ----- | ----- | ----- | ----- |
    "

    Mix.Generator.create_file("Products.md", data <> value)
  end

  def main() do
    {:ok, %{:body => body}} = get_all_project_data()

    body
    |> Enum.map(fn x -> handle_each(x) end)
    |> Enum.join("")
    |> to_markdown
  end
end
