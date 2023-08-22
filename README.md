# AliyunOpenApiSdk 
AliyunOpenApiSdk V1

This SDK is packaged according to Alibaba Cloud APIs in the remote procedure call (RPC) style

It can simple call to all of Alibaba Cloud product api


## Get Gateway Api Groups
```elixir

req_data = %{
  "PRODUCT" => "apigateway",
  "REGIONS"=> "cn-shenzhen",
  "Version" => "2016-07-14",
  "ALIYUN_ACCESS_KEY" => "<YOUR ALIYUN_ACCESS_KEY>",
  "ALI_YUN_ACCESS_SECRET"=> "<YOUR ALI_YUN_ACCESS_SECRET>",
}

path = ""
method = "GET"
body = %{
  "Action" => "DescribeApiGroups",
}

AliyunOpenApiSdk.Core.aliyun_api_request(method, path, body, req_data)
```

## Create A Gateway Api App
```elixir

req_data = %{
  "PRODUCT" => "apigateway",
  "REGIONS"=> "cn-shenzhen",
  "Version" => "2016-07-14",
  "ALIYUN_ACCESS_KEY" => "<YOUR ALIYUN_ACCESS_KEY>",
  "ALI_YUN_ACCESS_SECRET"=> "<YOUR ALI_YUN_ACCESS_SECRET>",
}
path = ""
method = "POST"

body = %{
  "AppName" => "demo",
  "Description" => "demo",
  "Action" => "CreateApp",
}
AliyunOpenApiSdk.Core.aliyun_api_request(method, path, body, req_data)
```

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `aliyun_open_api_sdk` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:aliyun_open_api_sdk, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/aliyun_open_api_sdk>.

