
clone自己的git repo，使用--mirror参数。

git clone --mirror git@github.com:huipengly/RobotArm.git

3.清除大文件，文件夹，隐私文件

这里官网给出的命令是这样的。第一句是删除文件，第二句是删除文件夹，两个语句的区别在附加参数上。这里，不指定文件/文件夹位置，只是用名称匹配。

java -jar bfg.jar --delete-files RobotArm.sdf RobotArm.git

java -jar bfg.jar --delete-folders _Boot RobotArm.git

这样会有一个问题，这种情况bfg会保护当前版本(HEAD所指的版本)，不去清理。提示如下。

Protected commits
-----------------

These are your protected commits, and so their contents will NOT be altered:

 * commit ******* (protected by 'HEAD')

如果说当前版本已经没有问题，那么这么使用没有问题。

但是我的当前版本也是有需要删除的文件的，在谷歌搜索了一下，找到了解决方法。

在命令行下加入--no-blob-protection命令，可以解除保护。我使用的命令如下。

java -jar bfg.jar --delete-files RobotArm.sdf RobotArm.git --no-blob-protection

java -jar bfg.jar --delete-folders _Boot RobotArm.git --no-blob-protection

 4.清理不需要的数据

在完成上面的指令后，实际上这些数据/文件并没有被直接删除，这时候需要使用git gc指令来清除。

cd RobotArm.git
git reflog expire --expire=now --all && git gc --prune=now --aggressive

5.推送到GitHub

最后，更新完本地仓库后，将数据推送到GitHub远程仓库。按照官网描述，由于之前使用了--mirror参数，推送时会推送所有内容。

git push

