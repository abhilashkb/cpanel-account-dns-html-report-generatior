#!/bin/bash

if ! cat /etc/trueuserdomains | grep $1 ; then

 cat /etc/trueuserdomains | cut -d':' -f2 > users
else
 cat /etc/trueuserdomains | grep $1 | cut -d':' -f2 > users
fi
> allcdomains.txt
while read username
do
echo $username

cat  /var/cpanel/userdata/$username/main | grep -A10000 addon_domains | grep -v addon_domains | grep -B10000 parked_domains | grep -v parked_domains  |sed 's/main_domain://g'| awk '{print $1}' | sed 's/://g' >> allcdomains.txt

done < users
sed -i '/^$/d' allcdomains.txt

> cpaneldomains
username="domain_check"
> $username.html

echo '<html>' >> $username.html
echo '<style>' >> $username.html

echo 'table, th, td {'>> $username.html
echo 'border: 1px solid black;'>> $username.html
echo  'border-collapse: collapse;'>> $username.html
echo '}'>> $username.html
echo '</style>'>> $username.html

echo '<table style="width:100%">' >> $username.html
 echo  '<tr>' >> $username.html
echo  '<th>'sl no'</th>' >> $username.html
 echo  '<th>'Domain name'</th>' >> $username.html
 echo  '<th>'Username'</th>'>> $username.html
 echo  '<th>'IP address'</th>'>> $username.html
 echo  '<th>'IP owner'</th>'>> $username.html
 echo  '<th>'Nameserver'</th>'>> $username.html
 echo  '<th>'MXrecord'</th>' >> $username.html
echo  '</tr>' >> $username.html
#username=`/scripts/whoowns $domainl`
#cat /var/cpanel/userdata/$username/main | grep -A1000 addon_domains | grep -v addon_domains | grep -B1000 parked_domains | grep -v parked_domains | sed 's/main_domain://g' | awk '{print $1}' | sed 's/://g' > allcdomains.txt
count=0
while read domain

do
count=$(($count + 1))

cuser=`/scripts/whoowns $domain`
ruser=`cat /etc/trueuserowners |grep $cuser| cut -d':' -f2|head -1`
ipaddress=`dig $domain +short  | cut -c 1-18` 
nameserver=`dig ns $domain +short   |tr -d ' ' |  tr  -d '[:blank:]'| awk '{print $1}'`
mxrecord=""`dig mx $domain +short  | tr  -d '[:blank:]'|head -1`
mxip=`dig mx $domain +short  |head -1 | cut -d' ' -f2 | xargs dig a +short  | sed '/root-servers.net/d'`
#registrar=$(whois $domain | grep -A1 'Registrar:' | grep -v ' Registrar:' |tr -d ' ' |  tr  -d '[:blank:]' | cut -c 1-20)
#if [ -z "$registrar" ]; then
#registrar=$(whois $domain | grep -i 'Registrar:' | cut -d':' -f2 | cut -c 1-17 |tr -d ' ' |  tr  -d '[:blank:]')
#fi
ipfo=$( echo "$ipaddress" | awk '{print $1}' | head -1 )
ipwn=$(whois "$ipfo" | grep -i 'NetName:' | cut -d':' -f2 |tr -d ' ' |  tr  -d '[:blank:]'| cut -c 1-12)
expd=$(whois "$domain" | grep -i 'Expiry date:'|cut -d':' -f2)


server=''
mx=''



#echo "|"$count'|'"$domain" '|' $registrar '| ip:'$ipaddress"'('"$ipwn')' '|' $nameserver '|' "$mx""|" >> cpaneldomains
echo $domain
 echo  '<tr>' >> $username.html
echo  '<td>'$count'</td>' >> $username.html
 echo  '<td><a href="http://'$domain'" 'target=\"_blank\"'>'$domain'</a></td>' >> $username.html
# echo  '<td>'$domain'('$username')''</td>' >> $username.html
 echo  '<td>'$cuser' /'$ruser'</td>'>> $username.html
 echo  '<td>'$server$ipaddress'</td>'>> $username.html
 echo  '<td>'$ipwn'</td>'>> $username.html
 echo  '<td>'$nameserver'</td>'>> $username.html
 echo  '<td>''('$mxip')'$mxrecord'</td>' >> $username.html 
echo  '</tr>' >> $username.html

#printf '|                       |           |                            |             ''|%4.4s|\n'"$mxrecord" >> cpaneldomains

done < allcdomains.txt
echo  '</table>' >> $username.html
echo '</html>' >> $username.html

host=$(hostname)

#sh  alldomaininfoold.sh $domainl

echo click to view domaindetails 'http://'$host'/'$username.html

 cp -f $username.html /usr/local/apache/htdocs/$username.html

