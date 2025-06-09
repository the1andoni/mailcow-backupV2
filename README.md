# mailcow Backup Script V2

Ein Bash-Skript zur Sicherung von mailcow-Daten mit Unterstützung für WebDAV- und FTP-Uploads. Dieses Projekt ermöglicht es, automatisierte Backups zu erstellen, zu verschlüsseln und auf Remote-Server hochzuladen.

## Ordnerstruktur

```
mailcow-BackupV2/
├── mailcow-backup.sh
├── setup.sh
├── Dependencies/
│   ├── Dependencies/dependencies.txt
│   └── Dependencies/install_dependencies.sh
├── Configs/
│   └── (verschlüsselte Konfigurationsdateien)
└── Upload/  
     ├── Upload/FTP-Upload.sh  
     └── Upload/WebDAV-Upload.sh
```

## Features

- **Automatisierte Backups**: Erstellt Backups von mailcow-Daten.
- **Verschlüsselung**: Konfigurationsdateien werden mit GPG verschlüsselt.
- **Remote-Upload**: Unterstützt WebDAV und FTP für das Hochladen von Backups.
- **Systemd-Timer-Integration**: Automatische Planung von Backups und Uploads.
- **Retention Management**: Löscht alte Backups lokal und remote basierend auf definierten Aufbewahrungszeiten.

## Voraussetzungen

- Betriebssystem: Linux
- Abhängigkeiten:
  - `gpg`
  - `curl`
  - `tar`
  - `systemd`

## Installation

1. **Repository herunterladen**:

   Sie können das Repository mithilfe von GitClone einfach runterladen.

   ```bash
   git clone https://github.com/the1andoni/mailcow-backupV2.git 
   ```
   
   Anschließend wechseln Sie in das neue Verzeichnis und machen die Scripte mithilfe folgendes Befehles ausführbar.

   ```bash
   chmod +x mailcow-backupV2/**/*.sh
   ```

   Alternativ steht ein Debian Packet zum Download zur Verfügung.

   ```bash
   wget https://github.com/the1andoni/mailcow-backupV2/releases/download/v2.0.0/mailcow-backup-v2.deb
   ```

2. **Abhängigkeiten installieren**:

   Sie können die Abhängigkeiten entweder manuell oder mit dem bereitgestellten Skript installieren:

   ```bash
   sudo xargs -a Dependencies/dependencies.txt apt install -y
   ```

   **Oder**:

   ```bash
   sudo ./Dependencies/install_dependencies.sh
   ```

3. **Setup ausführen**:

   Starten Sie das Setup-Skript, um die Konfigurationen zu erstellen und systemd-Timer einzurichten:

   ```bash
   sudo ./setup.sh
   ```

   Folgen Sie den Anweisungen im Skript, um die Backup-Methoden (WebDAV/FTP), Aufbewahrungszeiten und Zeitpläne zu konfigurieren.

## Automatisierte Backups & GPG-Passwort

Damit geplante Backups und Uploads ohne Interaktion funktionieren, wird das GPG-Passwort während des Setups automatisch in einer Datei (`/root/.mailcow-gpg-pass`) gespeichert.  
**Achtung:** Die Datei ist nur für root lesbar und wird vom Setup-Skript wie folgt angelegt:

```bash
echo "DEIN_GPG_PASSWORT" | sudo tee /root/.mailcow-gpg-pass > /dev/null
sudo chmod 600 /root/.mailcow-gpg-pass
```

Das Backup-Skript liest dieses Passwort automatisch ein und entschlüsselt damit die Konfiguration.  
**Hinweis:** Ändere das Passwort in dieser Datei nur, wenn du auch die Konfiguration neu verschlüsselst!

## Nutzung

- **Backup manuell starten**:

  ```bash
  sudo ./mailcow-backup.sh
  ```

- **WebDAV-Upload manuell starten**:

  ```bash
  sudo ./Upload/WebDAV-Upload.sh
  ```

- **FTP-Upload manuell starten**:

  ```bash
  sudo ./Upload/FTP-Upload.sh
  ```

- **Systemd-Timer für Backups verwalten**:
  - **Status überprüfen**:
    ```bash
    systemctl status mailcow-backup.timer
    ```
  - **Manuell starten**:
    ```bash
    systemctl start mailcow-backup.service
    ```
  - **Deaktivieren**:
    ```bash
    systemctl disable mailcow-backup.timer
    ```

- **Systemd-Timer für Exporte verwalten**:
  - **Status überprüfen**:
    ```bash
    systemctl status mailcow-export.timer
    ```
  - **Manuell starten**:
    ```bash
    systemctl start mailcow-export.service
    ```
  - **Deaktivieren**:
    ```bash
    systemctl disable mailcow-export.timer
    ```

## Konfiguration

Die Konfigurationsdateien werden während des Setups erstellt und verschlüsselt im Ordner `Configs` gespeichert. Sie enthalten sensible Informationen wie Zugangsdaten und sollten niemals unverschlüsselt gespeichert werden.

## Hinweis zum `.Configs`-Ordner

Der Ordner `.Configs` wird verwendet, um sensible Konfigurationsdateien zu speichern, die für den Betrieb des Skripts erforderlich sind. 

- Eine leere Datei namens `.gitkeep` wurde hinzugefügt, um sicherzustellen, dass der Ordner in Git enthalten ist.
- Bitte füge deine eigenen Konfigurationsdateien in diesen Ordner ein, nachdem du das Repository geklont hast. (Wird sonst automatisch vom `setup.sh`-Skript erstellt)
- Achte darauf, dass sensible Daten wie Zugangsdaten sicher gespeichert werden und nicht versehentlich in das Repository hochgeladen werden.

Falls der Ordner `.Configs` fehlt, wird er automatisch vom `setup.sh`-Skript erstellt.

## Automatisierung

Das Setup-Skript richtet automatisch systemd-Timer ein, um Backups und Uploads regelmäßig auszuführen. Die Timer können mit den folgenden Befehlen verwaltet werden:

- **Backup-Timer**:
  ```bash
  systemctl status mailcow-backup.timer
  ```
- **Export-Timer**:
  ```bash
  systemctl status mailcow-export.timer
  ```

## Sicherheit

- Die Konfigurationsdateien werden mit GPG verschlüsselt, um sensible Daten zu schützen.
- Für FTP-Uploads kann ein Zertifikat-Fingerabdruck angegeben werden, um die Verbindung abzusichern.
- Das GPG-Passwort wird sicher in `/root/.mailcow-gpg-pass` abgelegt und ist nur für root lesbar.

## Lizenz
Dieses Projekt steht unter der **CyberSpaceConsulting Public License v1.0**.  
Die vollständigen Lizenzbedingungen findest du in der [LICENSE](LICENSE)-Datei.

### Wichtige Punkte der Lizenz:
1. **Keine Weiterveräußerung oder öffentliche Verbreitung**:  
   Die Software darf nicht verkauft, unterlizenziert oder öffentlich weiterverbreitet werden, ohne vorherige schriftliche Genehmigung von CyberSpaceConsulting.
   
2. **Zentrale Verwaltung**:  
   Alle offiziellen Versionen und Updates werden ausschließlich über das ursprüngliche Repository verwaltet.

3. **Attribution erforderlich**:  
   Jede Nutzung oder Bereitstellung der Software muss die Herkunft des Projekts klar angeben:  
   "CyberSpaceConsulting – Original source available at the official repository."

4. **Kommerzielle Nutzung erlaubt (mit Einschränkungen)**:  
   Die Software darf in kommerziellen Kontexten verwendet werden, jedoch nicht als eigenständiges Produkt oder Dienstleistung weiterverkauft werden.

5. **Keine Garantie**:  
   Die Software wird "wie besehen" bereitgestellt, ohne jegliche Garantien oder Gewährleistungen.

6. **Verbotene Nutzung in KI-Training**:  
   Die Software darf nicht für das Training oder Fine-Tuning von KI-Modellen verwendet werden, ohne ausdrückliche Genehmigung.

Für weitere Informationen oder Genehmigungen, kontaktiere:  
📧 license@cyberspaceconsulting.de

---

### Feedback und Beiträge

Beiträge und Verbesserungsvorschläge sind willkommen! Erstellen Sie einfach ein Issue oder einen Pull Request.

---

### Autor

Erstellt von [The1AndOni](https://github.com/The1AndOni).
