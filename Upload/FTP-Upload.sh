#!/bin/bash

# Überprüfen, ob das Skript mit sudo ausgeführt wird
if [ "$EUID" -ne 0 ]; then
  echo "Bitte führen Sie dieses Skript mit sudo aus."
  exit 1
fi

# Sicherstellen, dass das Backup abgeschlossen ist
if [ ! -f /tmp/mailcow-backup.status ]; then
  echo "❌ Fehler: Backup ist noch nicht abgeschlossen!"
  exit 1
fi

# Konfigurationsdatei entschlüsseln und laden
CONFIG_DIR="$(dirname "$0")/../Configs"
GPG_PASS_FILE="/root/.mailcow-gpg-pass"
if [ ! -f "$GPG_PASS_FILE" ]; then
  echo "❌ Fehler: GPG-Passwortdatei $GPG_PASS_FILE nicht gefunden!"
  exit 1
fi
gpg_password=$(cat "$GPG_PASS_FILE")
source <(echo "$gpg_password" | gpg --quiet --batch --passphrase-fd 0 --decrypt "$CONFIG_DIR/ftp-config.sh.gpg")

# Variablen
BACKUP_DIR="/backup/mailcow"
LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/*.tar.gz | head -n 1)

# Prüfen, ob ein Backup vorhanden ist
if [ ! -f "$LATEST_BACKUP" ]; then
  echo "❌ Fehler: Kein Backup gefunden!"
  exit 1
fi

# Backup per FTP hochladen
if [ -n "$FTP_CERTIFICATE_FINGERPRINT" ]; then
  echo "[+] Lade Backup per FTP mit TLS hoch..."
  curl --pinnedpubkey "$FTP_CERTIFICATE_FINGERPRINT" -u "$FTP_USER:$FTP_PASSWORD" -T "$LATEST_BACKUP" "ftp://$FTP_SERVER$FTP_UPLOAD_DIR"
else
  echo "[⚠️] Kein Zertifikat-Fingerabdruck angegeben. Lade Backup ohne TLS hoch..."
  curl -u "$FTP_USER:$FTP_PASSWORD" -T "$LATEST_BACKUP" "ftp://$FTP_SERVER$FTP_UPLOAD_DIR"
fi

# Prüfen, ob der Upload erfolgreich war
if [ $? -eq 0 ]; then
  echo "[✅] Backup erfolgreich per FTP hochgeladen!"
else
  echo "❌ Fehler: Upload per FTP fehlgeschlagen!"
  exit 1
fi

# Alte Backups lokal löschen
if [ -n "$LOCAL_RETENTION" ]; then
  echo "[+] Lösche lokale Backups, die älter als $LOCAL_RETENTION Tage sind..."
  find "$BACKUP_DIR" -type f -name "*.tar.gz" -mtime +"$LOCAL_RETENTION" -exec rm -f {} \;
  echo "[✅] Alte lokale Backups erfolgreich gelöscht."
else
  echo "[⚠️] Kein Löschintervall für lokale Backups definiert. Es werden keine alten Backups gelöscht."
fi