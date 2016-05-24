# 发布博客
# git commit -a -m "update blog" && git push && \ 
ssh loc "docker start hexo && docker exec hexo sh -c 'git pull' && docker exec hexo hexo g -d"
