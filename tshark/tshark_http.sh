#!/bin/bash
##统计http的状态

tshark -n -q -z http,stat, -z http,tree