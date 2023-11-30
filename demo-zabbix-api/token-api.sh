curl -XPOST -H 'Content-Type: application/json-rpc' -d '
{
    "jsonrpc": "2.0",
    "method": "user.login",
    "params": {
        "user": "user_name",
        "password": "password"
    },
    "id": 4,
    "auth": null
}' https://itms.demo.com/zabbix/api_jsonrpc.php | json_pp
