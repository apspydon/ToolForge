#!/bin/bash
# ToolForge v1.0 - Complete interactive ethical hacking toolkit
# Every tool has its own runner. Works on macOS, Linux, Termux.

# Colors
BLUE='\033[0;34m'
WHITE='\033[1;37m'
NC='\033[0m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
RED='\033[0;31m'

BASE_DIR="$HOME/toolforge"
mkdir -p "$BASE_DIR"

export PATH="$HOME/go/bin:$HOME/.cargo/bin:/opt/homebrew/bin:$PATH"
hash -r 2>/dev/null

# Detect OS
OS="linux"
[[ "$OSTYPE" == "darwin"* ]] && OS="macos"
[[ -n "$PREFIX" && "$PREFIX" == "/data/data/com.termux"* ]] && OS="termux"

# Package manager setup
setup_pkg_manager() {
    if [[ "$OS" == "linux" ]]; then
        PKG_INSTALL="sudo apt-get install -y"
    elif [[ "$OS" == "macos" ]]; then
        if ! command -v brew &>/dev/null; then
            echo -e "${ORANGE}Installing Homebrew...${NC}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
        fi
        PKG_INSTALL="brew install"
    else
        PKG_INSTALL="pkg install -y"
    fi
}

# Install prerequisites (Go, Rust, Python, git, .NET, npm, etc.)
install_prerequisites() {
    echo -e "${ORANGE}Checking prerequisites...${NC}"
    if ! command -v git &>/dev/null; then
        echo -e "${ORANGE}Installing git...${NC}"
        eval "$PKG_INSTALL git" >/dev/null 2>&1
    fi
    if ! command -v python3 &>/dev/null; then
        echo -e "${ORANGE}Installing python3...${NC}"
        eval "$PKG_INSTALL python3" >/dev/null 2>&1
    fi
    if ! command -v pip3 &>/dev/null; then
        echo -e "${ORANGE}Installing pip3...${NC}"
        if [[ "$OS" == "macos" ]]; then
            brew install python3 >/dev/null 2>&1
        else
            eval "$PKG_INSTALL python3-pip" >/dev/null 2>&1
        fi
    fi
    if ! command -v go &>/dev/null; then
        echo -e "${ORANGE}Installing Go...${NC}"
        if [[ "$OS" == "macos" ]]; then
            brew install go >/dev/null 2>&1
        else
            eval "$PKG_INSTALL golang-go" >/dev/null 2>&1
        fi
        export PATH="$HOME/go/bin:$PATH"
    fi
    if ! command -v cargo &>/dev/null; then
        echo -e "${ORANGE}Installing Rust...${NC}"
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y >/dev/null 2>&1
        source "$HOME/.cargo/env"
        export PATH="$HOME/.cargo/bin:$PATH"
    fi
    if ! command -v dotnet &>/dev/null && [[ "$OS" != "termux" ]]; then
        echo -e "${ORANGE}.NET not found – Covenant will not work. Install .NET SDK from https://dotnet.microsoft.com${NC}"
    fi
    if ! command -v npm &>/dev/null && [[ "$OS" != "termux" ]]; then
        echo -e "${ORANGE}npm not found – Starkiller may not work. Install Node.js from https://nodejs.org${NC}"
    fi
    pip3 install --user cherrypy fuzzywuzzy >/dev/null 2>&1
    echo -e "${GREEN}Prerequisites ready.${NC}"
    sleep 1
}

# ------------------------------------------------------------
# ASCII BANNER
# ------------------------------------------------------------
show_banner() {
    clear
    echo -e "${BLUE}"
    cat << "EOF"
    ╔════════════════════════════════════════════════════════════╗
    ║                                                            ║
    ║                                                            ║
 ___║_____  ________  ________  ___       ________ ________  ____║___  ________  _______      
|\___   ___\\   __  \|\   __  \|\  \     |\  _____\\   __  \|\   __  \|\   ____\|\  ___ \     
\|___ \  \_\ \  \|\  \ \  \|\  \ \  \    \ \  \__/\ \  \|\  \ \  \|\  \ \  \___|\ \   __/|    
    ║\ \  \ \ \  \\\  \ \  \\\  \ \  \    \ \   __\\ \  \\\  \ \   _  _\ \  \  __\ \  \_|/__  
    ║ \ \  \ \ \  \\\  \ \  \\\  \ \  \____\ \  \_| \ \  \\\  \ \  \\  \\ \  \|\  \ \  \_|\ \ 
    ║  \ \__\ \ \_______\ \_______\ \_______\ \__\   \ \_______\ \__\\ _\\ \_______\ \_______\
    ║   \|__|  \|_______|\|_______|\|_______|\|__|    \|_______|\|__|\|__|\|_______|\|_______|
    ║                                                            ║                            
    ║                                                            ║                            
    ║                                                            ║                             
    ║                                                            ║
    ║                      ToolForge                             ║
    ║                    made by apspydon                        ║
    ║                                                            ║
    ╚════════════════════════════════════════════════════════════╝
EOF
    echo -e "${WHITE}"
}

# ------------------------------------------------------------
# TOOL DATABASE (category|type|name|source|install_cmd)
# ------------------------------------------------------------
declare -a tool_cat tool_type tool_name tool_source tool_install

read_tools_db() {
    tool_cat=(); tool_type=(); tool_name=(); tool_source=(); tool_install=()
    while IFS='|' read -r cat type name source install; do
        [[ -z "$cat" || "$cat" == \#* ]] && continue
        tool_cat+=("$cat")
        tool_type+=("$type")
        tool_name+=("$name")
        tool_source+=("$source")
        tool_install+=("$install")
    done << 'EOF'
1|pkg|nmap|nmap|brew install nmap
1|pkg|masscan|masscan|brew install masscan
1|rust|rustscan|rustscan|cargo install rustscan
1|go|gobuster|github.com/OJ/gobuster/v3|go install github.com/OJ/gobuster/v3@latest
1|go|ffuf|github.com/ffuf/ffuf/v2|go install github.com/ffuf/ffuf/v2@latest
1|git|dnsrecon|https://github.com/darkoperator/dnsrecon.git|pip3 install -r requirements.txt
2|git|nikto|https://github.com/sullo/nikto.git|perl Makefile.PL; make
2|git|linpeas|https://github.com/carlospolop/PEASS-ng.git|chmod +x linpeas.sh
2|git|searchsploit|https://github.com/offensive-security/exploitdb.git|make
2|git|wpscan|https://github.com/wpscanteam/wpscan.git|gem install wpscan
2|git|droopescan|https://github.com/SamJoan/droopescan.git|pip3 install -r requirements.txt
2|git|joomscan|https://github.com/rezasp/joomscan.git|chmod +x joomscan.pl
2|git|cmsmap|https://github.com/Dionach/CMSmap.git|pip3 install -r requirements.txt
3|git|sqlmap|https://github.com/sqlmapproject/sqlmap.git|python3 setup.py install
3|git|xsstrike|https://github.com/s0md3v/XSStrike.git|pip3 install -r requirements.txt
3|go|dalfox|github.com/hahwul/dalfox/v2|go install github.com/hahwul/dalfox/v2@latest
3|git|commix|https://github.com/commixproject/commix.git|python3 setup.py install
3|git|arjun|https://github.com/s0md3v/Arjun.git|pip3 install -r requirements.txt
4|git|john|https://github.com/openwall/john.git|make
4|git|hashcat|https://github.com/hashcat/hashcat.git|make
4|git|hydra|https://github.com/vanhauser-thc/thc-hydra.git|./configure; make
4|git|cewl|https://github.com/digininja/CeWL.git|gem install cewl
4|git|crunch|https://github.com/crunchsec/crunch.git|make
4|git|ncrack|https://github.com/nmap/ncrack.git|./configure; make
4|git|crowbar|https://github.com/galkan/crowbar.git|python3 setup.py install
4|git|patator|https://github.com/lanjelot/patator.git|python3 setup.py install
5|git|neteen|https://github.com/apspydon/NETEEN.git|chmod +x NETEEN.sh
5|git|aircrack-ng|https://github.com/aircrack-ng/aircrack-ng.git|./configure; make
5|git|wifite|https://github.com/derv82/wifite.git|pip3 install -r requirements.txt
5|git|airgeddon|https://github.com/v1s1t0r1sh3r3/airgeddon.git|chmod +x airgeddon.sh
5|git|bettercap|https://github.com/bettercap/bettercap.git|make build
5|git|reaver|https://github.com/t6x/reaver-wps-fork-t6x.git|./configure; make
5|git|pixiewps|https://github.com/wiire/pixiewps.git|make
5|git|hcxtools|https://github.com/ZerBea/hcxtools.git|make
6|git|metasploit-framework|https://github.com/rapid7/metasploit-framework.git|bundle install
6|git|beef|https://github.com/beefproject/beef.git|./install
6|git|setoolkit|https://github.com/trustedsec/social-engineer-toolkit.git|python3 setup.py install
6|git|linux-exploit-suggester|https://github.com/mzet-/linux-exploit-suggester.git|chmod +x les.sh
6|git|windows-exploit-suggester|https://github.com/AonCyberLabs/Windows-Exploit-Suggester.git|pip3 install -r requirements.txt
6|git|shellnoob|https://github.com/reyammer/shellnoob.git|python3 setup.py install
7|git|nishang|https://github.com/samratashok/nishang.git|echo
7|git|linenum|https://github.com/rebootuser/LinEnum.git|chmod +x LinEnum.sh
7|git|seatbelt|https://github.com/GhostPack/Seatbelt.git|dotnet build
7|git|sherlock|https://github.com/rasta-mouse/Sherlock.git|echo
8|git|binwalk|https://github.com/ReFirmLabs/binwalk.git|python3 setup.py install
8|git|steghide|https://github.com/StefanoDeVuono/steghide.git|./configure; make
8|git|foremost|https://github.com/raddyfiy/foremost.git|make
8|git|exiftool|https://github.com/exiftool/exiftool.git|make test
9|git|ettercap|https://github.com/Ettercap/ettercap.git|mkdir build; cd build; cmake ..; make
9|git|responder|https://github.com/SpiderLabs/Responder.git|pip3 install -r requirements.txt
9|git|dsniff|https://github.com/dugsong/dsniff.git|./configure; make
9|git|driftnet|https://github.com/deiv/driftnet.git|make
9|git|ngrep|https://github.com/jpr5/ngrep.git|./configure; make
9|git|macchanger|https://github.com/alobbs/macchanger.git|./configure; make
9|git|arping|https://github.com/ThomasHabets/arping.git|./bootstrap; ./configure; make
9|git|yersinia|https://github.com/tomac/yersinia.git|./configure; make
10|git|zphisher|https://github.com/htr-tech/zphisher.git|chmod +x zphisher.sh
10|git|camphish|https://github.com/techchipnet/CamPhish.git|chmod +x camphish.sh
10|git|kingphisher|https://github.com/securestate/king-phisher.git|python3 setup.py install
11|git|ghidra|https://github.com/NationalSecurityAgency/ghidra.git|gradle build
11|git|radare2|https://github.com/radareorg/radare2.git|sys/install.sh
11|git|cutter|https://github.com/rizinorg/cutter.git|qmake; make
11|git|pwndbg|https://github.com/pwndbg/pwndbg.git|./setup.sh
11|git|gef|https://github.com/hugsy/gef.git|wget -O ~/.gdbinit-gef.py -q https://gef.blah.cat/py
11|git|qiling|https://github.com/qilingframework/qiling.git|pip3 install -r requirements.txt
12|git|recon-ng|https://github.com/lanmaster53/recon-ng.git|pip3 install -r requirements.txt
12|git|spiderfoot|https://github.com/smicallef/spiderfoot.git|pip3 install -r requirements.txt
12|git|sherlock|https://github.com/sherlock-project/sherlock.git|python3 setup.py install
12|git|photon|https://github.com/s0md3v/Photon.git|pip3 install -r requirements.txt
12|git|holehe|https://github.com/megadose/holehe.git|python3 setup.py install
12|git|maigret|https://github.com/soxoj/maigret.git|pip3 install -r requirements.txt
13|git|socat|https://github.com/andrew-d/static-binaries.git|make
13|git|nethogs|https://github.com/raboof/nethogs.git|make
13|git|bmon|https://github.com/tgraf/bmon.git|./configure; make
13|git|vnstat|https://github.com/vergoh/vnstat.git|./configure; make
13|git|mtr|https://github.com/traviscross/mtr.git|./bootstrap.sh; ./configure; make
13|git|traceroute|https://github.com/iputils/iputils.git|make
13|git|iperf|https://github.com/esnet/iperf.git|./configure; make
13|git|proxychains-ng|https://github.com/rofl0r/proxychains-ng.git|./configure; make
14|git|covenant|https://github.com/cobbr/Covenant.git|dotnet build
14|git|starkiller|https://github.com/BC-SECURITY/Starkiller.git|npm install; npm start
14|git|poshc2|https://github.com/nettitude/PoshC2.git|./Install.sh
14|git|pupy|https://github.com/n1nj4sec/pupy.git|python3 pupy.py
15|git|bbqsql|https://github.com/Neohapsis/bbqsql.git|python3 setup.py install
15|git|blisqy|https://github.com/JohnTroony/Blisqy.git|python3 blisqy.py
15|git|patator|https://github.com/lanjelot/patator.git|python3 setup.py install
15|git|hydra|https://github.com/vanhauser-thc/thc-hydra.git|./configure; make
15|git|ncrack|https://github.com/nmap/ncrack.git|./configure; make
15|git|sqlmap|https://github.com/sqlmapproject/sqlmap.git|python3 setup.py install
15|git|nosqlmap|https://github.com/codingo/NoSQLMap.git|pip3 install -r requirements.txt
16|git|metasploit-framework|https://github.com/rapid7/metasploit-framework.git|bundle install
16|pkg|nmap|nmap|brew install nmap
16|git|bettercap|https://github.com/bettercap/bettercap.git|make build
16|git|beef|https://github.com/beefproject/beef.git|./install
16|git|setoolkit|https://github.com/trustedsec/social-engineer-toolkit.git|python3 setup.py install
16|git|bloodhound|https://github.com/BloodHoundAD/BloodHound.git|npm install; npm start
16|git|sqlmap|https://github.com/sqlmapproject/sqlmap.git|python3 setup.py install
16|git|john|https://github.com/openwall/john.git|make
16|git|hydra|https://github.com/vanhauser-thc/thc-hydra.git|./configure; make
EOF
}

# ------------------------------------------------------------
# INTERACTIVE RUNNERS FOR EVERY TOOL (complete list)
# ------------------------------------------------------------

run_neteen() {
    echo -e "${BLUE}▶ NETEEN - Network Assessment Tool${NC}"
    cd "$BASE_DIR/NETEEN" || { echo -e "${RED}NETEEN not installed. Install it first.${NC}"; return; }
    bash NETEEN.sh
}

run_nmap() {
    echo -e "${BLUE}▶ Nmap - Network Mapper${NC}"
    read -p "Target (IP, range, domain): " target
    [[ -z "$target" ]] && echo -e "${RED}Target required${NC}" && return
    read -p "Scan type (1=Quick,2=Full,3=Service/OS,4=Custom): " stype
    case $stype in
        2) flags="-sS -p- -T4" ;;
        3) flags="-sV -O -A" ;;
        4) read -p "Flags: " flags ;;
        *) flags="-F -T4" ;;
    esac
    sudo nmap $flags "$target"
}

run_masscan() {
    echo -e "${BLUE}▶ Masscan - Fast port scanner${NC}"
    read -p "Target IP/range: " target
    [[ -z "$target" ]] && echo -e "${RED}Target required${NC}" && return
    read -p "Ports [80,443,22,8080]: " ports
    ports="${ports:-80,443,22,8080}"
    read -p "Rate [1000]: " rate
    rate="${rate:-1000}"
    sudo masscan "$target" -p"$ports" --rate="$rate"
}

run_rustscan() {
    echo -e "${BLUE}▶ RustScan - Fast port scanner${NC}"
    read -p "Target IP: " target
    [[ -z "$target" ]] && echo -e "${RED}Target required${NC}" && return
    rustscan -a "$target" -- -sV
}

run_gobuster() {
    echo -e "${BLUE}▶ Gobuster - Directory brute‑forcing${NC}"
    read -p "URL (http://example.com): " url
    [[ -z "$url" ]] && echo -e "${RED}URL required${NC}" && return
    read -p "Wordlist [/usr/share/wordlists/dirb/common.txt]: " wordlist
    wordlist="${wordlist:-/usr/share/wordlists/dirb/common.txt}"
    gobuster dir -u "$url" -w "$wordlist"
}

run_ffuf() {
    echo -e "${BLUE}▶ FFUF - Web fuzzer${NC}"
    read -p "URL with FUZZ (http://example.com/FUZZ): " url
    [[ -z "$url" ]] && echo -e "${RED}URL required${NC}" && return
    read -p "Wordlist [/usr/share/wordlists/dirb/common.txt]: " wordlist
    wordlist="${wordlist:-/usr/share/wordlists/dirb/common.txt}"
    ffuf -u "$url" -w "$wordlist"
}

run_dnsrecon() {
    echo -e "${BLUE}▶ DNSRecon - DNS enumeration${NC}"
    read -p "Domain: " domain
    [[ -z "$domain" ]] && echo -e "${RED}Domain required${NC}" && return
    cd "$BASE_DIR/dnsrecon" || return
    python3 dnsrecon.py -d "$domain"
}

run_nikto() {
    echo -e "${BLUE}▶ Nikto - Web server scanner${NC}"
    read -p "Target URL or IP: " target
    [[ -z "$target" ]] && echo -e "${RED}Target required${NC}" && return
    cd "$BASE_DIR/nikto" || return
    perl nikto.pl -h "$target"
}

run_linpeas() {
    echo -e "${BLUE}▶ LinPEAS - Linux privilege escalation${NC}"
    cd "$BASE_DIR/linpeas" || return
    bash linpeas.sh 2>/dev/null || echo -e "${RED}linpeas.sh not found${NC}"
}

run_searchsploit() {
    echo -e "${BLUE}▶ SearchSploit - Exploit database${NC}"
    read -p "Search term: " term
    [[ -z "$term" ]] && echo -e "${RED}Term required${NC}" && return
    searchsploit "$term"
}

run_wpscan() {
    echo -e "${BLUE}▶ WPScan - WordPress scanner${NC}"
    read -p "WordPress URL: " url
    [[ -z "$url" ]] && echo -e "${RED}URL required${NC}" && return
    wpscan --url "$url"
}

run_droopescan() {
    echo -e "${BLUE}▶ Droopescan - CMS vulnerability scanner${NC}"
    read -p "Target URL (e.g., http://example.com): " url
    [[ -z "$url" ]] && echo -e "${RED}URL required${NC}" && return
    read -p "CMS type (drupal, wordpress, joomla, etc.) [drupal]: " cms
    cms="${cms:-drupal}"
    cd "$BASE_DIR/droopescan" || return
    python3 droopescan.py scan "$cms" --url "$url"
}

run_joomscan() {
    echo -e "${BLUE}▶ JoomScan - Joomla scanner${NC}"
    read -p "Joomla URL: " url
    [[ -z "$url" ]] && echo -e "${RED}URL required${NC}" && return
    cd "$BASE_DIR/joomscan" || return
    perl joomscan.pl -u "$url"
}

run_cmsmap() {
    echo -e "${BLUE}▶ CMSmap - CMS security scanner${NC}"
    read -p "Target URL: " url
    [[ -z "$url" ]] && echo -e "${RED}URL required${NC}" && return
    cd "$BASE_DIR/cmsmap" || return
    python3 cmsmap.py -t "$url"
}

run_sqlmap() {
    echo -e "${BLUE}▶ SQLmap - SQL injection${NC}"
    read -p "Target URL: " url
    [[ -z "$url" ]] && echo -e "${RED}URL required${NC}" && return
    read -p "Options (--dbs --batch): " opts
    opts="${opts:---batch}"
    if command -v sqlmap &>/dev/null; then
        sqlmap -u "$url" $opts
    else
        cd "$BASE_DIR/sqlmap" || return
        python3 sqlmap.py -u "$url" $opts
    fi
}

run_xsstrike() {
    echo -e "${BLUE}▶ XSStrike - XSS detection${NC}"
    read -p "Target URL: " url
    [[ -z "$url" ]] && echo -e "${RED}URL required${NC}" && return
    cd "$BASE_DIR/xsstrike" || return
    python3 xsstrike.py -u "$url"
}

run_dalfox() {
    echo -e "${BLUE}▶ Dalfox - XSS scanner${NC}"
    read -p "Target URL: " url
    [[ -z "$url" ]] && echo -e "${RED}URL required${NC}" && return
    [[ "$url" != http://* && "$url" != https://* ]] && url="https://$url"
    dalfox url "$url"
}

run_commix() {
    echo -e "${BLUE}▶ Commix - Command injection${NC}"
    read -p "Target URL: " url
    [[ -z "$url" ]] && echo -e "${RED}URL required${NC}" && return
    cd "$BASE_DIR/commix" || return
    python3 commix.py --url="$url"
}

run_arjun() {
    echo -e "${BLUE}▶ Arjun - HTTP parameter discovery${NC}"
    read -p "Target URL: " url
    [[ -z "$url" ]] && echo -e "${RED}URL required${NC}" && return
    cd "$BASE_DIR/arjun" || return
    python3 arjun.py -u "$url"
}

run_john() {
    echo -e "${BLUE}▶ John the Ripper - password cracker${NC}"
    read -p "Hash file path: " hashfile
    [[ -z "$hashfile" || ! -f "$hashfile" ]] && echo -e "${RED}Valid file required${NC}" && return
    read -p "Wordlist [rockyou.txt]: " wordlist
    wordlist="${wordlist:-/usr/share/wordlists/rockyou.txt}"
    cd "$BASE_DIR/john/run" || return
    ./john --wordlist="$wordlist" "$hashfile"
}

run_hashcat() {
    echo -e "${BLUE}▶ Hashcat - GPU password recovery${NC}"
    read -p "Hash file: " hashfile
    [[ -z "$hashfile" || ! -f "$hashfile" ]] && echo -e "${RED}Valid file required${NC}" && return
    read -p "Hash type (0=MD5, 100=SHA1, etc.): " hashtype
    read -p "Wordlist: " wordlist
    hashcat -m "$hashtype" -a 0 "$hashfile" "$wordlist"
}

run_hydra() {
    echo -e "${BLUE}▶ Hydra - login cracker${NC}"
    read -p "Target (e.g., ssh://192.168.1.1): " target
    read -p "Username list: " userlist
    read -p "Password list: " passlist
    hydra -L "$userlist" -P "$passlist" "$target"
}

run_cewl() {
    echo -e "${BLUE}▶ CeWL - custom wordlist generator${NC}"
    read -p "Target URL: " url
    [[ -z "$url" ]] && echo -e "${RED}URL required${NC}" && return
    read -p "Depth [2]: " depth
    depth="${depth:-2}"
    cewl -d "$depth" "$url"
}

run_crunch() {
    echo -e "${BLUE}▶ Crunch - wordlist generator${NC}"
    read -p "Minimum length: " min
    read -p "Maximum length: " max
    read -p "Charset (e.g., abc123): " charset
    read -p "Output file: " outfile
    cd "$BASE_DIR/crunch" || return
    ./crunch "$min" "$max" "$charset" -o "$outfile"
}

run_ncrack() {
    echo -e "${BLUE}▶ Ncrack - network auth cracker${NC}"
    read -p "Target (e.g., ssh://192.168.1.1): " target
    read -p "User list: " userlist
    read -p "Password list: " passlist
    ncrack -U "$userlist" -P "$passlist" "$target"
}

run_crowbar() {
    echo -e "${BLUE}▶ Crowbar - brute‑force tool${NC}"
    read -p "Target IP: " ip
    read -p "Service (ssh, openvpn, etc.): " service
    read -p "User list: " userlist
    read -p "Password list: " passlist
    crowbar -b "$service" -s "$ip" -U "$userlist" -C "$passlist"
}

run_patator() {
    echo -e "${BLUE}▶ Patator - multi‑purpose brute‑forcer${NC}"
    echo "Example: patator ssh_login host=192.168.1.1 user=root password=FILE0 0=passwords.txt"
    read -p "Enter patator command: " cmd
    eval "$cmd"
}

run_aircrack() {
    echo -e "${BLUE}▶ Aircrack‑ng - WiFi cracking${NC}"
    read -p "Capture file (.cap): " capfile
    [[ -z "$capfile" || ! -f "$capfile" ]] && echo -e "${RED}File required${NC}" && return
    aircrack-ng "$capfile"
}

run_wifite() {
    echo -e "${BLUE}▶ Wifite - automated WiFi auditor${NC}"
    sudo python3 "$BASE_DIR/wifite/wifite.py"
}

run_airgeddon() {
    echo -e "${BLUE}▶ Airgeddon - multi‑purpose wireless auditor${NC}"
    cd "$BASE_DIR/airgeddon" || return
    sudo bash airgeddon.sh
}

run_bettercap() {
    echo -e "${BLUE}▶ Bettercap - MITM framework${NC}"
    read -p "Interface (e.g., en0, wlan0): " iface
    sudo bettercap -iface "$iface"
}

run_reaver() {
    echo -e "${BLUE}▶ Reaver - WPS PIN brute‑forcer${NC}"
    read -p "Target BSSID (MAC): " bssid
    read -p "Interface (e.g., wlan0mon): " iface
    sudo reaver -i "$iface" -b "$bssid" -vv
}

run_pixiewps() {
    echo -e "${BLUE}▶ Pixiewps - WPS offline cracker${NC}"
    read -p "AuthKey (from reaver): " authkey
    read -p "E-Hash1: " ehash1
    read -p "E-Hash2: " ehash2
    read -p "PIN (optional): " pin
    pixiewps --authkey="$authkey" --e-hash1="$ehash1" --e-hash2="$ehash2" ${pin:+--pin=$pin}
}

run_hcxtools() {
    echo -e "${BLUE}▶ Hcxtools - capture WPA handshakes${NC}"
    read -p "Interface (monitor mode): " iface
    read -p "Output file prefix: " prefix
    sudo hcxdumptool -i "$iface" -o "$prefix.pcapng" --enable_status=1
}

run_metasploit() {
    echo -e "${BLUE}▶ Metasploit Framework${NC}"
    cd "$BASE_DIR/metasploit-framework" || return
    msfconsole
}

run_beef() {
    echo -e "${BLUE}▶ BeEF - Browser Exploitation Framework${NC}"
    cd "$BASE_DIR/beef" || return
    ./beef
}

run_setoolkit() {
    echo -e "${BLUE}▶ Social‑Engineer Toolkit${NC}"
    cd "$BASE_DIR/setoolkit" || return
    sudo python3 setoolkit
}

run_linux_exploit_suggester() {
    echo -e "${BLUE}▶ Linux Exploit Suggester${NC}"
    cd "$BASE_DIR/linux-exploit-suggester" || return
    bash les.sh
}

run_windows_exploit_suggester() {
    echo -e "${BLUE}▶ Windows Exploit Suggester${NC}"
    cd "$BASE_DIR/windows-exploit-suggester" || return
    python3 windows-exploit-suggester.py --update
    read -p "Systeminfo file: " sysinfo
    python3 windows-exploit-suggester.py --database "$(ls -t *.xls | head -1)" --systeminfo "$sysinfo"
}

run_shellnoob() {
    echo -e "${BLUE}▶ Shellnoob - shellcode helper${NC}"
    cd "$BASE_DIR/shellnoob" || return
    python3 shellnoob.py
}

run_nishang() {
    echo -e "${BLUE}▶ Nishang - PowerShell post‑ex${NC}"
    cd "$BASE_DIR/nishang" || return
    echo "Examples: Import-Module .\\nishang.ps1; Get-Information"
    echo "Open PowerShell as Administrator and run: Import-Module $BASE_DIR/nishang/nishang.ps1"
}

run_linenum() {
    echo -e "${BLUE}▶ LinEnum - Linux enumeration${NC}"
    cd "$BASE_DIR/linenum" || return
    bash LinEnum.sh
}

run_seatbelt() {
    echo -e "${BLUE}▶ Seatbelt - Windows system enumeration${NC}"
    cd "$BASE_DIR/seatbelt" || return
    if command -v mono &>/dev/null; then
        mono Seatbelt.exe
    else
        echo -e "${RED}Mono not installed. Run Seatbelt on Windows.${NC}"
    fi
}

run_sherlock() {
    echo -e "${BLUE}▶ Sherlock - Windows privesc${NC}"
    cd "$BASE_DIR/sherlock" || return
    echo "Run in PowerShell: Import-Module .\\Sherlock.ps1; Find-AllVulns"
}

run_binwalk() {
    echo -e "${BLUE}▶ Binwalk - firmware analysis${NC}"
    read -p "File to analyze: " file
    [[ -z "$file" || ! -f "$file" ]] && echo -e "${RED}Valid file required${NC}" && return
    binwalk "$file"
}

run_steghide() {
    echo -e "${BLUE}▶ Steghide - steganography${NC}"
    echo "1) Embed file into image"
    echo "2) Extract from image"
    read -p "Choose (1/2): " mode
    if [[ "$mode" == "1" ]]; then
        read -p "Cover image: " cover
        read -p "File to embed: " embed
        read -p "Passphrase: " pass
        steghide embed -cf "$cover" -ef "$embed" -p "$pass"
    else
        read -p "Image file: " img
        read -p "Passphrase: " pass
        steghide extract -sf "$img" -p "$pass"
    fi
}

run_foremost() {
    echo -e "${BLUE}▶ Foremost - file carving${NC}"
    read -p "File to carve from: " file
    [[ -z "$file" || ! -f "$file" ]] && echo -e "${RED}Valid file required${NC}" && return
    read -p "Output directory [./output]: " outdir
    outdir="${outdir:-./output}"
    foremost -i "$file" -o "$outdir"
}

run_exiftool() {
    echo -e "${BLUE}▶ ExifTool - metadata reader${NC}"
    read -p "File to examine: " file
    [[ -z "$file" || ! -f "$file" ]] && echo -e "${RED}Valid file required${NC}" && return
    exiftool "$file"
}

run_ettercap() {
    echo -e "${BLUE}▶ Ettercap - MITM tool${NC}"
    read -p "Interface: " iface
    read -p "Target IP (optional): " target
    sudo ettercap -T -i "$iface" ${target:+-M arp:remote /$target//}
}

run_responder() {
    echo -e "${BLUE}▶ Responder - LLMNR/NBT‑NS poisoner${NC}"
    read -p "Interface: " iface
    cd "$BASE_DIR/responder" || return
    sudo python3 Responder.py -I "$iface"
}

run_dsniff() {
    echo -e "${BLUE}▶ Dsniff - password sniffer${NC}"
    read -p "Interface: " iface
    sudo dsniff -i "$iface"
}

run_driftnet() {
    echo -e "${BLUE}▶ Driftnet - image sniffer${NC}"
    read -p "Interface: " iface
    sudo driftnet -i "$iface"
}

run_ngrep() {
    echo -e "${BLUE}▶ Ngrep - grep for packets${NC}"
    read -p "Interface: " iface
    read -p "Pattern: " pattern
    sudo ngrep -i -d "$iface" "$pattern"
}

run_macchanger() {
    echo -e "${BLUE}▶ Macchanger - MAC address spoofer${NC}"
    read -p "Interface: " iface
    sudo macchanger -r "$iface"
}

run_arping() {
    echo -e "${BLUE}▶ Arping - ARP pinger${NC}"
    read -p "Target IP: " target
    sudo arping "$target"
}

run_yersinia() {
    echo -e "${BLUE}▶ Yersinia - layer 2 attack framework${NC}"
    sudo yersinia -h
}

run_zphisher() {
    echo -e "${BLUE}▶ Zphisher - phishing tool${NC}"
    cd "$BASE_DIR/zphisher" || return
    bash zphisher.sh
}

run_camphish() {
    echo -e "${BLUE}▶ Camphish - camera phishing${NC}"
    cd "$BASE_DIR/camphish" || return
    bash camphish.sh
}

run_kingphisher() {
    echo -e "${BLUE}▶ King Phisher - email phishing${NC}"
    cd "$BASE_DIR/kingphisher" || return
    sudo python3 king-phisher
}

run_ghidra() {
    echo -e "${BLUE}▶ Ghidra - reverse engineering${NC}"
    cd "$BASE_DIR/ghidra" || return
    ./ghidraRun
}

run_radare2() {
    echo -e "${BLUE}▶ Radare2 - binary analysis${NC}"
    read -p "Binary file: " binary
    [[ -z "$binary" || ! -f "$binary" ]] && echo -e "${RED}File required${NC}" && return
    r2 "$binary"
}

run_cutter() {
    echo -e "${BLUE}▶ Cutter - Radare2 GUI${NC}"
    cd "$BASE_DIR/cutter" || return
    ./Cutter
}

run_pwndbg() {
    echo -e "${BLUE}▶ Pwndbg - GDB plugin${NC}"
    gdb
}

run_gef() {
    echo -e "${BLUE}▶ GEF - GDB Enhanced Features${NC}"
    gdb -q
}

run_qiling() {
    echo -e "${BLUE}▶ Qiling - binary emulation${NC}"
    read -p "Binary to emulate: " binary
    [[ -z "$binary" || ! -f "$binary" ]] && echo -e "${RED}File required${NC}" && return
    cd "$BASE_DIR/qiling" || return
    python3 -m qiling "$binary"
}

run_recon_ng() {
    echo -e "${BLUE}▶ Recon‑ng - OSINT framework${NC}"
    cd "$BASE_DIR/recon-ng" || return
    ./recon-ng
}

run_spiderfoot() {
    echo -e "${BLUE}▶ SpiderFoot - OSINT scanner${NC}"
    cd "$BASE_DIR/spiderfoot" || return
    python3 sf.py -l 127.0.0.1:5001
}

run_sherlock_osint() {
    echo -e "${BLUE}▶ Sherlock - username search${NC}"
    read -p "Username: " username
    [[ -z "$username" ]] && echo -e "${RED}Username required${NC}" && return
    cd "$BASE_DIR/sherlock" || return
    python3 sherlock "$username"
}

run_photon() {
    echo -e "${BLUE}▶ Photon - crawler/OSINT${NC}"
    read -p "URL: " url
    [[ -z "$url" ]] && echo -e "${RED}URL required${NC}" && return
    cd "$BASE_DIR/photon" || return
    python3 photon.py -u "$url"
}

run_holehe() {
    echo -e "${BLUE}▶ Holehe - email OSINT${NC}"
    read -p "Email: " email
    [[ -z "$email" ]] && echo -e "${RED}Email required${NC}" && return
    cd "$BASE_DIR/holehe" || return
    python3 holehe "$email"
}

run_maigret() {
    echo -e "${BLUE}▶ Maigret - username search${NC}"
    read -p "Username: " username
    [[ -z "$username" ]] && echo -e "${RED}Username required${NC}" && return
    cd "$BASE_DIR/maigret" || return
    python3 -m maigret "$username"
}

run_socat() {
    echo -e "${BLUE}▶ Socat - multipurpose relay${NC}"
    echo "Example: socat TCP-LISTEN:8080,fork TCP:192.168.1.100:80"
    read -p "Enter socat command: " cmd
    eval "$cmd"
}

run_nethogs() {
    echo -e "${BLUE}▶ Nethogs - per‑process network monitor${NC}"
    sudo nethogs
}

run_bmon() {
    echo -e "${BLUE}▶ Bmon - bandwidth monitor${NC}"
    bmon
}

run_vnstat() {
    echo -e "${BLUE}▶ VnStat - network traffic monitor${NC}"
    vnstat
}

run_mtr() {
    echo -e "${BLUE}▶ MTR - network diagnostic${NC}"
    read -p "Target: " target
    [[ -z "$target" ]] && echo -e "${RED}Target required${NC}" && return
    mtr "$target"
}

run_traceroute() {
    echo -e "${BLUE}▶ Traceroute - path discovery${NC}"
    read -p "Target: " target
    [[ -z "$target" ]] && echo -e "${RED}Target required${NC}" && return
    traceroute "$target"
}

run_iperf() {
    echo -e "${BLUE}▶ iPerf3 - network throughput${NC}"
    read -p "Mode (client/server): " mode
    if [[ "$mode" == "server" ]]; then
        iperf3 -s
    else
        read -p "Server IP: " server
        iperf3 -c "$server"
    fi
}

run_proxychains() {
    echo -e "${BLUE}▶ ProxyChains - routing through proxies${NC}"
    read -p "Command to run: " cmd
    proxychains4 $cmd
}

run_covenant() {
    echo -e "${BLUE}▶ Covenant - .NET C2${NC}"
    cd "$BASE_DIR/covenant" || return
    if command -v dotnet &>/dev/null; then
        dotnet run
    else
        echo -e "${RED}.NET SDK not found. Covenant requires .NET.${NC}"
    fi
}

run_starkiller() {
    echo -e "${BLUE}▶ Starkiller - Empire GUI${NC}"
    cd "$BASE_DIR/starkiller" || return
    if command -v npm &>/dev/null; then
        npm start
    else
        echo -e "${RED}npm not found. Install Node.js.${NC}"
    fi
}

run_poshc2() {
    echo -e "${BLUE}▶ PoshC2 - PowerShell C2${NC}"
    cd "$BASE_DIR/poshc2" || return
    if [[ -f "poshc2" ]]; then
        sudo ./poshc2
    else
        echo -e "${RED}PoshC2 not properly installed. Check $BASE_DIR/poshc2${NC}"
    fi
}

run_pupy() {
    echo -e "${BLUE}▶ Pupy - cross‑platform RAT${NC}"
    cd "$BASE_DIR/pupy" || return
    if [[ -f "pupy.py" ]]; then
        python3 pupy.py
    else
        echo -e "${RED}pupy.py not found. Check $BASE_DIR/pupy${NC}"
    fi
}

run_bbqsql() {
    echo -e "${BLUE}▶ BBQSQL - blind SQL injection${NC}"
    cd "$BASE_DIR/bbqsql" || return
    if [[ -f "bbqsql.py" ]]; then
        python3 bbqsql.py
    else
        echo -e "${RED}bbqsql.py not found.${NC}"
    fi
}

run_blisqy() {
    echo -e "${BLUE}▶ Blisqy - blind SQL injection${NC}"
    cd "$BASE_DIR/blisqy" || return
    if [[ -f "blisqy.py" ]]; then
        python3 blisqy.py
    else
        echo -e "${RED}blisqy.py not found.${NC}"
    fi
}

run_nosqlmap() {
    echo -e "${BLUE}▶ NoSQLMap - NoSQL injection${NC}"
    cd "$BASE_DIR/nosqlmap" || return
    if [[ -f "nosqlmap.py" ]]; then
        if python3 nosqlmap.py --help &>/dev/null; then
            python3 nosqlmap.py
        elif command -v python2 &>/dev/null; then
            python2 nosqlmap.py
        else
            echo -e "${RED}NoSQLMap requires Python 2 or 3.${NC}"
        fi
    else
        echo -e "${RED}nosqlmap.py not found.${NC}"
    fi
}

run_bloodhound() {
    echo -e "${BLUE}▶ BloodHound - AD attack graph${NC}"
    cd "$BASE_DIR/bloodhound" || return
    ./BloodHound
}

# ------------------------------------------------------------
# DISPATCH (maps tool name to function)
# ------------------------------------------------------------
run_tool() {
    local name="${tool_name[$1]}"
    case "$name" in
        neteen) run_neteen ;;
        nmap) run_nmap ;;
        masscan) run_masscan ;;
        rustscan) run_rustscan ;;
        gobuster) run_gobuster ;;
        ffuf) run_ffuf ;;
        dnsrecon) run_dnsrecon ;;
        nikto) run_nikto ;;
        linpeas) run_linpeas ;;
        searchsploit) run_searchsploit ;;
        wpscan) run_wpscan ;;
        droopescan) run_droopescan ;;
        joomscan) run_joomscan ;;
        cmsmap) run_cmsmap ;;
        sqlmap) run_sqlmap ;;
        xsstrike) run_xsstrike ;;
        dalfox) run_dalfox ;;
        commix) run_commix ;;
        arjun) run_arjun ;;
        john) run_john ;;
        hashcat) run_hashcat ;;
        hydra) run_hydra ;;
        cewl) run_cewl ;;
        crunch) run_crunch ;;
        ncrack) run_ncrack ;;
        crowbar) run_crowbar ;;
        patator) run_patator ;;
        aircrack-ng) run_aircrack ;;
        wifite) run_wifite ;;
        airgeddon) run_airgeddon ;;
        bettercap) run_bettercap ;;
        reaver) run_reaver ;;
        pixiewps) run_pixiewps ;;
        hcxtools) run_hcxtools ;;
        metasploit-framework) run_metasploit ;;
        beef) run_beef ;;
        setoolkit) run_setoolkit ;;
        linux-exploit-suggester) run_linux_exploit_suggester ;;
        windows-exploit-suggester) run_windows_exploit_suggester ;;
        shellnoob) run_shellnoob ;;
        nishang) run_nishang ;;
        linenum) run_linenum ;;
        seatbelt) run_seatbelt ;;
        sherlock) run_sherlock ;;
        binwalk) run_binwalk ;;
        steghide) run_steghide ;;
        foremost) run_foremost ;;
        exiftool) run_exiftool ;;
        ettercap) run_ettercap ;;
        responder) run_responder ;;
        dsniff) run_dsniff ;;
        driftnet) run_driftnet ;;
        ngrep) run_ngrep ;;
        macchanger) run_macchanger ;;
        arping) run_arping ;;
        yersinia) run_yersinia ;;
        zphisher) run_zphisher ;;
        camphish) run_camphish ;;
        kingphisher) run_kingphisher ;;
        ghidra) run_ghidra ;;
        radare2) run_radare2 ;;
        cutter) run_cutter ;;
        pwndbg) run_pwndbg ;;
        gef) run_gef ;;
        qiling) run_qiling ;;
        recon-ng) run_recon_ng ;;
        spiderfoot) run_spiderfoot ;;
        sherlock) run_sherlock_osint ;;
        photon) run_photon ;;
        holehe) run_holehe ;;
        maigret) run_maigret ;;
        socat) run_socat ;;
        nethogs) run_nethogs ;;
        bmon) run_bmon ;;
        vnstat) run_vnstat ;;
        mtr) run_mtr ;;
        traceroute) run_traceroute ;;
        iperf) run_iperf ;;
        proxychains-ng) run_proxychains ;;
        covenant) run_covenant ;;
        starkiller) run_starkiller ;;
        poshc2) run_poshc2 ;;
        pupy) run_pupy ;;
        bbqsql) run_bbqsql ;;
        blisqy) run_blisqy ;;
        nosqlmap) run_nosqlmap ;;
        bloodhound) run_bloodhound ;;
        *) echo -e "${RED}No runner for $name${NC}" ;;
    esac
    echo -e "${GREEN}Returning to menu...${NC}"
    read -p "Press Enter"
}

# ------------------------------------------------------------
# INSTALL TOOL (handles pkg / go / rust / git)
# ------------------------------------------------------------
install_tool() {
    local idx="$1"
    local type="${tool_type[$idx]}"
    local name="${tool_name[$idx]}"
    local source="${tool_source[$idx]}"
    local install_cmd="${tool_install[$idx]}"

    echo -e "${ORANGE}[+] Installing $name...${NC}"
    case "$type" in
        pkg)
            if command -v "$name" >/dev/null; then
                echo -e "${GREEN}✓ $name already installed${NC}"
            else
                eval "$PKG_INSTALL $source" >/dev/null 2>&1 && echo -e "${GREEN}✓ $name installed${NC}" || echo -e "${RED}✗ Failed${NC}"
            fi
            ;;
        go)
            if command -v "$name" >/dev/null; then
                echo -e "${GREEN}✓ $name already installed${NC}"
            elif command -v go >/dev/null; then
                eval "$install_cmd" >/dev/null 2>&1 && hash -r
                command -v "$name" >/dev/null && echo -e "${GREEN}✓ $name installed via go${NC}" || echo -e "${RED}✗ Failed${NC}"
            else
                echo -e "${RED}✗ Go missing${NC}"
            fi
            ;;
        rust)
            if command -v "$name" >/dev/null; then
                echo -e "${GREEN}✓ $name already installed${NC}"
            elif command -v cargo >/dev/null; then
                eval "$install_cmd" >/dev/null 2>&1 && hash -r
                command -v "$name" >/dev/null && echo -e "${GREEN}✓ $name installed via cargo${NC}" || echo -e "${RED}✗ Failed${NC}"
            else
                echo -e "${RED}✗ Rust missing${NC}"
            fi
            ;;
        git)
            local dest="$BASE_DIR/$name"
            if [ -d "$dest/.git" ]; then
                echo -e "${GREEN}✓ $name already cloned${NC}"
            else
                git clone "$source" "$dest" >/dev/null 2>&1
                if [ -d "$dest/.git" ]; then
                    [[ -n "$install_cmd" && "$install_cmd" != " " && "$install_cmd" != "echo" ]] && (cd "$dest" && eval "$install_cmd" >/dev/null 2>&1)
                    echo -e "${GREEN}✓ $name ready${NC}"
                else
                    echo -e "${RED}✗ Clone failed${NC}"
                fi
            fi
            ;;
    esac
}

# ------------------------------------------------------------
# NETEEN (your own tool) – installation and runner
# ------------------------------------------------------------
install_neteen() {
    echo -e "${ORANGE}[+] Installing NETEEN...${NC}"
    local dest="$BASE_DIR/NETEEN"
    if [ -d "$dest/.git" ]; then
        echo -e "${GREEN}✓ NETEEN already installed${NC}"
    else
        git clone "https://github.com/apspydon/NETEEN.git" "$dest" >/dev/null 2>&1
        (cd "$dest" && chmod +x NETEEN.sh 2>/dev/null)
        echo -e "${GREEN}✓ NETEEN installed at $dest/NETEEN.sh${NC}"
    fi
}

# ------------------------------------------------------------
# CATEGORY MENU
# ------------------------------------------------------------
show_category() {
    local cat_id="$1"
    local cat_name="$2"
    local indices=()
    for i in "${!tool_cat[@]}"; do
        [[ "${tool_cat[$i]}" == "$cat_id" ]] && indices+=("$i")
    done
    [[ ${#indices[@]} -eq 0 ]] && { echo -e "${RED}No tools.${NC}"; read -p "Press Enter..."; return; }

    while true; do
        show_banner
        echo -e "${WHITE}╔════════════════════════════════════════════╗${NC}"
        echo -e "${WHITE}║${BLUE}               $cat_name${WHITE}║${NC}"
        echo -e "${WHITE}╠════════════════════════════════════════════╣${NC}"
        local i=1
        for idx in "${indices[@]}"; do
            printf "${WHITE}║${GREEN}%2d${NC}) %-36s ${WHITE}║${NC}\n" "$i" "${tool_name[$idx]}"
            ((i++))
        done
        echo -e "${WHITE}╠════════════════════════════════════════════╣${NC}"
        printf "${WHITE}║${ORANGE}  A${NC}) Install ALL tools in this category${WHITE}        ║${NC}\n"
        printf "${WHITE}║${RED}  B${NC}) Back to main menu${WHITE}                               ║${NC}\n"
        echo -e "${WHITE}╚════════════════════════════════════════════╝${NC}"
        read -p "$(echo -e ${GREEN}"Select [1-${#indices[@]}/A/B]: "${NC})" choice

        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le ${#indices[@]} ]; then
            local idx="${indices[$((choice-1))]}"
            install_tool "$idx"
            read -p "$(echo -e ${ORANGE}"Run this tool now? (y/n): "${NC})" runnow
            if [[ "$runnow" =~ ^[Yy]$ ]]; then
                run_tool "$idx"
            fi
        elif [[ "$choice" =~ ^[Aa]$ ]]; then
            echo -e "${ORANGE}Installing all tools in $cat_name...${NC}"
            for idx in "${indices[@]}"; do
                install_tool "$idx"
            done
            echo -e "${GREEN}✓ All tools installed!${NC}"
            read -p "Press Enter"
        elif [[ "$choice" =~ ^[Bb]$ ]]; then
            break
        else
            echo -e "${RED}Invalid choice${NC}"; sleep 1
        fi
    done
}

# ------------------------------------------------------------
# INSTALL ALL TOOLS (global)
# ------------------------------------------------------------
install_all_tools() {
    echo -e "${ORANGE}Installing all tools from all categories...${NC}"
    for i in "${!tool_cat[@]}"; do
        install_tool "$i"
    done
    echo -e "${GREEN}All tools processed!${NC}"
    read -p "Press Enter"
}

# ------------------------------------------------------------
# OPEN GITHUB IN BROWSER
# ------------------------------------------------------------
open_github() {
    local url="https://github.com/apspydon"
    echo -e "${BLUE}Opening $url...${NC}"
    if [[ "$OS" == "macos" ]]; then
        open "$url"
    elif [[ "$OS" == "linux" ]]; then
        command -v xdg-open &>/dev/null && xdg-open "$url" || echo -e "${ORANGE}Please visit: $url${NC}"
    elif [[ "$OS" == "termux" ]]; then
        termux-open-url "$url" 2>/dev/null || echo -e "${ORANGE}Please visit: $url${NC}"
    else
        echo -e "${ORANGE}Please visit: $url${NC}"
    fi
    sleep 2
}

# ------------------------------------------------------------
# MAIN MENU
# ------------------------------------------------------------
main_menu() {
    while true; do
        show_banner
        echo -e "${WHITE}╔════════════════════════════════════════════╗${NC}"
        echo -e "${WHITE}║${BLUE}                 MAIN MENU                       ${WHITE}║${NC}"
        echo -e "${WHITE}╠════════════════════════════════════════════╣${NC}"
        printf "${WHITE}║${GREEN} 1${NC}) NETEEN (my personal tool)${WHITE}                          ║${NC}\n"
        printf "${WHITE}║${GREEN} 2${NC}) Information Gathering${WHITE}                         ║${NC}\n"
        printf "${WHITE}║${GREEN} 3${NC}) Vulnerability Analysis${WHITE}                        ║${NC}\n"
        printf "${WHITE}║${GREEN} 4${NC}) Web Application Hacking${WHITE}                       ║${NC}\n"
        printf "${WHITE}║${GREEN} 5${NC}) Password Attacks${WHITE}                              ║${NC}\n"
        printf "${WHITE}║${GREEN} 6${NC}) Wireless Attacks${WHITE}                              ║${NC}\n"
        printf "${WHITE}║${GREEN} 7${NC}) Exploitation Frameworks${WHITE}                       ║${NC}\n"
        printf "${WHITE}║${GREEN} 8${NC}) Post Exploitation${WHITE}                             ║${NC}\n"
        printf "${WHITE}║${GREEN} 9${NC}) Forensics${WHITE}                                     ║${NC}\n"
        printf "${WHITE}║${GREEN}10${NC}) Sniffing & Spoofing${WHITE}                           ║${NC}\n"
        printf "${WHITE}║${GREEN}11${NC}) Social Engineering${WHITE}                            ║${NC}\n"
        printf "${WHITE}║${GREEN}12${NC}) Reverse Engineering${WHITE}                           ║${NC}\n"
        printf "${WHITE}║${GREEN}13${NC}) OSINT${WHITE}                                         ║${NC}\n"
        printf "${WHITE}║${GREEN}14${NC}) Network Utilities${WHITE}                             ║${NC}\n"
        printf "${WHITE}║${GREEN}15${NC}) Red Teaming & C2${WHITE}                              ║${NC}\n"
        printf "${WHITE}║${GREEN}16${NC}) Database Hacking${WHITE}                              ║${NC}\n"
        printf "${WHITE}║${GREEN}17${NC}) All‑in‑One Swiss Army${WHITE}                         ║${NC}\n"
        printf "${WHITE}║${GREEN}18${NC}) Install ALL tools${WHITE}                             ║${NC}\n"
        printf "${WHITE}║${GREEN}19${NC}) Visit my GitHub${WHITE}                               ║${NC}\n"
        printf "${WHITE}║${RED} 0${NC}) Exit${WHITE}                                            ║${NC}\n"
        echo -e "${WHITE}╚════════════════════════════════════════════╝${NC}"
        read -p "$(echo -e ${GREEN}"Choose option: "${NC})" choice

        case $choice in
            1) install_neteen && run_neteen ;;
            2) show_category "1" "Information Gathering" ;;
            3) show_category "2" "Vulnerability Analysis" ;;
            4) show_category "3" "Web Application Hacking" ;;
            5) show_category "4" "Password Attacks" ;;
            6) show_category "5" "Wireless Attacks" ;;
            7) show_category "6" "Exploitation Frameworks" ;;
            8) show_category "7" "Post Exploitation" ;;
            9) show_category "8" "Forensics" ;;
            10) show_category "9" "Sniffing & Spoofing" ;;
            11) show_category "10" "Social Engineering" ;;
            12) show_category "11" "Reverse Engineering" ;;
            13) show_category "12" "OSINT" ;;
            14) show_category "13" "Network Utilities" ;;
            15) show_category "14" "Red Teaming & C2" ;;
            16) show_category "15" "Database Hacking" ;;
            17) show_category "16" "All‑in‑One Swiss Army" ;;
            18) install_all_tools ;;
            19) open_github ;;
            0|q|Q) echo -e "${GREEN}goodbye.${NC}"; exit 0 ;;
            *) echo -e "${RED}Invalid option${NC}"; sleep 1 ;;
        esac
    done
}

# ------------------------------------------------------------
# START
# ------------------------------------------------------------
root_check() {
    if [[ "$OS" != "termux" && $EUID -ne 0 ]]; then
        echo -e "${RED}Please run with sudo.${NC}"
        exit 1
    fi
}

setup_pkg_manager
read_tools_db
install_prerequisites
root_check
main_menu
