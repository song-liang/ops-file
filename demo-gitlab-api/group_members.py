#!/usr/bin/env python
# coding=utf-8
# @Author : songliang

# 获取项目成员
# access_level 数字对应权限
# Guest：10
# Reporter：20
# Developer：30
# manintainer:40
# Owner:50
#
import pandas as pd
from login_conf import *
from list_groups import load_json, save_json


# 获取单个组成员列表
def get_group_member(gl, gruop_id):
    group = gl.groups.get(gruop_id)
    members = group.members.all(all=True)
    members_list = []
    for member in members:
        member = member.__dict__.get('_attrs')
        members_list.append(member)
    return members_list


# 权限数字对应权限
def access_level_to_str(access_level):
    if access_level == 50:
        return 'Owner'
    elif access_level == 40:
        return 'Maintainers'
    elif access_level == 30:
        return 'Developer'
    elif access_level == 20:
        return 'Reporter'
    elif access_level == 10:
        return 'Guest'


# 筛选定义,获取所有群组成员信息
def get_all_member_list(gl, groups_list):
    group_member_list = []
    for group in groups_list:
        group_name = group.get('name')
        member = get_group_member(gl, group_name)
        logging.debug(member)

        for user in member:

            # 获取用户email
            all_users_list = load_json('tmp/users.json')
            for users in all_users_list:
                if user.get('id') == users.get('id'):
                    email = users.get('email')

            # 获取用户名和访问等级，添加所属群组， 添加用户邮件
            user = {'group_name': group_name,
                    'name': user.get('name'),
                    'username': user.get('username'),
                    'email': email,
                    'access_level': access_level_to_str(user.get('access_level')),
                    }
            logging.info(user)
            group_member_list.append(user)
    return group_member_list


def save_excel(data):
    pf = pd.DataFrame(data)
    # 设置索引
    #pf = pf.set_index(['group_name', 'access_level'])
    # # 将列名替换为中文
    columns_map = {
        'name': '用户',
        'username': '用户名',
        'email': '用户邮箱'
    }
    pf.rename(columns=columns_map, inplace=True)
    # 指定生成的Excel表格名称
    file_path = pd.ExcelWriter('tmp/members.xlsx')
    # 替换空单元格
    pf.fillna(' ', inplace=True)
    # 输出
    pf.to_excel(file_path, sheet_name='member', encoding='utf-8', index=True)
    # 保存表格
    file_path.save()


if __name__ == '__main__':

    # groups_list = load_json('tmp/group.json')
    # 导出群组成员列表保存为json
    group_member_list = get_group_member(gl, "2098")
    # print(group_member_list)
    save_json('tmp/group_member.json', group_member_list)

    # 加载本地数据
    # group_member_list = load_json('tmp/group_member.json')
    # 保存excel
    save_excel(group_member_list)
