#!/usr/bin/env bash

sourceYaml=$1
outputYaml=$2

validate_no_cipher_suites() {
  local ymlPath=$1

  local declaredCipherSuites=`yq r $ymlPath processes[0].args | grep tls-cipher-suites`
  if [[ -n $declaredCipherSuites ]]
  then
    printf "I'm so disappointed: ($declaredCipherSuites)\n"
    exit -1 # TODO: how should we register an error?
  #else
    #printf "I guess you pass this time ($declaredCipherSuites) -- wait, what's your favourite color?\n"
  fi
}
validate_no_cipher_suites $1

merge_cipher_suites() {
  local ymlSource=$1
  local ymlOutput=$2
  local ciphersFile=$3

  local ciphers=`cat $ciphersFile`
  yq w $ymlSource "processes[0].args[+]" -- "--tls-cipher-suites=$ciphers" > $ymlOutput
}
# TODO: consider where to find ciphers.txt
merge_cipher_suites sourceYaml outputYaml 'ciphers.txt'

