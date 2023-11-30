
# 登陆 gitlab的信息

import gitlab
import logging

# host_url
gitlab_url = 'https://gitlab.demo.com'


# api token
gitlab_token = 'glpat-suExyNC7dGXA78AFFPvi'        

# private token or personal token authentication
gl = gitlab.Gitlab(gitlab_url, private_token=gitlab_token)

logging.basicConfig(level=logging.DEBUG,
                    format='%(asctime)s - %(filename)s[line:%(lineno)d] - %(levelname)s: %(message)s')

