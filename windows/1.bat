
set "Ymd=%date:~,4%%date:~5,2%%date:~8,2%"
"C:\Program Files\7-Zip\7z" a E:\backup\autoback\backup%Ymd%.zip  D:\SQLServerData\Backup -xJL_qianbao*

winsock ready

set "Ymd=%date:~,4%%date:~5,2%%date:~8,2%"
net stop mysql
@echo 复制MySQL数据...请稍等
"C:\Program Files\7-Zip\7z" a D:\backup\autoback\mysqldata%Ymd%.zip D:\MySqlData\
net start mysql

@echo 复制WEB数据...请稍等
"C:\Program Files\7-Zip\7z" a  D:\backup\autoback\freehost%Ymd%.zip D:\freehost