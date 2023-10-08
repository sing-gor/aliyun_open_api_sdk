defmodule Mix.AliyunOpenApiSdk.ApiContext do
  @moduledoc false
  defstruct file_name: nil,
            module: nil,
            # dir_path: nil,
            flie_path: nil,
            required_lists: nil,
            api_action: nil,
            params_lists: nil,
            req_method: nil,
            summary: nil,
            base_module: nil,
            fields_table: nil,
            fields_schema: nil

  def new(base_item, key, item) do
    name = Macro.underscore(key)

    file_name = name <> ".ex"
    flie_path = base_item.dir_path <> "/" <> file_name

    %__MODULE__{
      file_name: file_name,
      module: key,
      flie_path: flie_path,
      required_lists: get_required_lists(item["parameters"]),
      api_action: key,
      params_lists: get_params_lists(item["parameters"]),
      req_method: List.first(item["methods"]),
      summary: item["summary"],
      base_module: base_item.code,
      fields_table: nil,
      fields_schema: get_fields_schema(item["parameters"])
    }
  end

  # def make_readme_md() do
  #  todo
  # end

  def get_required_lists(data) do
    Enum.filter(data, fn x -> x["schema"]["required"] end)
    |> Enum.map(fn x -> ":#{x["name"]}" end)
    |> Enum.join(", ")
    |> atom_list_to_str
  end

  @spec get_fields_schema(any) :: <<_::16, _::_*8>>
  def get_params_lists(data) do
    Enum.map(data, fn x -> ":#{x["name"]}" end)
    |> Enum.join(", ")
    |> atom_list_to_str
  end

  def get_fields_schema(data) do
    Enum.map(data, fn x ->
      handle_fields_schema_item(x["name"], x["schema"]["type"], x["schema"]["required"])
    end)
    |> Enum.join("\n")
  end

  defp handle_fields_schema_item(name, "string", true), do: "field :#{name}, :string"

  defp handle_fields_schema_item(name, "array", _),
    do: "field(:#{name}, {:array, :map}, default: [])"

  defp handle_fields_schema_item(name, "integer", _), do: "field :#{name}, :integer"
  defp handle_fields_schema_item(name, "boolean", _), do: "field :#{name}, :boolean"
  defp handle_fields_schema_item(name, "object", _), do: "field :#{name}, :string"
  defp handle_fields_schema_item(name, _, _), do: "field :#{name}, :string"

  def make_ex_flie(data) do
    file_context = "defmodule AliyunOpenApiSdk.#{data.base_module}.#{data.module} do
      use Ecto.Schema
      import Ecto.Changeset
      alias AliyunOpenApiSdk.#{data.base_module}, as: PackageData
      import AliyunOpenApiSdk
      @required_lists #{data.required_lists}
      @api_action \"#{data.api_action}\"
      @params_lists  #{data.params_lists}
      @req_method \"#{data.req_method}\"

      @moduledoc \"\"\"

      ## #{data.summary}

      | field |description| required | type | example |
      | ----- | ----- | ----- |----- | ----- |
      | AppName | The name of the application. The name must be 4 to 26 characters in length. The name can contain letters, digits, and underscores (\_), and must start with a letter. | true | string|
      | Description | The description of the application. The description can be up to 180 characters in length | false | string|
      | AppKey |  | false | string| ----- |
      | AppSecret |  | false | string| ----- |
      | AppCode |  | false | string| ----- |
      | Tag |  | false | array| ----- |
      #{data.fields_table}
      \"\"\"

      embedded_schema do
        #{data.fields_schema}
      end

      def changeset(params \\\\ %{}) do
        %__MODULE__{}
        |> cast(params, @params_lists)
        |> validate_required(@required_lists)
        |> check_changeset(params, @api_action, PackageData.init(), @req_method)
      end
    end

    "
    Mix.Generator.create_file(data.flie_path, file_context)
  end

  def handle_data(base_item, key, value) do
    data = new(base_item, key, value)
    make_ex_flie(data)
  end

  def atom_list_to_str(data), do: "[#{data}]"
end
