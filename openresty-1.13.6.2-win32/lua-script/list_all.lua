--- 功能描述：前提启动file-manager服务，接收GET请求
--- 列出workhome文件夹下的所有文件夹及对应的result文件夹下的文件
--- Created by yangpengfei.
--- DateTime: 2019/8/15 9:30
---
local json = require("cjson")
json.encode_sparse_array(true)
local http = require("resty.http")
-- file-manager服务地址
local fileManager = "http://127.0.0.1:8081"
local httpc = http:new()
-- 设置连接超时时间
httpc:set_timeout(5000)
-- 响应内容的数据格式
ngx.header.content_type = "application/json; charset=utf-8"

--读取workhome下所有文件夹
local res, err = ngx.location.capture('/listpathfile',
        { method = ngx.HTTP_GET,
          args = {path = "workhome"}}
)
ngx.log(ngx.ERR, "读取workhome下所有文件夹：", json.encode(res))

--ngx.print(res.body)

--将workhome下的所有文件夹名称提取出来，并拼接路径，存到table中，作为后续接口的参数
local dirlist = {}
local j = json.decode(res.body)
for k,v in ipairs(j) do
    --ngx.log(ngx.ERR, "------k:", k)
    --ngx.log(ngx.ERR, "------v.name:", v.name)
    if nil ~= v.name then
        table.insert(dirlist, "workhome/" .. v.name)
    end
end
--ngx.print(json.encode(dirlist))
local ParamsList = json.encode(dirlist)

--调用fileManager服务接口，读取workhome下所有文件夹中的文件
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
        body = "{\"action\":\"list\",\"path\":\"\",\"ParamsList\":"..ParamsList..",\"params\":{\"childDirName\":\"result\"}}"
    }
)
ngx.log(ngx.ERR, "读取workhome下所有文件夹中的文件：", res0.body)
local response = json.decode(res0.body)

--for k,v in ipairs(response.result) do
--    ngx.log(ngx.ERR, "------k:", k)
--    ngx.log(ngx.ERR, "------v:", v)
--end

if 0 == response.status then
    ngx.print(json.encode(response.result))
else
    ngx.print(response.massage)
end