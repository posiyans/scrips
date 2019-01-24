#!/usr/bin/python3
from xml.dom import minidom
import glob
n=0
xmldoc = minidom.parse('winroute2.cfg')
itemlist = xmldoc.getElementsByTagName('list')
for l in itemlist:
	if (l.getAttribute("name")=='IpAccessList'):
		list=l.getElementsByTagName('variable')
		for l in list:
			if (l.getAttribute("name")=='Id'):
				if (n<int(l.firstChild.data)):
					n=int(l.firstChild.data)

text1='''
  <listitem>
    <variable name="Id">'''
text2='''</variable>
    <variable name="Enabled">1</variable>
    <variable name="Desc"></variable>
    <variable name="Name">'''
text3='''</variable>
    <variable name="Value">'''
text4='''</variable>
    <variable name="SharedId">0</variable>
  </listitem>'''
text=''
for filename in glob.glob('*.list'):
	with open(filename) as f:
		content = f.readlines()
		for line in content:
			ip=line.rstrip('\n').rstrip()
			group_name=filename[0:-5]
			#print(line.rstrip('\n').rstrip())
			if not (ip==''):
				n=n+1
				if not (ip.find('/') == -1):
					text+=text1+str(n)+text2+group_name+text3+'prefix:'+ip+text4
				else:
					text+=text1+str(n)+text2+group_name+text3+ip+text4
print(text)
f = open('rules.txt', 'w')
f.write(text)
f.close()
i=0
line_in=0
line_out=0
tt=''
with open('./winroute2.cfg') as f:
	content = f.readlines()
	for line in content:
		i=i+1
		if not (line_in == 0) and (line_out == 0) and (i > line_in):
			if not (line.find('</list>') == -1):
				line_out=i
				tt=tt+text+"\n"
		if not (line.find('IpAccessList') == -1):
			line_in=i
			tt=tt+'<list name="IpAccessList" identityCounter="'+str(n)+'">\n'
		else:
			tt=tt+line
f = open('winroute.cfg', 'w')
f.write(tt)
f.close
