# Filldatabase - Fill your database easily !


### Requirements
[![Swift Version](https://img.shields.io/badge/Swift-3.1-orange.svg?style=flat-square)](https://swift.org) 


#### How can i declare my table ?
```
#
insert contact_enterprise
name;@name
forname;@forname
email;email
phone_number;phone
fonction;@fonction
street;@street
postal_code;postalcode
pays;@country
###
quantity:1
```

This request will produce this

```SQL
insert into contact_enterprise(name,forname,email,phone_number,fonction,street,postal_code,pays)
values('Germain','Louison','louison.germain@debian.org','06240228553','Electricien','37, ALLEE DES MERLES',03613,'Sao Tomé-et-Principe');
```

Data can be ...
```
phone -> Phone Number
lorem -> insert lorem impum string
datebirthday -> date from 1950
date 
postalcode
email
integer,min,max
%pk%,start
```