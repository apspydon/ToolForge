ToolForge

ToolForge is a terminal menu for installing, running, and organizing 200+ ethical hacking tools. It works on macOS, Kali Linux, Ubuntu, Termux, and other Linux distributions. It handles git clones, builds, and package installs interactively, so you do not have to run them by hand.

Features

200+ tools across 17 categories, including Information Gathering, Web Hacking, Wireless, Forensics, and OSINT.
Interactive runners. Each tool prompts for the values it needs and then runs.
Dependency handling for Go, Rust, Python, Homebrew, npm, and .NET.
Install one tool or an entire category. Press A inside a category to install everything in it.
NETEEN is included as option 1 in the main menu and as the first tool in Wireless Attacks.
GitHub link opens https://github.com/apspydon in your default browser.
Colour-coded terminal output: blue/white menus, green successes, orange warnings, red errors.
Works on macOS with bash 3.2, most Linux distributions, and Termux.
Installation

bash
git clone https://github.com/apspydon/ToolForge.git
cd ToolForge
chmod +x ToolForge.sh
sudo ./ToolForge.sh
Root or sudo is required because many tools need raw socket access or install system-wide binaries.

Usage

Run the script:

bash
sudo ./ToolForge.sh
The main menu lists:

NETEEN
Information Gathering
Vulnerability Analysis
Web Application Hacking
Password Attacks
Wireless Attacks
Exploitation Frameworks
Post Exploitation
Forensics
Sniffing & Spoofing
Social Engineering
Reverse Engineering
OSINT
Network Utilities
Red Teaming & C2
Database Hacking
All-in-One Swiss Army
Install ALL tools
Visit my GitHub
Exit
Inside a category menu:

Type a number to install that specific tool. You can then choose to run it immediately.
Press A to install all tools in that category.
Press B to go back to the main menu.
Follow the prompts for each tool, such as target IP, wordlist path, or scan type.
Installed tools are stored in ~/toolforge/ and can be reused later. The script handles command failures with error messages instead of exiting unexpectedly.

Tool Categories and Examples

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
All-in-One Swiss Army	metasploit-framework, nmap, bettercap, beef, setoolkit, bloodhound, sqlmap, john, hydra
NETEEN appears both in the main menu and as the first tool in Wireless Attacks.

Requirements

macOS: Homebrew is installed automatically if missing.
Linux: apt or yum. Debian and Ubuntu are recommended because the script uses apt-get.
Termux: pkg package manager.
The script installs needed dependencies such as Go, Rust, Python3, pip, git, dotnet, and npm when required.

Customization

To add your own tool, edit the read_tools_db function in ToolForge.sh and add a new line:

text
category|type|toolname|repo_url|install_command
Then write an interactive runner function, for example run_mytool(), and add a case entry in the run_tool dispatch.

All cloned tools are stored in ~/toolforge/. Delete that folder to remove every tool.

Credits

All tools belong to their respective authors. Repository links are included in the script.

ToolForge was created by apspydon.

License

MIT License. You can use, modify, and distribute it.

Disclaimer

ToolForge is intended for ethical hacking, penetration testing, and educational use. Do not use any tool on systems you do not own or do not have explicit permission to test. The author is not responsible for misuse or damage caused by this software.
