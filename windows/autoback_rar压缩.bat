net stop mysql
@echo ����MySQL����...���Ե�
"C:\Program Files\WinRAR\Rar" a -k -r -s D:\backup\autoback\mysqldata%date% D:\MySqlData\
net start mysql

@echo ����WEB����...���Ե�
"C:\Program Files\WinRAR\Rar" a -r -x*\tst52237377 -x*\tst87895577 D:\backup\autoback\freehost%date% D:\freehost

"C:\Program Files\WinRAR\Rar" a -r D:\backup\autoback\tst52237377%date% D:\freehost\tst52237377

"C:\Program Files\WinRAR\Rar" a -r D:\backup\autoback\tst87895577%date% D:\freehost\tst87895577