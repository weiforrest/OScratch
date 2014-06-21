OScratch by weiforrest
======================
My English isn't enough level to explain  my code,
so i decide to use my mothertongue to write the comment.
And i think the resource about write a tiny Oprate System
kernel by english is everywhere, no excuse care about my code.

Summrise
--------
		这个是我在学习操作系统时，跟随 <<Orange's 一个操作系统的实现>>
所实现的一个简单的操作系统的内核，当时写完了七章，因为一些原因，没有完成。
借着自己阅读linux内核0.12源码的东风，决定重新开始，所以创建了这个仓库，方便管理。
		
Environment
-----------
		我使用的是ubuntu发行版（12.04-14.04），运行的模拟器使用的是bochs，
bochs的启动脚本是bochsrc。使用的编译器是nasm+gcc。
因为make中使用了挂载操作所以编译命令为：sudo make 详情请看Makefile。

branch
------
		master 是当前可用的最新进度,而其他的分支是属于试验下的,
只有稳定后才会合并到master上.

Now
---
		当前已经使用3个TTY，F1-F3切换TTY0-TTY2，TTY0不断输出A，TTY1不断输出B，TTY2没有输出，同时3个TTY会对键盘进行响应，产生回显。仅此而已，好吧，确实弱爆了。		
