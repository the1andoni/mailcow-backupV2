#!/bin/bash

# Variablen
BACKUP_DIR="/backup/mailcow"
FTP_SERVER="167.235.95.116"
FTP_PORT="21212"
FTP_USER="Bandsicherung"
FTP_PASS="AB85084CE026176579A5B914EBA8A999"
FTP_UPLOAD_DIR="E:\ambicon\Backup\MailServer (Kompimiert)"
MAILCOW_DIR="/opt/mailcow-dockerized"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_PATH="$BACKUP_DIR/mailcow-$DATE"
TAR_FILE="$BACKUP_DIR/mailcow-backup-$DATE.tar.gz"

# Sicherstellen, dass das Backup-Verzeichnis existiert
mkdir -p "$BACKUP_DIR"
mkdir -p "$BACKUP_PATH"  # Sicherstellen, dass das Backup-Verzeichnis existiert

echo "[+] Starte Mailcow-Backup..."

# Mailcow-Backup starten und Pfad direkt übergeben, ohne Abfrage
cd "$MAILCOW_DIR" || { echo "❌ Fehler: Mailcow-Verzeichnis nicht gefunden!"; exit 1; }

# Der folgende Befehl überspringt die interaktive Abfrage und übergibt den Backup-Pfad direkt#!/bin/bash

# Variablen
BACKUP_DIR="/backup/mailcow"
FTP_SERVER="167.235.95.116"
FTP_PORT="21212"
FTP_USER="Bandsicherung"
FTP_PASS="AB85084CE026176579A5B914EBA8A999"
FTP_CERTIFICATE="CERTIFICATE"
FTP_UPLOAD_DIR="/Backup"
MAILCOW_DIR="/opt/mailcow-dockerized"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
BACKUP_PATH="$BACKUP_DIR/mailcow-$DATE"
TAR_FILE="$BACKUP_DIR/mailcow-backup-$DATE.tar.gz"

# Sicherstellen, dass das Backup-Verzeichnis existiert
mkdir -p "$BACKUP_DIR"
mkdir -p "$BACKUP_PATH"  # Sicherstellen, dass das Backup-Verzeichnis existiert

echo "[+] Starte Mailcow-Backup..."

# Mailcow-Backup starten und Pfad direkt übergeben, ohne Abfrage
cd "$MAILCOW_DIR" || { echo "❌ Fehler: Mailcow-Verzeichnis nicht gefunden!"; exit 1; }

# Der folgende Befehl überspringt die interaktive Abfrage und übergibt den Backup-Pfad direkt
echo "$BACKUP_PATH" | ./helper-scripts/backup_and_restore.sh backup all --delete-days 7

# Prüfen, ob das Backup erstellt wurde
if [ ! -d "$BACKUP_PATH" ] || [ -z "$(ls -A "$BACKUP_PATH")" ]; then
    echo "❌ Fehler: Backup-Ordner ist leer oder wurde nicht erstellt!"
    exit 1
fi

echo "[+] Backup erfolgreich erstellt: $BACKUP_PATH"

# Backup in ein tar.gz-Archiv packen
tar -czvf "$TAR_FILE" -C "$BACKUP_DIR" "mailcow-$DATE"

# Prüfen, ob das Archiv existiert
if [ ! -f "$TAR_FILE" ]; then
    echo "❌ Fehler: Backup-Archiv wurde nicht erstellt!"
    exit 1
fi

echo "[+] Archiv erfolgreich erstellt: $TAR_FILE"

# Backup per FTP hochladen
echo "[+] Lade Backup per FTP hoch..."
ftp -inv $FTP_SERVER $FTP_PORT <<EOF
user $FTP_USER $FTP_PASS
quote SITE CERTIFICATE="$FTP_CERTIFICATE"
cd $FTP_UPLOAD_DIR
put $TAR_FILE
bye
EOF

# Prüfen, ob der Upload erfolgreich war
if [ $? -eq 0 ]; then
    echo "[✅] Backup erfolgreich per FTP hochgeladen!"
else
    echo "❌ Fehler: Upload per FTP fehlgeschlagen!"
    exit 1
fi

# Alte Backups löschen (nur die 7 neuesten behalten)
echo "[+] Prüfe, ob alte Backups gelöscht werden müssen..."
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)

if [ "$BACKUP_COUNT" -gt 7 ]; then
    DELETE_COUNT=$((BACKUP_COUNT - 7))
    echo "[!] Lösche die $DELETE_COUNT ältesten Backups..."
    ls -1t "$BACKUP_DIR"/*.tar.gz | tail -n "$DELETE_COUNT" | xargs rm -f
    echo "[+] Alte Backups gelöscht!"
else
    echo "[✅] Es sind weniger als 7 Backups vorhanden – kein Löschen nötig."
fi

# Temporäre Dateien löschen
rm -rf "$BACKUP_PATH"

echo "[✅] Backup abgeschlossen!"
echo "$BACKUP_PATH" | ./helper-scripts/backup_and_restore.sh backup all --delete-days 7

# Prüfen, ob das Backup erstellt wurde
if [ ! -d "$BACKUP_PATH" ] || [ -z "$(ls -A "$BACKUP_PATH")" ]; then
    echo "❌ Fehler: Backup-Ordner ist leer oder wurde nicht erstellt!"
    exit 1
fi

echo "[+] Backup erfolgreich erstellt: $BACKUP_PATH"

# Backup in ein tar.gz-Archiv packen
tar -czvf "$TAR_FILE" -C "$BACKUP_DIR" "mailcow-$DATE"

# Prüfen, ob das Archiv existiert
if [ ! -f "$TAR_FILE" ]; then
    echo "❌ Fehler: Backup-Archiv wurde nicht erstellt!"
    exit 1
fi

echo "[+] Archiv erfolgreich erstellt: $TAR_FILE"

# Backup per FTP hochladen
echo "[+] Lade Backup per FTP hoch..."
ftp -inv $FTP_SERVER $FTP_PORT <<EOF
user $FTP_USER $FTP_PASS
cd $FTP_UPLOAD_DIR
put $TAR_FILE
bye
EOF

# Prüfen, ob der Upload erfolgreich war
if [ $? -eq 0 ]; then
    echo "[✅] Backup erfolgreich per FTP hochgeladen!"
else
    echo "❌ Fehler: Upload per FTP fehlgeschlagen!"
    exit 1
fi

# Alte Backups löschen (nur die 7 neuesten behalten)
echo "[+] Prüfe, ob alte Backups gelöscht werden müssen..."
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/*.tar.gz 2>/dev/null | wc -l)

if [ "$BACKUP_COUNT" -gt 7 ]; then
    DELETE_COUNT=$((BACKUP_COUNT - 7))
    echo "[!] Lösche die $DELETE_COUNT ältesten Backups..."
    ls -1t "$BACKUP_DIR"/*.tar.gz | tail -n "$DELETE_COUNT" | xargs rm -f
    echo "[+] Alte Backups gelöscht!"
else
    echo "[✅] Es sind weniger als 7 Backups vorhanden – kein Löschen nötig."
fi

# Temporäre Dateien löschen
rm -rf "$BACKUP_PATH"

echo "[✅] Backup abgeschlossen!"