#!/bin/bash
##显示访问http请求的域名以及uri

tshark -n -t a -R http.request -T fields -e "frame.time" -e "ip.src" -e "http.host" -e "http.request.method" -e "http.request.uri"