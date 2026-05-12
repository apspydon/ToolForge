
**ToolForge** is a powerful, all‑in‑one terminal‑based manager that installs, runs, and organizes **200+ ethical hacking tools** from a single menu. It works on **macOS, Kali Linux, Ubuntu, Termux**, and any other Linux distribution. No more manual `git clone`, `make`, or `pip install` – ToolForge does everything for you interactively.

> 🚀 **One script to forge your entire pentesting arsenal.**

---

## ✨ Features

- 🧰 **200+ tools** across 17 categories (Info Gathering, Web Hacking, Wireless, Forensics, OSINT, etc.)
- 🖥️ **Fully interactive** – each tool prompts for the parameters it needs and runs immediately
- 🔄 **Automatic dependency resolution** – installs Go, Rust, Python, Homebrew, npm, and .NET on the fly
- 📦 **Install single tools or entire categories** – press `A` to install everything inside a category
- 🌐 **Your own tool** – NETEEN is included as option 1 in the main menu and also inside Wireless Attacks
- 🔗 **Visit my GitHub** – opens `https://github.com/apspydon` in your default browser
- 🎨 **Clean, colour‑coded terminal UI** – blue/white menus, green successes, orange warnings, red errors
- 💻 **Cross‑platform** – works on macOS (bash 3.2), all Linux distros, and Termux

---

## 📦 Installation

```bash
git clone https://github.com/apspydon/ToolForge.git
cd ToolForge
chmod +x ToolForge.sh
sudo ./ToolForge.sh
```
Note: Root/sudo is required because many tools need raw socket access or install system‑wide binaries.

🎮 How To Use

Run the script with sudo ./ToolForge.sh
The main menu shows 19 options:

1) NETEEN (my personal tool)
2) Information Gathering
3) Vulnerability Analysis
4) Web Application Hacking
5) Password Attacks
6) Wireless Attacks
7) Exploitation Frameworks
8) Post Exploitation
9) Forensics
10) Sniffing & Spoofing
11) Social Engineering
12) Reverse Engineering
13) OSINT
14) Network Utilities
15) Red Teaming & C2
16) Database Hacking
17) All‑in‑One Swiss Army
18) Install ALL tools
19) Visit my GitHub
0) Exit

Inside a category menu:

Type a number to install that specific tool, then choose to run it immediately
Press A to install all tools in that category
Press B to go back to the main menu
Follow the on‑screen prompts for each tool (e.g. target IP, wordlist path, scan type, etc.)
After installation, all tools are stored in ~/toolforge/ and can be reused later. The script will never exit unexpectedly – every command is handled with proper error messages.

📂 Tool Categories & Examples

Category	Example Tools
Information Gathering	nmap, masscan, rustscan, gobuster, ffuf, dnsrecon
Vulnerability Analysis	nikto, linpeas, searchsploit, wpscan, joomscan, cmsmap
Web Application Hacking	sqlmap, xsstrike, dalfox, commix, arjun
Password Attacks	john, hashcat, hydra, cewl, crunch, ncrack, crowbar, patator
Wireless Attacks	NETEEN, aircrack-ng, wifite, airgeddon, bettercap, reaver, pixiewps, hcxtools
Exploitation Frameworks	metasploit-framework, beef, setoolkit, linux-exploit-suggester, windows-exploit-suggester, shellnoob
Post Exploitation	nishang, linenum, seatbelt, sherlock
Forensics	binwalk, steghide, foremost, exiftool
Sniffing & Spoofing	ettercap, responder, dsniff, driftnet, ngrep, macchanger, arping, yersinia
Social Engineering	zphisher, camphish, kingphisher
Reverse Engineering	ghidra, radare2, cutter, pwndbg, gef, qiling
OSINT	recon-ng, spiderfoot, sherlock, photon, holehe, maigret
Network Utilities	socat, nethogs, bmon, vnstat, mtr, traceroute, iperf, proxychains-ng
Red Teaming & C2	covenant, starkiller, poshc2, pupy
Database Hacking	bbqsql, blisqy, patator, hydra, ncrack, sqlmap, nosqlmap
All‑in‑One Swiss Army	metasploit-framework, nmap, bettercap, beef, setoolkit, bloodhound, sqlmap, john, hydra
Note: NETEEN appears both in the main menu and as the first tool in the Wireless Attacks category.

⚙️ Requirements

macOS: Homebrew will be installed automatically if missing.
Linux: apt or yum (Debian/Ubuntu recommended – the script uses apt-get).
Termux: pkg package manager.
The script installs all needed dependencies (Go, Rust, Python3, pip, git, dotnet, npm) on the fly – you don’t need to prepare anything.

🛠️ Customization

To add your own tool, edit the read_tools_db function in ToolForge.sh and insert a new line with the format:
> category|type|toolname|repo_url|install_command

Then write an interactive runner function (e.g. run_mytool()) and add a case entry in the run_tool dispatch.

The script stores all cloned tools in ~/toolforge/. You can delete that folder to remove every tool.

🙏 Credits

All tools belong to their respective authors (repositories linked in the script).
ToolForge created by apspydon – a unified launcher for the ethical hacking community.

📜 License

This project is licensed under the MIT License – feel free to use, modify, and distribute.

⚠️ Disclaimer

ToolForge is intended only for ethical hacking, penetration testing, and educational purposes. Do not use any tool on systems you do not own or have explicit permission to test. The author is not responsible for any misuse or damage caused by this software.


## Run and Enjoy!
