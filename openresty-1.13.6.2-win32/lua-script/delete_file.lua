--- 功能描述：前提启动file-manager服务，接收Delete请求
--- 删除文件
--- Created by yangpengfei
--- DateTime: 2019/10/10 18:30
--- body中格式: {"ParamsList":["workhome/test"]} 即删除workhome/test文件
local json = require("cjson")
json.encode_sparse_array(true)
local http = require("resty.http")
-- file-manager服务地址
local fileManager = "http://127.0.0.1:8081"
local httpc = http:new()
-- 设置连接超时时间
httpc:set_timeout(5000)
-- 响应内容的数据格式{
ngx.header.content_type = "application/json; charset=utf-8"

ngx.req.read_body()
-- 请求的消息体
local decodeInputBody = json.decode(ngx.req.get_body_data())
-- ParamsList字段
local paramsList = json.encode(decodeInputBody.ParamsList)
--ngx.log(ngx.ERR, "ParamsList参数：", paramsList)

local res0, err0 = httpc:request_uri(
    fileManager,
    {
        -- 指定具体路径
        path = '/',
        -- 请求的参数
        query = { format = 'json' },
        method = "POST",
        headers = {
            ["Content-Type"] = "application/json;charset=UTF-8",
        },
        -- 请求体数据
        body = "{\"action\":\"delete_file\",\"ParamsList\":"..paramsList.."}"
    }
)

local response = json.decode(res0.body)
--返还status
ngx.print(json.encode(response))