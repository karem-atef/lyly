#!/bin/bash

# Installing All Tools Needed In LyLy Script


    # installing go 
GOlang() {
	
	LATEST=$(curl -s 'https://go.dev/VERSION?m=text')
	wget https://golang.org/dl/$LATEST.linux-amd64.tar.gz -O golang.tar.gz &>/dev/null 
	sudo tar -C /usr/local -xzf golang.tar.gz
	echo "export GOROOT=/usr/local/go" >> $HOME/.bashrc
	echo "export GOPATH=$HOME/go" >> $HOME/.bashrc
	echo 'export PATH=$PATH:$GOROOT/bin:$GOPATH/bin' >> $HOME/.bashrc
	source .bashrc
	
	printf "[+] Golang Installed !.\n"
}

Findomain(){
	git clone https://github.com/karem941/findomain.git
	cd findomain
	chmod +x findomain-linux.1
	sudo cp findomain-linux.1 /usr/bin/findomain
	cd ..
	printf "[+] findomain Installed !.\n"

}
Assetfinder(){
	go install  github.com/tomnomnom/assetfinder@latest
	printf "[+] assetfinder Installed !.\n"

}
Amass(){
	sudo snap install amass
	printf "[+] Amass Installed !.\n"
}
Httprobe(){
	go install github.com/tomnomnom/httprobe@latest
	printf "[+] httprobe Installed !.\n"
}
subfinder(){
	go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
	printf "[+] subfinder Installed !.\n"
}

SubEnum(){

	git clone https://github.com/bing0o/SubEnum.git
	cd SubEnum
 	chmod +x setup.sh
 	./setup.sh
	 cd ..
	 printf "[+] subenum Installed !.\n"
	 
}
waybackurls(){
	go install github.com/tomnomnom/waybackurls@latest
	printf "[+] waybackurls Installed !.\n"
}
Gau(){
	go install github.com/lc/gau/v2/cmd/gau@latest
	printf "[+] Gau Installed !.\n"
}
Anew(){
	go install -v github.com/tomnomnom/anew@latest
	printf "[+] Anew Installed !.\n"
}
unfurl(){
	go install github.com/tomnomnom/unfurl@latest
	printf "[+] unfurl Installed !.\n"

}
make(){
	sudo apt install make
	printf "[+] make Installed !.\n"
}
massdns(){
	git clone https://github.com/blechschmidt/massdns.git
	cd massdns/
	make
	sudo cp ./bin/massdns /usr/bin/massdns
	cd ..
	printf "[+] massdns Installed !.\n"
}
masscan(){

	sudo apt install masscan
	printf "[+] masscan Installed !.\n"
}
clean_ip(){
	wget https://gist.githubusercontent.com/LuD1161/bd4ac4377de548990b47b0af8d03dc78/raw/85b0ea69b321ad66d4b34faf2f9b880d25f2409f/clean_ips.py
	printf "[+] clean_ip Installed !.\n"
}

nmap-input-file(){
	wget https://raw.githubusercontent.com/LuD1161/HackingSimplified/master/Recon/nmap/nmap-input-file.py
	printf "[+] nmap-input-file Installed !.\n"

}
nmap.sh(){
	wget https://raw.githubusercontent.com/LuD1161/HackingSimplified/master/Recon/nmap/nmap.sh
	chmod +x nmap.sh
	printf "[+] nmap.sh Installed !.\n"
}
nmap(){
	sudo apt install nmap
	printf "[+] nmap Installed !.\n"
}
wafw00f(){
	sudo apt install wafw00f
	printf "[+] wafw00f Installed !.\n"
}
subjack(){
	go install github.com/haccer/subjack@latest
	printf "[+] subjack Installed !.\n"
}
FFF(){
	go install github.com/tomnomnom/fff@latest
	printf "[+] FFF Installed !.\n"
}
GF(){
	go install github.com/tomnomnom/gf@latest
	printf "[+] GF Installed !.\n"
}
Nuclei(){
	go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
	printf "[+] Nuclei Installed !.\n"

}
JSScan(){
	git clone https://github.com/0x240x23elu/JSScanner.git
	pip3 install -r  ./JSScanner/requirements.txt

}
corscaner(){
	 pip install corscanner
}
uro{
	pip3 install uro
}
qsreplace(){
	go install github.com/tomnomnom/qsreplace@latest
}
dalfox(){
	go install github.com/hahwul/dalfox/v2@latest
}
Smuggler(){
	git clone https://github.com/defparam/smuggler.git
}
Jira-Lens(){
	pip install Jira-Lens
}	

###################################################################################################################################################################

hash go 2>/dev/null && printf "[!] Golang is already installed.\n" || { printf "[+] Installing GOlang!" && GOlang; } 
