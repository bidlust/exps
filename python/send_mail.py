#!/usr/bin/python3

import sys 
import smtplib
from email.mime.text import MIMEText
from email.header import Header

# 第三方 SMTP 服务
mail_host="smtp.qiye.aliyun.com"  #设置服务器
mail_user="zabbix@maxscale.cn"    #用户名
mail_pass="Maxscale996!@"   #口令 
 
receiver = sys.argv[1]
subject  = sys.argv[2]
message  = sys.argv[3]

if receiver is None:
	print("[Error] - receiver is None")
	sys.exit(1)
if subject is None:
	print("[Error] - subject is None")
	sys.exit(1)
if message is None:
	print("[Error] - message is None")
	sys.exit(1)

sender = 'zabbix@maxscale.cn'
receivers = [ receiver ]  # 接收邮件，可设置为你的QQ邮箱或者其他邮箱

message = MIMEText(str(message), 'plain', 'utf-8')
message['From'] = Header("Zabbix告警监控", 'utf-8')
message['To'] =  Header("运维巡检人员", 'utf-8')
message['Subject'] = Header(str(subject), 'utf-8')

try:
	smtpObj = smtplib.SMTP_SSL(mail_host)
	# smtpObj.set_debuglevel(1)
    smtpObj.login(mail_user,mail_pass)  
    smtpObj.sendmail(sender, receivers, message.as_string())
    print("mail send success...")
except:
    raise 