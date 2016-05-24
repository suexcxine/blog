title: High Order Function
date: 2015-12-21
tags: programming
---
高阶函数可以提高代码的可复用性
<!--more-->
下例有许多重复的代码
```java
import java.util.ArrayList;                                                      
import java.util.List;                                                           
public class Customer {                                                          
    static public ArrayList<Customer> allCustomers = new ArrayList<Customer>();  
    public Integer id = 0;                                                       
    public String name = "";                                                     
    public String address = "";                                                  
    public String state = "";                                                    
    public String primaryContact = "";                                           
    public String domain = "";                                                   
    public Boolean enabled = true;                                               
    public Customer() {}                                                         
                                                                                 
    public static List<String> getEnabledCustomerNames() {                       
        ArrayList<String> outList = new ArrayList<String>();                     
        for(Customer customer : Customer.allCustomers) {                         
            if(customer.enabled) {                                               
                outList.add(customer.name);                                      
            }                                                                    
        }                                                                        
        return outList;                                                          
    }                                                                            
                                                                                 
    public static List<String> getEnabledCustomerStates() {                      
        ArrayList<String> outList = new ArrayList<String>();                     
        for(Customer customer : Customer.allCustomers) {                         
            if(customer.enabled) {                                               
                outList.add(customer.state);                                     
            }                                                                    
        }                                                                        
        return outList;                                                          
    }                                                                            
                                                                                 
    public static List<String> getEnabledCustomerPrimaryContacts() {
        ArrayList<String> outList = new ArrayList<String>();
        for(Customer customer : Customer.allCustomers) {
            if(customer.enabled) {
                outList.add(customer.primaryContact);
            }
        }
        return outList;
    }
    public static List<String> getEnabledCustomerDomains() {
        ArrayList<String> outList = new ArrayList<String>();
        for(Customer customer : Customer.allCustomers) {
            if(customer.enabled) {
                outList.add(customer.domain);
            }
        }
        return outList;
    }

    /* TODO: functions getting other fields */
}                 
```
上面的代码,有许多重复的行,如
```java
ArrayList<String> outList = new ArrayList<String>();                     
for(Customer customer : Customer.allCustomers) { 
    ...
}
return outList; 
```
如果可以传递函数,那么...的部分就可以通过调用一个函数参数来做,这部分代码就不需要重复了
用函数式编程语言下面这样的代码相当于上面的函数getEnabledCustomerNames,其中就传递了两个匿名函数
实现了lists:map和lists:filter这两个函数的复用
```erlang
lists:map(fun(#customer{name = Name}) -> Name end, 
    lists:filter(fun(#customer{enabled = E}) -> E end, L)).
```
或者更简洁的方式
```erlang
[Name || #customer{enabled = true, name = Name} <- L].
```

