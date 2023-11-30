import json
import ldap
import pandas as pd

LdapServer = 'ldap://localhost'
ManagerDn = 'cn=admin,dc=demo,dc=com'
DnPasswd = 'demo@123'
SearchBase = "ou=users,dc=demo,dc=com"
SearchScope = ldap.SCOPE_SUBTREE
SearchFilter = '(mail=*)'
AttrList = ['cn', 'employeeNumber', 'mail']


# 获取ldap所有用户
def get_ldap_users():
    conn = ldap.initialize(LdapServer)
    conn.simple_bind_s(ManagerDn, DnPasswd)
    result = conn.search_s(base=SearchBase,
                           scope=SearchScope,
                           filterstr=SearchFilter,
                           attrlist=AttrList, attrsonly=0)  # 查询所有用户
    user_list = []  # 用户列表
    for dn, entry in result:
        # print('Processing:', dn, entry)
        ut_number = str(entry.get('employeeNumber')[0], encoding="utf-8")  # bytes 转换为 str
        cn = str(entry.get('cn')[0], encoding="utf-8")
        mail = str(entry.get('mail')[0], encoding="utf-8")

        userdata = {'employeeNumber': ut_number, 'cn': cn, 'mail': mail}
        user_list.append(userdata)

    return user_list


# 加载已导出的json
def load_users_data(file):
    with open(file, 'r', encoding='utf-8') as fp:
        json_data = json.load(fp)
    return json_data


# 导出为表格
def export_excel(data, filename):
    pf = pd.DataFrame(list(data))
    # pf = pf.set_index(['employeeNumber'])
    # 将列名替换为中文
    # columns_map = {
    #    'cn': '用户名',
    #    'employeeNumber': '工号',
    #    'mail': '邮箱'
    # }
    # pf.rename(columns=columns_map, inplace=True)
    pf.sort_index(inplace=True)
    # # 指定生成的Excel表格名称
    file_path = pd.ExcelWriter(filename + '.xlsx')
    # 替换空单元格
    pf.fillna(' ', inplace=True)
    # 输出
    pf.to_excel(file_path, sheet_name=filename, encoding='utf-8', index=True)
    file_path.save()


# 过滤离职人员
def filter_resigned_users():
    seafile_users = load_users_data("seafile-users.json").get("data")
    ldap_users = get_ldap_users()
    # ldap_users = load_users_data("ldap-users.json")
    resigned_list = []
    ldap_mail_list = []
    for user in ldap_users:
        mail = user.get("mail")
        ldap_mail_list.append(mail)
    for seafile_user in seafile_users:
        mail = seafile_user.get('email')
        if mail not in ldap_mail_list:
            resigned_list.append(seafile_user)

    return resigned_list


if __name__ == '__main__':
    resigned_users = filter_resigned_users()
    export_excel(resigned_users, "已离职人员")
