#!/usr/bin/env python
# coding=utf-8
# @Author : songliang

# 获取用户列表
import pickle
import pandas as pd
from login_conf import *
from list_groups import load_json, save_json


# 获取所有用户列表
def get_all_users(gl):
    users_list = []

    users = gl.users.list(all=True, sort='asc', order_by='id')

    for user in users:
        user = user.__dict__.get('_attrs')
        # print(user)
        users_list.append(user)
    return users_list


# 写入Excel
def save_excel(data, filepath):
    # 将字典列表转换为DataFrame
    pf = pd.DataFrame(list(data))
    # 指定字段顺序
    order = ['id', 'name', 'username', 'state', 'email', 'web_url', 'can_create_group', 'last_activity_on']
    pf = pf[order]
    # 将列名替换为中文
    columns_map = {
        'id': '用户ID',
        'name': '显示名称',
        'username': '用户名字',
        'state': '用户状态',
        'email': '邮件',
        'web_url': '用户地址',
        'can_create_group': '创建组权限',
        'last_activity_on': '最后活跃时间'
    }
    pf.rename(columns=columns_map, inplace=True)
    # 指定生成的Excel表格名称
    file_path = pd.ExcelWriter(filepath)
    # 替换空单元格
    pf.fillna(' ', inplace=True)
    # 输出
    pf.to_excel(file_path, sheet_name='users', encoding='utf-8', index=False)
    # 保存表格
    file_path.save()


if __name__ == '__main__':
    # 保存users数据到json文件
    users_data = get_all_users(gl)
    save_json('tmp/users.json', data=users_data)

    # 读取json数据
    # users_data = load_json('tmp/users.json')
    # for user in users_data:
    #     print(user)

    # 保存excel
    save_excel(users_data, 'tmp/users.xlsx')
