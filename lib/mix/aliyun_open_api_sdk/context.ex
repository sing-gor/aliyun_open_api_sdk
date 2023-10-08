defmodule Mix.AliyunOpenApiSdk.Context do
  @moduledoc false
  defstruct file_name: nil,
            module: nil,
            dir_path: nil,
            flie_path: nil,
            version: nil,
            product: nil,
            code: nil,
            description: nil,
            name: nil,
            short_name: nil,
            product: nil,
            endpoint_regional: nil

  def new(item, data) do
    name = Macro.underscore(item["code"])
    dir_path = "lib/" <> name
    file_name = name <> ".ex"
    flie_path = "lib/" <> file_name

    %__MODULE__{
      file_name: name,
      module: item["code"],
      dir_path: dir_path,
      flie_path: flie_path,
      version: item["defaultVersion"],
      product: Map.get(data, item["code"], "apigateway"),
      code: item["code"],
      description: item["description"],
      name: item["name"],
      short_name: item["shortName"],
      endpoint_regional: Map.get(data, item["endpoint_regional"], true)
    }
  end

  def make_readme_md() do
  end

  def make_ex_flie(data) do
    file_context = "defmodule AliyunOpenApiSdk.#{data.module} do
      def init()do
        %{:PRODUCT =>  \"#{data.product}\", :Version => \"#{data.version}\", :EndpointRegional => #{data.endpoint_regional}}
      end
    end
    "
    Mix.Generator.create_file(data.flie_path, file_context)
    Mix.Generator.create_directory(data.dir_path)
    data
  end
end
