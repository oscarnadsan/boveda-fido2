# Bóveda FIDO2

An encrypted document vault built with [age](https://github.com/FiloSottile/age), one or more FIDO2 security keys supporting `hmac-secret`, and an emergency recovery mechanism requiring **both recovery passphrases**.

**Supported platforms:** macOS (Apple Silicon and Intel), Debian, and Ubuntu (x86-64 and ARM64). Requires Python 3.9+.

> **STATUS: Experimental / not security-audited.** The [`age-plugin-fido2-hmac`](https://github.com/olastor/age-plugin-fido2-hmac) dependency is also experimental. Do not rely on this application as the only copy of critical information. Test your backups and recovery process before using it for important data.

## Installation

```bash
unzip Boveda_FIDO2_GitHub_Mac_Debian_Ubuntu.zip
cd boveda-fido2-github
bash install.sh
```

The installer installs `age` and `libfido2` tools through Homebrew (macOS) or APT (Debian/Ubuntu), downloads the FIDO2 plugin if necessary, and configures `~/.local/bin` and Bash/Zsh tab completion. **It downloads a third-party executable without verifying its signature or checksum.** We recommend independently verifying the release or building the plugin from source before entrusting it with secrets. Review scripts before running them.

```bash
# Open a new terminal, then run:
boveda estado
boveda configurar   # New installations only
boveda verificar    # Verify two-passphrase recovery
```

If a vault already exists at `~/BovedaFIDO2`, the installer **does not delete** that directory. `boveda configurar` respects existing keys and does not replace them when the configuration is complete.

## Commands

| Command | Description |
|---|---|
| `boveda abrir` | Open the vault using a FIDO2 key or both recovery passphrases |
| `boveda cerrar` | Encrypt documents and close the vault |
| `boveda nuevo notes.md` | Create a `.txt`, `.md`, `.csv`, `.rtf`, or `.docx` document |
| `boveda add /path/to/file.pdf` | Copy files or directories into the vault without deleting the originals |
| `boveda listar` | List documents (vault must be open) |
| `boveda borrar file.pdf` | Delete a file from the open working folder after confirmation |
| `boveda ubicacion /path` | Set the encrypted vault location, including USB drives |
| `boveda backup /path` | Back up the encrypted vault and required metadata |
| `boveda exportar /path/new-folder` | Export **unencrypted** documents |
| `boveda llaves listar` | List registered FIDO2 identities |
| `boveda llaves anadir second` | Register an additional security key while the vault is open |
| `boveda llaves quitar second` | Remove a security key while the vault is open |
| `boveda claves cambiar` | Change **both** recovery passphrases |
| `boveda verificar` | Test two-passphrase recovery |
| `boveda desinstalar` | Uninstall the application without deleting vault data |

By default, encrypted documents are stored at `~/BovedaFIDO2/documentos.tar.age`, unless another location is configured. **Decrypted** documents are handled in `~/BovedaFIDO2/Trabajo` on the local computer, **not automatically on the USB drive**. Enable FileVault on macOS or full-disk encryption (such as LUKS) on Linux to help protect temporary files and residual data on the SSD.

### USB storage

macOS:

```bash
boveda ubicacion '/Volumes/MY_USB/Vault'
```

Debian/Ubuntu (example; adjust to your actual mount point):

```bash
boveda ubicacion '/media/username/MY_USB/Vault'
```

Make sure the volume is mounted, and do not unplug the USB drive while encryption is running. Changing the location copies the encrypted vault and verifies it using SHA-256, while keeping the previous copy.

### Multiple security keys

```bash
boveda abrir
boveda llaves anadir second
boveda cerrar
```

Confirm that the new key can decrypt the vault **after closing it**, before removing an old key. Previously encrypted files and older backups might still be accessible with removed keys. Adding or removing a key does not automatically revoke access to existing backups.

### Changing recovery passphrases

```bash
boveda claves cambiar
boveda verificar
```

Choose two different, non-empty passphrases: the application does not itself enforce that they differ. Passphrase entry is delegated to `age -p`; if you submit an empty entry, `age` may generate a passphrase automatically. **Verify the newly configured passphrases by completing a recovery test before relying on them.** Never publish passphrases, recovery keys, or identity files.

## Security risks and limitations

- **The `Trabajo` folder contains plaintext while the vault is open.** Closing the vault removes the directory using `shutil.rmtree`, which **does not guarantee secure erasure** on SSDs or from snapshots, Word caches, swap, and similar locations.
- An interrupted close operation can leave plaintext temporary files behind. Check `boveda estado` and the working directory before retrying. Save and close all document editors before running `boveda cerrar`.
- Backups are generated as `tar.gz` archives containing encrypted documents and plugin identities, **but the backup archive itself has no additional encryption**. Store it securely and separately from the computer. Periodically verify that you can restore it on another device.
- After changing passphrases, old backups of `recuperacion-doble.age` may still be unlocked with the previous passphrases. Key revocation likewise does not affect previously encrypted files.
- This implementation has not undergone a security audit. Multi-key operations, hardware integration, and recovery workflows require real-world testing on each platform. We do not claim secure deletion, protection against malware, or automatic vault locking when the computer sleeps.
- `age-plugin-fido2-hmac` reconstructs identities in computer memory; it **does not provide fully hardware-confined asymmetric encryption**.
- To recover from losing a USB drive, keep a separate copy of both the encrypted vault and the identity/recovery backup.

## Development and testing

```bash
python3 -m unittest discover -s tests -v
bash -n install.sh
python3 -m py_compile src/boveda
```

These are basic tests and **do not test cryptographic behavior or real FIDO2 device interaction**. No personal data or secrets are included in this repository.

## License

MIT. This is an independent project and is not affiliated with the authors of `age`, `libfido2`, or the FIDO2 plugin.
