#!/bin/bash


docker run \
--detach \
-p 8443:443 \    # 映射https端口, 不过本文中没有用到
-p 8090:80 \      # 映射宿主机8090端口到容器中80端口
-p 8022:22 \      # 映射22端口, 可不配
--name gitlab \            
--restart always \
-v /var/lib/gitlab/etc:/etc/gitlab \    # 挂载gitlab的配置文件
-v /var/lib/gitlab/logs:/var/log/gitlab \    # 挂载gitlab的日志文件
-v /var/lib/gitlab/data:/var/opt/gitlab \    # 挂载gitlab的数据
-v /etc/localtime:/etc/localtime:ro \    # 保持宿主机和容器时间同步
--privileged=true beginor/gitlab-ce    # 在容器中能以root身份执行操作