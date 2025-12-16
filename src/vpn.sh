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

