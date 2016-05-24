title: <<The Linux Command Line>> 第十五章笔记 软件包管理
date: 2015-09-07 20:00:15
tags: [linux, bash]
---

## 通过软件包文件来安装软件
```
dpkg --install package_file
```

## 列出所安装的软件包
```
dpkg --list
```

## 确定是否安装了一个软件包
```
dpkg --status package_name
```

## 显示所安装软件包的信息
```
apt-cache show package_name
```

## 查找安装了某个文件的软件包
```
dpkg --search file_name
```

