# для работы требуются plink.exe и pscp.exe
# https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

﻿#ip адрес и пароль керио
$ip='192.168.0.1'
$password='123456'

cd $PSScriptRoot
#$PSDefaultParameterValues = @{ '*:Encoding' = 'utf8' }
.\pscp -pw $password root@${ip}:/var/winroute/winroute.cfg winroute2.cfg
$data= Get-Date -Format "dd.MM.yyyy"
$text1='
  <listitem>
    <variable name="Id">'
$text2='</variable>
    <variable name="Enabled">1</variable>
    <variable name="Desc">загруженно из файла '+${data}+'</variable>
    <variable name="Name">'
$text3='</variable>
    <variable name="Value">'
$text4='</variable>
    <variable name="SharedId">0</variable>
  </listitem>'
$text=''
$br='
'
Remove-Item .\winroute.cfg
$conf=''
$l=1
$len=[int]@(Get-Content .\winroute2.cfg).Length
$ok=0
foreach($line_original in Get-Content .\winroute2.cfg) {
    $pr=$l/100
    Write-Progress -Activity "File processing" -status "Complete $pr %" -percentComplete ($l/$len*100)
    $l++
    if ($line_original.Contains('IpAccessList')){
        $line_original
        $ok=1
        $n=$line_original.Substring($line_original.IndexOf('"')+1)
        $n=$n.Substring($n.IndexOf('"')+1)
        $n=$n.Substring($n.IndexOf('"')+1)
        $n=[int]$n.Substring(0,$n.LastIndexOf('"'))
        $n


        #создаем список ip адресов по группам, название файла имя_группы.list

        foreach($ip_list in Get-ChildItem -Force .\ -filter '*.list') {
            $ip_list.Name
            $group_name=$ip_list.Name
            $group_name=$group_name.Substring(0,$group_name.LastIndexOf('.'))
            foreach($line in Get-Content $ip_list) {
                $line=$line.Trim()
                $n++
                if ($line.Contains("/")){
                    $text+=$text1+$n+$text2+$group_name+$text3+'prefix:'+$line+$text4
                }else{
                    $text+=$text1 + $n+$text2+$group_name+$text3+$line+$text4
                }

            }
        }
        $text
        $conf+='<list name="IpAccessList" identityCounter="'+$n+'">'+$br
    }else{
        if ($ok -eq 1 -And $line_original.Contains('</list>')){
            $ok = 2
            $conf+=$text

        }
        $conf+=$line_original+$br
       
    }
}

$conf | Set-Content -Path "$PSScriptRoot\winroute.cfg"

.\pscp -pw $password winroute.cfg root@${ip}:/var/winroute/winroute.cfg 
.\plink -pw $password root@$ip chmod 700 /var/winroute/winroute.cfg
.\plink -pw $password root@$ip /etc/boxinit.d/60winroute restart


