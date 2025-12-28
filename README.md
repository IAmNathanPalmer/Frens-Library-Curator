# Frens Library Curator
This Library Curator is a portable Bash script for mirroring public-domain PDF books from the Frenschan Library. It preserves a large, historically significant collection from a controversial website pending shutdown, using stable IDs and resumable downloads.

The repository contains **only the script** and should run on cross-platform on macOS, Linux or Windows via WSL.
---

## Purpose

The Frenschan Library hosts a large, controversial, but historically significant collection of public-domain works. This script was written to preserve data before disappearance while it remains publicly accessible. 

It is designed to:
- Work on Linux, macOS, and other POSIX systems
- Avoid JavaScript emulation or headless browsers
- Resume interrupted downloads
- Remain readable, auditable, and boring (on purpose)

---

## Requirements

- Bash (Linux, macOS, WSL)
- `curl`
- `grep`, `sed`, `tr` (standard POSIX tools)
- Sufficient disk space (the full archive exceeds **90 GB**)

Windows users should run this via **WSL**.

---

## Usage

1. Create a directory where you want the library stored and change directory to that folder:
   ```sh
   mkdir library
   cd library
   ```

2. Copy the script into this directory (for example as `grab.sh`).

3. Make it executable from this directory:
   ```sh
   chmod a+x grab.sh
   ```

4. Run it:
   ```sh
   ./grab.sh
   ```

5. Wait. The script will take a long time to complete depending on connection speed.

You may safely stop and restart the script at any time. Existing files will be skipped and partial downloads resumed.

---

## Folder Naming Convention (Important)

Folders are named using **internal numeric category IDs**, for example:

```
Category_775/
Category_1187/
Category_42/
```

### Why numeric IDs are used

The Frenschan Library uses **JavaScript-based infinite scroll** for category pages. Because of this:

- Category membership is not fully exposed in server-rendered HTML
- Book listings cannot be reliably enumerated with static tools like `curl`
- Attempting to infer category contents would be fragile and misleading

Numeric category IDs are the **only stable, authoritative identifiers** available without emulating JavaScript.

Human-readable category names can be cross-referenced from the site’s category index if desired. As seen in links on the archive: https://web.archive.org/web/20250731233751/https://library.frenschan.org/category?data=category&sort_param=stored

---

## Ethics & Legality

- The script accesses **publicly available content**
- No authentication or access controls are bypassed
- Users are responsible for complying with applicable laws in their jurisdiction

This repository distributes a **tool**, not copyrighted material.

---

## License

MIT License. See the `LICENSE` file for details.
