#!/usr/bin/env python
# coding=utf-8
# @Author : songliang

# 获取项目远程mirror
# https://docs.gitlab.com/ee/api/remote_mirrors.html  api 文档
# https://python-gitlab.readthedocs.io/en/stable/gl_objects/remote_mirrors.html

from login_conf import *
from list_groups import save_json, load_json


# 所以mirror 列表
mirrors_list = []


# 获取所有组下仓库ID
def get_all_project_id():
    # 项目仓库ID 列表
    projects_id_list = []
    all_projects = gl.projects.list(all=True)
    # all_projects = gl.projects.list()
    for p in all_projects:
        projects_id = p.__dict__['_attrs'].get('id')
        projects_id_list.append(projects_id)

    return projects_id_list


# 通过ID获取projects是否已经设置了镜像地址
def get_remote_mirrors(project_id):
    project = gl.projects.get(project_id)
    mirror_list = project.remote_mirrors.list()
    if len(mirror_list) is not False:
        for m in mirror_list:
            mirror = m.__dict__['_attrs']       # calss对象信息获取转化为字典
            print(mirror)
            mirrors_list.append(mirror)
    else:
        print("mirror 为空")


if __name__ == '__main__':

    # 获取数据保存文件
    projects_id_list = get_all_project_id()
    for project_id in projects_id_list:
        get_remote_mirrors(project_id)

    save_json("tmp/mirrors_bj_wh.json", mirrors_list)

    # 读写本地文件
    # mirrors_list = load_json('tmp/mirrors_xa.json')
    # for m in mirrors_list:
    #     print(m.get("url"))
    #