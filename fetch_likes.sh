#!/bin/bash
# ASCII Art Title
cat << "EOF"
_ _ _ ____ ____ ___  ____ ____ ____ ___    _    _ _  _ ____ ____
| | | |__| |__/ |__] |    |__| [__   |     |    | |_/  |___ [__
|_|_| |  | |  \ |    |___ |  | ___]  |     |___ | | \_ |___ ___]
Made with 🔵 by 0xHashbrown
EOF
# Check for .env file and load API keys, or prompt for them if not found
ENV_FILE="./.env"

if [ -f "$ENV_FILE" ]; then
    source $ENV_FILE
else
    echo "Enter your Neynar API key:"
    read NEYNAR_API_KEY
    echo "Enter your Airstack API key:"
    read AIRSTACK_API_KEY
    echo "NEYNAR_API_KEY='$NEYNAR_API_KEY'" > $ENV_FILE
    echo "AIRSTACK_API_KEY='$AIRSTACK_API_KEY'" >> $ENV_FILE
fi



echo -e "\nPlease enter the Warpcast URL: 🔗"
read WARPCAST_URL

# Encode the URL for use in the API call
ENCODED_URL=$(echo -n $WARPCAST_URL | jq -sRr @uri)

# API details
API_ENDPOINT="https://api.neynar.com/v2/farcaster/cast?identifier=$ENCODED_URL&type=url"

# FIDs File Path
FIDS_FILE="./fids.txt"

# Make API Call and extract FIDs of likes
curl --silent --request GET \
     --url "${API_ENDPOINT}" \
     --header "accept: application/json" \
     --header "api_key: $NEYNAR_API_KEY" | jq -r '.cast.reactions.likes[]?.fid' > $FIDS_FILE

# Confirmation Message and running Node.js script with Warpcast URL as argument
if [ -s $FIDS_FILE ]; then
    echo "FIDs have been extracted successfully and saved to $FIDS_FILE."
    # Pass the Warpcast URL to the Node.js script as an argument
    node processFIDs.js "$WARPCAST_URL"
else
    echo "No FIDs found or an error occurred."
fi
