# Remote Access

To access the DAQ server remotely we will be using SSH and UCR's VPN. If you
need to use the user with root permission on the server, please ask the DAQ
lead for permissions. All programs that you need are already installed, so to
prevent human errors occurring on the server because of typos or other
misinputs, we have decided to limit the people getting root access on the
server.

## Connect to VPN

<div class="warning">
  Please create an UCR engineer account first.

  [Follow this guide](https://docs.google.com/document/d/1oX0ZYzlXolmpZ0fJNAy_cVPW6i22R3PRp1TenrxjHMw/edit?usp=sharing).
</div>

You can follow the [UCR's VPN
guide](https://library.ucr.edu/using-the-library/technology-equipment/connect-from-off-campus)
to connect to the BCOE network--which is where our server's LAN is located. If
you don't want to read the UCR guide, we have created a TLDR below that you can
follow. If you are a Linux user or you want an open-source-only option, we have
provided a guide for that below as well.

<details>
  <summary>TLDR</summary>

  1. Make sure:
      * you can login into UCR's CISCO Anyconnect VPN using [vpn.ucr.edu](https://vpn.ucr.edu) (username and password should be the same as how you log into R'web)
      * you have an [engineer account](https://docs.google.com/document/d/1oX0ZYzlXolmpZ0fJNAy_cVPW6i22R3PRp1TenrxjHMw/edit?usp=sharing).
  2. Log into [vpn.ucr.edu](https://vpn.ucr.edu), and click on continue.
  3. You will see instructions telling you how to install CISCO Anyconnect VPN client.
  4. Download the client and install it.
  5. Open the client and enter `vpn.ucr.edu` as the VPN endpoint where the client will connect to.
  6. Click "Connect" and you should be connected to the UCR VPN after a few seconds.
</details>

<details>
  <summary>Open source option</summary>

  1. First, you need to download the command [`openconnect`](https://www.infradead.org/openconnect/).
      * Arch Linux: `sudo pacman -S openconnect`
  2. Make sure:
      * `curl` is avaliable in your `PATH` environment variable.
      * you can login into UCR's CISCO Anyconnect VPN using [vpn.ucr.edu](https://vpn.ucr.edu) (username and password should be the same as how you log into R'web) 
      * you have an [engineer account](https://docs.google.com/document/d/1oX0ZYzlXolmpZ0fJNAy_cVPW6i22R3PRp1TenrxjHMw/edit?usp=sharing).
  3. Download [`vpn.sh`](./vpn.sh) and fill out your `USERNAME` and `PASSWORD` inside of the file on line 3 and 4.
  4. `cd` into where `vpn.sh` is located and make it executable `chmod +x vpn.sh`.
  5. Run `vpn.sh` with `./vpn.sh`
  6. This script will ask for you to approve the login attempt on DUO application everytime you run it.

  This is the content of [`vpn.sh`](./vpn.sh):

  ```sh
  #!/bin/env sh

  USERNAME=""
  PASSWORD=""
  DOMAIN="https://vpn.ucr.edu"

  #echo -n "Enter DUO Passcode: "
  #read DUO_PASSCODE
  DUO_PASSCODE="1"

  echo Getting the \`tg\` cookie
  VAR_tg=$(curl -s -v "${DOMAIN}/+CSCOE+/logon.html?tgroup=FTD_VPN" 2>&1 | grep -i "Set-Cookie:" | grep -oP '(?<=tg=)[^;]+')

  echo Getting CSRFtoken cookie
  CSRF_TOKEN=$(curl -s "${DOMAIN}/+CSCOE+/logon.html" | grep CSRFtoken | awk -F'"' '{print $4}')

  # Random stuff that are required
  curl -s "${DOMAIN}/+CSCOE+/logon.html" \
    -H "Cookie: tg=${VAR_tg}" \
    -H "Referer: ${DOMAIN}/" > /dev/null

  curl -s "${DOMAIN}/+CSCOE+/blank.html" \
    -H "Cookie: tg=${VAR_tg}; webvpnlogin=1; webvpnLang=en; CSRFtoken=${CSRF_TOKEN}" \
    -H "Referer: ${DOMAIN}/+CSCOE+/logon.html" > /dev/null

  echo Login using username and password
  LOGIN_PAGE=$(curl -X POST -s "${DOMAIN}/+webvpn+/index.html" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Cookie: tg=${VAR_tg}; webvpnlogin=1; webvpnLang=en; CSRFtoken=${CSRF_TOKEN}" \
    -H "Referer: ${DOMAIN}/+CSCOE+/logon.html" \
    --data "tgroup=" \
    --data "next=" \
    --data "tgcookieset=" \
    --data "csrf_token=${CSRF_TOKEN}" \
    --data "username=${USERNAME}" \
    --data "password=${PASSWORD}" \
    --data "Login=Logon")

  AUTH_HANDLE=$(echo $LOGIN_PAGE | sed -n 's/.*&auth_handle=\([^"]*\)".*/\1/p')
  VAR_a1=$(echo $LOGIN_PAGE | sed -n 's/.*&a1=\([^"]*\)".*/\1/p')

  # DUO challenge
  HOME_PAGE=$(curl -X POST -v -s "${DOMAIN}/+webvpn+/login/challenge.html" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -H "Referer: ${DOMAIN}/+CSCOE+/logon.html?reason=7&a0=2&a1=${VAR_a1}&a2=&a3=0&next=&auth_handle=${AUTH_HANDLE}&status=2&username=${UESRNAME}&serverType=0&challenge_code=0" \
    -H "Cookie: tg=${VAR_tg}; webvpnlogin=1; webvpnLang=en; CSRFtoken=${CSRF_TOKEN}" \
    -v \
    --data "next=" \
    --data "auth_handle=${AUTH_HANDLE}" \
    --data "status=2" \
    --data "username=${USERNAME}" \
    --data "challenge_code=0" \
    --data "csrf_token=${CSRF_TOKEN}" \
    --data "password=${DUO_PASSCODE}" 2>&1)

  if [[ "$HOME_PAGE" != *"doStart"* ]]; then
    # failed to login
    echo failed to login
    exit 1
  fi

  WEBVPN_COOKIE=$(echo $HOME_PAGE | grep "Set-Cookie:" | sed -n 's/.*webvpn=\([^;]*\);.*/\1/p')

  echo Sucessfully logged in. Connecting to VPN...

  sudo openconnect --protocol=anyconnect -C "webvpn=${WEBVPN_COOKIE}" vpn.ucr.edu
  ```

  The reason why this script is needed is because `sudo openconnect
  --protocol=anyconnect vpn.ucr.edu` by itself is not currently compatible with
  `vpn.ucr.edu`. What this script does is it extra the login session cookie
  from `vpn.ucr.edu` and use it with `openconnect`.
</details>

## SSH Access

For regular members, you should be using the user without root access. We want
to reduce the amount of human errors that can happen on the machine. If you
really need root access, please ask the DAQ lead.

After you are connected to the BCOE network, you can access the server through SSH.

* Server IP: 169.235.18.162
* Username: highlander
* Password: hsp

`ssh highlander@169.235.18.162`
