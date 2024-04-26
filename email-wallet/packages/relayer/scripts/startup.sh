#!/bin/bash


/email-wallet/target/release/relayer setup

if [ $? -ne 0 ]; then
    echo "Error: Failed to run /email-wallet/target/release/relayer setup"
    exit 1
fi

/email-wallet/target/release/relayer >> output.log

if [ $? -ne 0 ]; then
    cat output.log
    echo "Error: Failed to run /email-wallet/target/release/relayer >> output.log"
    exit 1
fi
