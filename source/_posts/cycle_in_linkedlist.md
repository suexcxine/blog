title: 找出链表中环的起点
date: 2016-03-16
tags: [algorithm]
---
haha
一般的思路是遍历链表,每一步的指针都记到一个字典里,
如果当前指针在字典里存在即环存在,该指针即环的起点,
这个字典能否省掉呢?

<!--more-->

## 检测链表是否有环,使用双指针追击法
从head出发,快指针一次走两步,慢指针一次走一步。
如果两指针在某一点相遇,证明环存在,否则环不存在(快指针必定会遇到NULL结束循环)

## 如何找到环的起点
如下图,假设链表有环,环长Y,环以外的长度是X。
![图片标题](http://leanote.com/api/file/getImage?fileId=56e8deb7ab6441777b002123)
如果两指针走了t次后相遇在K点,
那么

    慢指针走的路是 t = X + nY + K   ①
    快指针走的路是2t = X + mY + K   ②    m,n为未知数
    把等式一代入到等式二中, 有
    2X + 2nY + 2K = X + mY + K
    => X + K = (m - 2n)Y   ③

X+K即K+X, 即K的长度加X的长度相当于m-2n个整圈(Y)长度
而快指针此时在环中K的位置,所以从K点再走X步即可达环的起点(虽然可能多绕了几圈)
然而X是未知的,如何走X步呢?
让慢指针指向head,快慢指针这次都一步步地走,相遇时即都走了X步,也就是环的起点


    struct ListNode *detectCycle(struct ListNode *head) {                            
        struct ListNode *slow = head;                                                
        struct ListNode *fast = head;                                                
        while (fast != NULL) {                                                       
            slow = slow -> next;                                                     
            fast = fast -> next;                                                     
            if (fast != NULL) {                                                      
                fast = fast -> next;                                                 
            } else {                                                                 
                return NULL;                                                         
            }                                                                        
            if (slow == fast) break;                                                 
        }                                                                            
        if (fast == NULL) return NULL;                                               
        slow = head;                                                                 
        while (slow != fast) {                                                       
            slow = slow -> next;                                                     
            fast = fast -> next;                                                     
        }                                                                            
        return slow;                                                                 
    }  

## 参考链接
https://leetcode.com/problems/linked-list-cycle-ii/
http://fisherlei.blogspot.co.id/2013/11/leetcode-linked-list-cycle-ii-solution.html

