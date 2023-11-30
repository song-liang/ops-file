import requests
import jenkins
import json

username = 'uta001'
password = '123456'
url = 'http://demo.com/jenkins/'

server = jenkins.Jenkins(url, username=username, password=password)

get_views = server.get_views()

for v in get_views:
    views = v.get('name')
    print(views)

view_jobs = server.get_jobs(view_name='all')
for j in view_jobs:
    jobs = j.get('fullname')
    print(jobs)


