#!/usr/bin/env python
# coding=utf-8
# @Author : songliang

# 获取所有群组

import gitlab
import pandas as pd
import json
from login_conf import *


# 获取单独组
def get_one_group(gl, groups_id):
    one_group = gl.groups.get(groups_id)
    return one_group


# 获取单个组所有项目
def get_groups_project(gl, gruops_id):
    group = get_one_group(gl, gruops_id)
    projects = group.projects.list(all=True)
    return projects


# 获取所有项目
def get_all_projects(gl):
    all_projects = gl.projects.list(all=True)
    return all_projects


# 获取群组成员列表
def get_group_member(gl, gruop_name):
    group = gl.groups.list(search=gruop_name)[0]
    members = group.members.all(all=True)
    members_list = []
    for member in members:
        member = member.__dict__.get('_attrs')
        members_list.append(member)
    return members_list


# 获取群组拥有者
def get_group_owner(members):
    group_owner = {}
    for member in members:
        if member.get('access_level') == 50:
            name = member.get('name')
            username = member.get('username')
            group_owner = {'owner': name, 'username': username}
    return group_owner


# 转换获取所有群组列表
def get_all_group_list(gl):
    # 获取所有组的数据
    groups = gl.groups.list(all=True, sort='asc', order_by='id')
    groups_list = []
    for group in groups:
        group = group.__dict__.get('_attrs')

        # 获取 组中项目数
        # group.update({'project_tail': len(get_groups_project(gl, group.get('id')))})
        group.update({'project_tail': ''})

        groups_list.append(group)
        logging.debug(group)
    return groups_list


# 写入Excel
def save_excel(data, filepath):
    # 将字典列表转换为DataFrame
    pf = pd.DataFrame(list(data))
    # 指定字段顺序
    order = ['id', 'web_url', 'name', 'full_name', 'full_path', 'description', 'visibility',
             'request_access_enabled',  'parent_id',  'project_tail']
    pf = pf[order]
    # 将列名替换为中文
    columns_map = {
        'id': '群组ID',
        'web_url': '群组访问地址',
        'name': '群组名称',
        'full_name': '群组全名',
        'full_path': '群组完整路径',
        'description': '群组描述',
        'visibility': '群组可见性',
        'request_access_enabled': '允许用户请求权限',
        'parent_id': '父群组ID',
        # 'owner': '群组拥有者',
        # 'username': '拥有者用户名',
        'project_tail': '群组项目数量'
    }
    pf.rename(columns=columns_map, inplace=True)
    # 指定生成的Excel表格名称
    file_path = pd.ExcelWriter(filepath)
    # 替换空单元格
    pf.fillna(' ', inplace=True)
    # 输出
    pf.to_excel(file_path, sheet_name='groups', encoding='utf-8', index=False)
    # 保存表格
    file_path.save()


# 保存json
def save_json(filename_path, data):
    with open(filename_path, 'w', encoding='utf-8') as fp:
        json.dump(data, fp, ensure_ascii=False)


# 加载本地json文件数据
def load_json(filename_path):
    with open(filename_path, 'r', encoding='utf-8') as fp:
        json_data = json.load(fp)
    return json_data


if __name__ == '__main__':

    groups_list = get_all_group_list(old_gl)

    # 群组数据保存为json文件
    save_json('tmp/group.json', groups_list)

    # 直接读取本地
    # groups_list = load_json('tmp/group.json')

    # 保存excel
    save_excel(groups_list, 'tmp/groups.xlsx')
