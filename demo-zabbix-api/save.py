import requests
import json
import datetime
import time
from datetime import datetime, date

USER_ID='4'
ZBX_RPC_URL='https://itms.demo.com/zabbix/api_jsonrpc.php'
AUTH_TOKEN='36f7dd5890054597cefe'


headers = {
    "Content-Type": "application/json"
}

# 获取监控项id
def get_itemid(hostid, itemkey):
    data = json.dumps({
        "jsonrpc": "2.0",
        "auth": AUTH_TOKEN,
        "id": USER_ID,
        "method": "item.get",
        "params": {
            "output": 'itemid',
            "hostids": hostid,
            "search": {
                "key_": itemkey
            }
        },
    })
    
    resp = requests.post(url=ZBX_RPC_URL, headers=headers, data=data)
    # logging.debug(resp.json().get('result')[0])

    itemid = resp.json().get('result')[0].get('itemid')
    return itemid


# 获取监控项趋势
def get_trend(itemid,time_from=None,time_till=None):
    # output  默认为"extend", 可以选择只打印部分
    data = json.dumps({
        "jsonrpc": "2.0",
        "auth": AUTH_TOKEN,
        "id": USER_ID,
        "method": "trend.get",
        "params": {
            "output": "extend",
            "time_from": time_from,
            "time_till": time_till,
            "itemids": itemid,
            "limit": ""
        },
    })

    resp = requests.post(url=ZBX_RPC_URL, headers=headers, data=data)
    trend_data= resp.json().get("result")[0]
    print(trend_data)
    return trend_data

# 历史监控数据
def get_history(itemid,time_from=None,time_till=None):
    # output  默认为"extend", 可以选择只打印部分
    data = json.dumps({
        "jsonrpc": "2.0",
        "auth": AUTH_TOKEN,
        "id": USER_ID,
        "method": "history.get",
        "params": {
            "output": "extend",
            "history": 0,
            "itemids": itemid,
            "time_from": time_from,
            "time_till": time_till,
            "sortfield": "clock",
            "sortorder": "ASC",
        },
    })

    resp = requests.post(url=ZBX_RPC_URL, headers=headers, data=data)
    history_data= resp.json().get("result")
    print(history_data)
    return history_data


# itemid = get_itemid(hostid="10429",itemkey="system.cpu.util")

#print(itemid)

itemid='126593'

# 获取时间戳
today = date.today()
today = time.strptime(str(today),'%Y-%m-%d')
today = int(time.mktime(today))
yesterday = today - 86400

print(yesterday,today)

get_trend(itemid=itemid,time_from=yesterday,time_till=today)
get_history(itemid=itemid,time_from=yesterday,time_till=today)