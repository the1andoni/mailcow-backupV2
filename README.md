At the Moment the script is doing a backup from the Mailcow Data, via mailcow-backup integrated script, into a nextcloud folder via Nextcloud-User and Nextcloud-User-PW or via sFTP.
<br>This script will compress this data into an tar.gz file and will Upload them.

For more informations about the mailcow-backup script, please watch the following Link:
<br>https://docs.mailcow.email/backup_restore/b_n_r-backup

<h1>Upload to Nextcloud</h1>
For Upload the Backup to Nextcloud please use the Mailcow_Backup-Nextcloud.sh script and provide the needed information.
<br>Following information are needed:
<br> - Nextcloud Url
<br> - Nextcloud User
<br> - Nextcloud User PW

I would recommend to create a new User for this Job (like Backup User) and only give him Access to the needed Directory.
<br>On this Way you make sure that, if you mailserver is hacked, the attacker can't see you full Nextcloud files.

<h1> Upload via sFTP</h1>
For Upload the Backup via sFTP please use the Mailcow_Backup-FTP.sh script and provide the needed information.
<br> Following information are needed:
<br> - Server IP
<br> - Portnumber
<br> - Username (For FTP User)
<br> - User-PW
<br> - Certificate-Fingerprint (Only if you need to Upload via SSL, Plain will Upload the File unsecure)
<br> - FTP Upload Directory


<br>
<br>Thx for reading this, and if you like this script, or have any Issues or feedback, leave a message ^^
<br>Alex / The1AndOni
