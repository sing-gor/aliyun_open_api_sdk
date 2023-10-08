# AliyunOpenApiSdk
AliyunOpenApiSdk V3

This SDK is packaged according to Alibaba Cloud APIs in the remote procedure call (RPC) style

It can simple call to all of Alibaba Cloud product api

## Get Stand

Change file `config/test.demo` to `config/test.exs` .  
Change file `config/dev.demo` to `config/dev.exs` .

Remember to set your **ALI_YUN_REGIONS, ALIYUN_ACCESS_KEY** and **ALI_YUN_ACCESS_SECRET**.

```bash
mix aliyun --namespace=<Product Code> && mix format mix.exs "lib/**/*.{ex,exs}"
```

### Example
```bash
mix aliyun --namespace=CloudAPI && mix format mix.exs "lib/**/*.{ex,exs}"
```
You can see the all of the product in the Products.md   

## Get Gateway Api Groups(CloudAPI)
```elixir
alias AliyunOpenApiSdk.CloudAPI.DescribeApiGroups
{:ok, data} = DescribeApiGroups.changeset(%{})

AliyunOpenApiSdk.Core.aliyun_api_request(data)
```

## Create A Gateway Api App(CloudAPI)
```elixir

alias AliyunOpenApiSdk.CloudAPI.CreateApp
{:ok, data} = CreateApp.changeset(%{AppName: "SingSing", Description: "test",Tag: [%{"teat1" => "teat1"}, %{"test2" => "test2"}])

AliyunOpenApiSdk.Core.aliyun_api_request(data)

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
