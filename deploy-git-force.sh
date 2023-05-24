# 删除 Git 记录
rm -rf .git

# 初始化 Git 并提交
git init
git add -A
git commit -m 'deploy'

# 提交代码

# 需要配置好 Gitee SSH 密钥
# https://gitee.com/tishenme/smallbird-bigdata
echo -e "\n###### Push Gitee ######\n"
git push -f git@gitee.com:tishenme/smallbird-bigdata.git master:master

# 需要配置好 Github SSH 密钥
# https://github.com/tishenme/smallbird-bigdata
echo -e "\n###### Push Github ######\n"
git push -f git@github.com:tishenme/smallbird-bigdata.git master:master