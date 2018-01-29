# 发布博客
git add source && git commit -m "修改博客" && git push
ssh root@hal "docker exec hexo git pull"
