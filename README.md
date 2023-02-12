mycmd osinfo --显示操作系统信息，含主机名IP，操作系统版本，内核版本，是否虚拟机（物理机型号，报障SN号），CPU配置，内存配置，磁盘配置，网卡配置等信息

mysql osrule --给出操作系统的配置建议，RAID，操作系统参数配置等

mycmd info  --主机名，版本，运行时间，规格（核数，内存，磁盘大小）

mycmd stat --CPU使用率，内存使用率，磁盘使用率，网卡流量

mycmd errlog [err|warn]  --当天的错误日志，待写脚本

mycmd slave qa  --主从报错，问题/回答

mycmd qa  --错误号收集，案例

mycmd dlock  --死锁信息，参考阿里云死锁分析

mycmd active  --按时间刷新会话，参照阿里云，含会话统计(mycmd refresh,mycmd conncnt)

mycmd tran    --事务情况，待写脚本

mycmd dbsize  --数据库大小分析

mycmd tabsize --表大小分析

mycmd temp  --5.7版本，8.0版本，待写脚本

mycmd undo  --undo信息，待写脚本

mycmd check  --基础巡检(mycmd info ，mycmd stat，空间【TOP表，TOP库，无主键表，锁片率TOP表】，冗余索引，最后一次死锁时间【时间维度】,当天错误日志，当天慢SQL数量【没开启提示没开启慢日志】)

mycmd tools  --列出MySQL常用的工具，这里先没展开，后续想展开之后，将各个工具常用的内容进行集合
物理备份工具：xtrabackup，下载地址：
逻辑备份工具：mydumper，并行备份，下载地址：
MySQL运维工具：pt-tools，下载地址：
MySQL沙盒部署：dbdeployer，快速构建测试环境，下载地址：
MySQL随机数据填充工具：mysql_random_load_data，快速造数，下载地址：
binlog解析工具：binlog2sql，下载地址：
binlog解析工具：my2sql，下载地址：
结构对比工具：schemasync，下载地址：
mysqlreport工具：下载地址：
高可用架构：
读写分离工具：
分库分表工具：

还待编写脚本的想法：
mycmd 语法     --语法提示，比如收集binlog常用的分析

mycmd sql      --收集常用SQL收集模板

mycmd 空间预估 --这个可参考阿里云的das功能

mycmd slow     --慢SQL统计
