title: 记 RFC 5987 和 RFC 7578 给我带来的困扰
date: 2024-01-17 21:35:00
tags: [web, rails, telegram, rfc]
---

遇到一个下载链接不支持中文文件名的问题，查了一下好多不知道的东西冒了出来，RFC 5987, RFC 7578...

<!--more-->

rails 的 active storage 有一个为 blob 生成 url 的函数，文档如下:
https://edgeapi.rubyonrails.org/classes/ActiveStorage/Blob.html#method-i-url

生成出来的 url 大概这个样:
```html
https://suexcxine-test.s3.ap-southeast-1.amazonaws.com/lm4vky0jbnts7sih77d3d6ind197?response-content-disposition=inline%3B%20filename%3D%22%253F%253Fpdf.pdf%22%3B%20filename%2A%3DUTF-8%27%27%25E6%25B5%258B%25E8%25AF%2595pdf.pdf&response-content-type=application%2Fpdf&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIVOOJV2V5F72J24Q%2F20240117%2Fap-southeast-1%2Fs3%2Faws4_request&X-Amz-Date=20240117T085041Z&X-Amz-Expires=300&X-Amz-SignedHeaders=host&X-Amz-Signature=b8159ee599c4e5b771719eee026238481b44b47d535021e532f42c2cdaf03807
```
url decode 后这样:
```html
https://suexcxine-test.s3.ap-southeast-1.amazonaws.com/lm4vky0jbnts7sih77d3d6ind197?response-content-disposition=inline; filename="%3F%3Fpdf.pdf"; filename*=UTF-8''%E6%B5%8B%E8%AF%95pdf.pdf&response-content-type=application/pdf&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAIVOOJV2V5F72J24Q/20240117/ap-southeast-1/s3/aws4_request&X-Amz-Date=20240117T085041Z&X-Amz-Expires=300&X-Amz-SignedHeaders=host&X-Amz-Signature=b8159ee599c4e5b771719eee026238481b44b47d535021e532f42c2cdaf03807
```
可以看到其中有
filename="%3F%3Fpdf.pdf"; filename*=UTF-8''%E6%B5%8B%E8%AF%95pdf.pdf
继续 decode 可以得知 
"%3F%3Fpdf.pdf" 对应的是 "??pdf.pdf"
而 "%E6%B5%8B%E8%AF%95pdf.pdf" 对应的是 "测试pdf.pdf" ，也就是我上传的文件名

这里的 filename 和 filename* 并用的做法据说是 filename 比较老的，当时只支持 ASCII 字符，后来要支持其他字符集就搞了个 filename* ，也就是一个兼容的意思, 估计 rails 是把所有的非 ASCII 字符都换成了问号，这个做法据称来自下面这个 [RFC 5987](https://datatracker.ietf.org/doc/html/rfc5987), 太长我也没看

然而，我把上面那个 url 做为文件下载链接发给 telegram bot 的时候，用的这个 [api](https://core.telegram.org/bots/api#senddocument) ，telegram 那头给我显示出来的文件名是 "??pdf.pdf"，这怎么能忍？我明明发了 filename* 把 utf8 形式的中文给你了啊

于是就查查查，然后查到一个 telegram 相关的 [issue](https://github.com/tdlib/td/issues/1459#issuecomment-805417564) ，里面讲

There are no plans to support "filename*" directive, but UTF-8 characters are allowed in "filename", so it can be used to send files with arbitrary names. RFC7578 mandates that "The encoding method described in RFC5987, which would add a "filename*" parameter to the Content-Disposition header field, MUST NOT be used."

也就是说 [RFC 7578](https://datatracker.ietf.org/doc/html/rfc7578) 说不允许用 filename*，然后说 UTF-8 字符可以放到 filename 里 ......

卒
