#！/usr/bin/env python3

from kafka import KafkaConsumer
import json 

consumer  = KafkaConsumer(
	'foobar', 
	auto_offset_reset='earliest' , #读取目前最早可读的消息
	#enable_auto_commit = True, # 每过一段时间自动提交所有已消费的消息（在迭代时提交）
	#auto_commit_interval_ms = 2000, # 自动提交的周期（毫秒）
	group_id = "my.group", # 消费组id
	bootstrap_servers=['127.0.0.1:9092'],
	)

for message in consumer:

	'''
	print("[topic]: {} - [partition]:{} - offset:{} - key:{} - value:{}".format(
		message.topic,
		message.partition,
		message.offset,
		message.key,
		message.value 
	))
	'''

	#print( json.loads( message.value ) )

	print(message.value)