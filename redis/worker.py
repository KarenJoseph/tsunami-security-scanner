#!/usr/bin/env python

import time
import rediswq

#host="redis"
import os
host = os.getenv("REDIS_SERVICE_HOST")

print("Working with Redis Host: " + host)

q = rediswq.RedisWQ(name="tsunamiServerScan", host=host)
print("Worker with sessionID: " +  q.sessionID())
print("Initial queue state: empty=" + str(q.empty()))
while not q.empty():
  item = q.lease(lease_secs=10, block=True, timeout=2) 
  if item is not None:
    itemstr = item.decode("utf-8")
    print("Working on " + itemstr)
    os.environ["target_ip"] = itemstr
    os.system("java -cp tsunami.jar:plugins/* -Dtsunami-config.location=tsunami.yaml com.google.tsunami.main.cli.TsunamiCli --ip-v4-target=${target_ip} --scan-results-local-output-format=JSON --scan-results-local-output-filename=/usr/tsunami/logs/${target_ip}-$(date '+%d%m%y')-tsunami-output.json; cat /usr/tsunami/logs/${target_ip}-$(date '+%d%m%y')-tsunami-output.json")
    q.complete(item)
  else:
    print("Waiting for work")
print("Queue empty, exiting")

os.system("pkill promtail; true")
