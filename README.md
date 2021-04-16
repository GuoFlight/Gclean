# 简介

> 该代码用于清理过期文件
> 配合crontab一起使用更佳

# 特点
## 防止误删数据

* 删除check。删除文件中的目录必须包含某个字段，防止误删除。
* 先将数据移动到废纸篓，过一段时间后再去清理该目录
* 删除的时候先删除文件，再删除空目录。(避免使用rm -rf)
* 若文件名含有空格，应该避免误删除其他文件。

# 数据恢复

* 当数据需要恢复时，应能够恢复到原位

