const fs = require('fs').promises;
const { init, fetchQuery } = require("@airstack/node");
require('dotenv').config();

// Initialize Airstack with your API key from the .env file
init(process.env.AIRSTACK_API_KEY);

const query = `query MyQuery($userId: String!, $dappName: SocialDappName!, $blockchain: Blockchain!) {
  Socials(
    input: {filter: {userId: {_eq: $userId}, dappName: {_eq: $dappName}}, blockchain: $blockchain}
  ) {
    Social {
      dappName
      userAddress
    }
  }
}`;

// Get the Warpcast URL from command-line arguments
const warpcastUrl = process.argv[2];

async function fetchAddresses() {
    const fids = await fs.readFile("./fids.txt", "utf8");
    const fidList = fids.split('\n').filter(Boolean);
    const outputCSV = "./addresses.csv";
    const currentDate = new Date().toISOString();

    // Check if output CSV file exists, if not, add header
    try {
        await fs.access(outputCSV);
    } catch (e) {
        await fs.writeFile(outputCSV, "Warpcast URL,FID,User Address,Timestamp\n");
    }

    for (const fid of fidList) {
        const variables = {
            userId: fid,
            dappName: "farcaster", // Adjust according to your GraphQL schema
            blockchain: "ethereum"
        };

        const { data, error } = await fetchQuery(query, variables);

        if (error) {
            console.error("Error fetching data for FID:", fid, error);
            continue;
        }

        if (data && data.Socials && data.Socials.Social.length > 0) {
            const address = data.Socials.Social[0].userAddress;
            // Include Warpcast URL, FID, address, and timestamp in the CSV line
            const line = `${warpcastUrl},${fid},${address},${currentDate}\n`;
            await fs.appendFile(outputCSV, line);
        }
    }

    console.log("Addresses, timestamps, and Warpcast URLs have been written to addresses.csv");
}

fetchAddresses().catch(console.error);
