# log-book


ps -mp 2633 -o THREAD,tid,time | sort -rn
显示结果如下：
USER     %CPU PRI SCNT WCHAN  USER SYSTEM   TID     TIME
root     10.5  19    - -         -      -  3626 00:12:48
root     10.1  19    - -         -      -  3593 00:12:16
找到了耗时最高的线程3626，占用CPU时间有12分钟了！
将需要的线程ID转换为16进制格式：printf "%x\n" 3626


du -h --max-depth=1 |grep [TG] |sort   #查找上G和T的目录并排序
du -sh    #统计当前目录的大小，以直观方式展现
du -h --max-depth=1 |grep 'G' |sort   #查看上G目录并排序
du -sh --max-depth=1  #查看当前目录下所有一级子目录文件夹大小
du -h --max-depth=1 |sort    #查看当前目录下所有一级子目录文件夹大小 并排序
du -h --max-depth=1 |grep [TG] |sort -nr   #倒序排


tar -zcvf test.tar.gz test
tar -zxvf file.tar.gz



11. https://jmeter.apache.org/

17. Arthas

18. Celery

19. MySQLTuner

20. https://matplotlib.org/stable/tutorials/introductory/pyplot.html

21. https://github.com/collinsmith/riiablo

22. https://github.com/Anuken/Mindustry

23. https://github.com/phantacix/litchi

24. https://github.com/mansamtsui/tinyrenderer

25. https://github.com/twitter/twemproxy

26. https://github.com/alibaba/cobar

27. https://github.com/jfree/jfreechart

28. https://prometheus.io/docs/introduction/overview/

29. https://github.com/google/guice/wiki

30. https://quasar.dev/

31. https://github.com/ben-manes/caffeine/wiki
