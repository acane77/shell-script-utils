#!/bin/bash

function _get_md5() {
    str=$1

    r=$(echo "$str"|md5sum)
    echo "$r"|cut -f 1 -d ' '
}

function _get_dyn_name() {
    var_name=$1
    echo "${!var_name}"
}

function _map_set() {
    map_name=$(_get_md5 "$1")
    key=$(_get_md5 "$2")
    value=$3    

    # initialize map if uninitialized
    inited="$(_get_dyn_name __map_$map_name)"
    if [ "$inited" != "inited" ]; then
        #echo " --> init map: __map_$map_name"
        printf -v __map_$map_name "inited"
        printf -v __map_$map_name"_keys" ""
    fi

    keys=$(_get_dyn_name __map_$map_name"_keys")
    keys="$2\n$keys"
    printf -v __map_$map_name"_keys" "$keys"
    #echo " --> size=$(_get_dyn_name __map_$map_name"_keys")"

    printf -v __map_$map_name"_"$key "$value"
}

function _map_get() {
    map_name=$(_get_md5 "$1")
    key=$(_get_md5 "$2")
    __var="__map_"$map_name"_"$key
    value="${!__var}"
    if [ "$value" == "__removed__""$map_name"_"$key"__ ]; then
        echo ""
    else
        echo "$value"
    fi
}

function _map_keys() {
    map_name=$(_get_md5 "$1")
    _get_dyn_name __map_$map_name"_keys"
}

function _map_exists() {
    _map_keys "$1"|grep -oEi '^'"$2"'$' >/dev/null
    ret=$?
    return $ret
}

function _map_erase() {
    map_name=$(_get_md5 "$1")
    key=$(_get_md5 "$2")
    key_="$2"
    _map_exists $1 $2
    if [ $? -ne 0 ]; then
        echo "error: key does not exist in map[$1]: $2"
        return 1
    fi
    keys=$(_map_keys "$1"|grep -voEi '^'"$2"'$')
    printf -v __map_$map_name"_keys" "$keys"
    _map_set "$1" "$2" "__removed__""$map_name"_"$key"__
}

function map() {
    in="$*"
    #echo " --> $in"
    accessor=$(echo "$in"|awk -F '=' '{ print $1 }')
    echo "$accessor"|grep -oEi '^(\d|\w)+\[.*<?\]$' 1>/dev/null 2>&1
    # test if is map_name[key] form
    if [ $? -ne 0 ]; then
        # test if id map_name.prop form
        echo "$1"|grep -oEi '^(\d|\w)+\..*<?\$' 1>/dev/null 2>&1
        if [ $? -ne 0 ]; then
            map_name=$(echo "$1"|cut -f 1 -d '.')
            prop=$(echo "$1"|cut -f 2 -d '.')
            if [ "$prop" == "size" ]; then
                _map_keys "$map_name"|wc -l|tr -d ' '
                return 0
            elif [ "$prop" == "keys" ]; then
                _map_keys "$map_name"
                return 0
            elif [ "$prop" == "exists" ]; then
                if [ "$2" == "" ]; then
                    echo "usage: $0 $1 [key]"
                    return 101
                fi
                _map_exists $map_name $2
                return 0
            elif [ "$prop" == "erase" ]; then
                if [ "$2" == "" ]; then
                    echo "usage: $0 $1 [key]"
                    return 101
                fi
                _map_erase $map_name $2
                return 0
            else

                echo "error: no such prop in map: $in"
                return 2
            fi
        fi
        echo "error: invalid accessor: $in"
        return 1
    fi
    map_name=$(echo "$accessor"|cut -f 1 -d '[')
    key=$(echo "$accessor"|cut -f 2 -d '['|tr -d ']')
    len_accessor=${#accessor}
    len_accessor=$(( len_accessor + 1 ))
    if [[ "$in" == *"="* ]]; then
        value=${in:len_accessor}
        _map_set "$map_name" "$key" "$value"
    else
        _map_get "$map_name" "$key"
    fi
}
