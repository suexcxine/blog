# 发布博客
git add source && git commit -m "修改博客" && git push 
ssh loc "docker exec hexo sh -c 'git pull'"
