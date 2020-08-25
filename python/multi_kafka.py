#!/usr/bin/env python3



import multiprocessing

from kafka import 	KafkaConsumer

PARTITION_NUMBER = 3

# 消费者 基于多进程
class Consumer(multiprocessing.Process):
	def __init__(self): 
		multiprocessing.Process.__init__(self) 
		self.stop_event = multiprocessing.Event() 
	def stop(self): 
		self.stop_event.set() 
	def run(self): 
		consumer = KafkaConsumer(
									bootstrap_servers=['localhost:9092'], 
									auto_offset_reset='earliest',
									group_id = "my.group",
									consumer_timeout_ms=1000
								) 
		consumer.subscribe(['foobar']) 
		while not self.stop_event.is_set(): 
			for message in consumer: 
				print(message) 
				if self.stop_event.is_set(): 
					break 
		consumer.close()


def main():
	for i in range(3):
		print( i )



if __name__ == '__main__':
	main()