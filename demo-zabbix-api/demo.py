import json
import requests
import logging
import time
from datetime import datetime, date
import datetime

import xlwt
import openpyxl
import pandas as pd

logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s')

headers = {
    "Content-Type": "application/json"
}


# 将 json dist 格式展开打印
def format_print(data):
    format_data = json.dumps(data, indent=4, ensure_ascii=False)
    logging.debug(format_data)


# 获取token
def get_token(USER, PASSWD):
    data = json.dumps({
        "jsonrpc": "2.0",
        "method": "user.login",
        "params": {
            "user": USER,
            "password": PASSWD
        },
        "id": USER_ID,
    })

    resp = requests.post(ZBX_RPC_URL, headers=headers, data=data)
    auth = json.loads(resp.text)
    print(auth)
    return auth["result"]


# 通过组名字获取组ID
def get_hostgroup_id(GROUP_NAME):
    data = json.dumps(
        {
            "jsonrpc": "2.0",
            "auth": AUTH_TOKEN,
            "id": USER_ID,
            "method": "hostgroup.get",
            "params": {
                "output": "groupid",
                "filter": {
                    "name": GROUP_NAME
                }
            }
        })

    resp = requests.post(ZBX_RPC_URL, headers=headers, data=data)
    groupid = resp.json().get("result")[0].get('groupid')
    logging.debug('groupid: {0}'.format(groupid))
    return groupid


# 获取组主机列表
def get_host_list(group_id):
    # request json 
    # output  默认为"extend", 可以选择只打印部分
    data = json.dumps(
        {
            "jsonrpc": "2.0",
            "auth": AUTH_TOKEN,
            "id": USER_ID,
            "method": "host.get",
            "params": {
                "groupids": group_id,
                "output": ["hostid", "host", "status", "available", "name", ]
            }
        })

    resp = requests.post(ZBX_RPC_URL, headers=headers, data=data)
    host_list = resp.json().get('result')
    format_print(host_list)

    # host_rm = []

    # for n in range(len(host_list)):
    #     if host_list[n].get('available') != "1":
    #         host_rm.append(n)
    #     elif n == 0:
    #         print('主机组中没有监控可用主机')
    #         break
    # for n in host_rm:
    #     host_list.remove(host_list[n]) 

    return host_list


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
def get_trend(itemid, time_from=None, time_till=None):
    # output  默认为"extend", 可以选择只打印部分
    data = json.dumps({
        "jsonrpc": "2.0",
        "auth": AUTH_TOKEN,
        "id": USER_ID,
        "method": "trend.get",
        "params": {
            "output": [
                "itemid",
                "value_avg",
                "value_max",
            ],
            "time_from": time_from,
            "time_till": time_till,
            "itemids": itemid,
            "limit": ""
        },
    })

    resp = requests.post(url=ZBX_RPC_URL, headers=headers, data=data)
    trend_data = resp.json().get("result")[0]
    format_print(trend_data)
    return trend_data


# 获取组下的主机监控项数据, 昨天一天的平均趋势
def get_monitordata(group_name):
    # 获取时间戳
    today = date.today()
    today = time.strptime(str(today), '%Y-%m-%d')
    today = int(time.mktime(today))
    yesterday = today - 86400

    group_data_list = []
    host_list = get_host_list(get_hostgroup_id(group_name))

    for n in range(len(host_list)):
        host_name = host_list[n].get('name')

        if host_list[n].get('available') == "1":
            cpuutil_itemid = get_itemid(hostid=host_list[n].get('hostid'), itemkey='system.cpu.util')
            cpuutil_trend = get_trend(itemid=cpuutil_itemid, time_from=yesterday, time_till=today)
            cpuutil_avg_value = round(float(cpuutil_trend.get('value_avg')), 2)
            cpuutil_max_value = round(float(cpuutil_trend.get('value_max')), 2)

            memory_itemid = get_itemid(hostid=host_list[n].get('hostid'), itemkey='vm.memory.size[pavailable]')
            memory_trend = get_trend(itemid=memory_itemid, time_from=yesterday, time_till=today)
            memory_avg_value = round(float(memory_trend.get('value_avg')), 2)
            memory_max_value = round(float(memory_trend.get('value_max')), 2)
        else:
            cpuutil_avg_value = 'null'
            cpuutil_max_value = 'null'
            memory_avg_value = 'null'
            memory_max_value = 'null'
        cpuutil_avg = {'主机名': host_name, '监控项': 'CPU使用率平均值%', 'value': cpuutil_avg_value}
        group_data_list.append(cpuutil_avg)

        cpuutil_max = {'主机名': host_name, '监控项': 'CPU使用率最大值%', 'value': cpuutil_max_value}
        group_data_list.append(cpuutil_max)

        memory_avg = {'主机名': host_name, '监控项': '内存使用率平均值%', 'value': memory_avg_value}
        group_data_list.append(memory_avg)

        memory_max = {'主机名': host_name, '监控项': '内存使用率最大值%', 'value': memory_max_value}
        group_data_list.append(memory_max)

    return group_data_list


def export_excel(data, gruopname):
    yesterday = datetime.date.today() + datetime.timedelta(-1)
    pf = pd.DataFrame(list(data))
    pf = pf.set_index(['主机名', '监控项'])
    # 将列名替换为中文
    columns_map = {
        'value': yesterday
    }
    pf.rename(columns=columns_map, inplace=True)
    pf.sort_index(inplace=True)
    # # 指定生成的Excel表格名称
    file_path = pd.ExcelWriter(gruopname + '.xlsx')
    # 替换空单元格
    pf.fillna(' ', inplace=True)
    # 输出
    pf.to_excel(file_path, sheet_name=gruopname, encoding='utf-8', index=True)
    file_path.save()


if __name__ == '__main__':
    USER_ID = '4'
    ZBX_RPC_URL = 'https://itms.demo.com/zabbix/api_jsonrpc.php'
    AUTH_TOKEN = '36f7dd5890054597c'

    gruopname = '研发中心服务器'
    data = get_monitordata(gruopname)
    export_excel(data=data, gruopname=gruopname)
