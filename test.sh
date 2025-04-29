#!/bin/bash

select image in $(cat files/system/etc/containerconf/.cherry/list.txt); do
    if [[ -n $image ]]; then
        echo $image
        echo "Done! You can switch to the container using 'cherry branch jump'."
        exit 0
    else
        echo "Invalid selection."
        exit 1
    fi
done