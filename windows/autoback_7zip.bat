set "Ymd=%date:~,4%%date:~5,2%%date:~8,2%"

@echo ����WEB����...���Ե�
"C:\Program Files\7-Zip\7z" a  E:\backup\web_back\wwwwroot-%Ymd%.zip D:\wwwwroot -x@E:\backup\shell\Exclude-filenames.txt

"D:\mysql\bin\mysqldump.exe" --opt -Q minfang -uroot -pminfang123456 > E:\backup\mysql-%Ymd%.sql 