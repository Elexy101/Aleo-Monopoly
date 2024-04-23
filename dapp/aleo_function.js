 //connecting the wallet
 let finalValue;  // Declare finalValue outside fetchData function

 function aleo_connect1() {
    window.leoWallet.connect("ON_CHAIN_HISTORY", "testnet3", ["credits.aleo","aleo_monopoly_workshop12.aleo"]);
    window.leoWallet.requestRecordPlaintexts("aleo_monopoly_workshop12.aleo").then(res => console.log(res));

    //sign a message
    let utf8Encode = new TextEncoder();
    let bytes = utf8Encode.encode("Welcome to Aleo-Monopoly, roll dice by getting rent, mystery cards...");


    window.leoWallet.signMessage(bytes);

    var publicKey = window.leoWallet.publicKey; // Replace with the actual public key

    //reduce it
    var wallet_addr = publicKey;

    sub_str_wallet = publicKey.substr(0,5) + "..." + publicKey.substr(-3); 
    console.log('Signature: ', bytes);

    document.getElementById('aleo_wallet').innerHTML = sub_str_wallet;
    document.getElementById('aleo_wallet2').innerHTML = sub_str_wallet;
    var mint_amount = document.getElementById('result').textContent;


//============================ FETCH ACCOUNT BALANCE ========================================
const apiUrl = 'https://testnet3.aleoscan.io/testnet3/program/aleo_monopoly_workshop12.aleo/mapping/account/'+publicKey;
console.log(apiUrl);

//============================ FETCH NO. OF BUILDING OWNED BY PLAYER ==============================
const apiUrl_Building = 'https://testnet3.aleoscan.io/testnet3/program/aleo_monopoly_workshop12.aleo/mapping/account/'+publicKey;
console.log(apiUrl_Building);

async function fetchData() {
  try {
    // Make a fetch request to the API endpoint
    const response = await fetch(apiUrl);

    // Check if the request was successful (status code 200)
    if (!response.ok) {
      throw new Error('Network response was not ok');
    }

    const inputString = await response.text();

    
    // Remove the quotes
    const stringWithoutQuotes = inputString.replace(/"/g, '');

    // Remove the "u64" part
    const finalValue = stringWithoutQuotes.replace('u64', '');
    
    console.log(finalValue);  // This will log '5600'
    

    // Insert the value into your webpage (assuming you have an HTML element with id "result")
    document.getElementById("result").innerHTML = finalValue;

    document.getElementById("result2").innerHTML = finalValue;

  } catch (error) {
    console.error('Error fetching data:', error.message);
  }
}


if(!publicKey){
    document.getElementById('mint_token') = 'disabled';
}else if(mint_amount > 0) {
    document.getElementById("mint_token").innerHTML = "Minted!";
    //document.getElementById('mint_token') = 'disabled';
}else{
    //change the mint button to be active to mint token to wallet
    var btn_mint = document.getElementById("mint_token");
    btn_mint.disabled = false;
    
    //change it to mint me
    btn_mint.innerHTML = "Mint!";
}  

    // Call fetchData again after a delay (e.g., every 5 seconds)
    setTimeout(fetchData, 5000);
}



//===============================================================================
//========================== minting MONO token =================================
//===============================================================================

//check if token has been minted once already, and avoid minting twice
//if(token_minted()) {
  //  revoke();
// }else{ mint_token() }
// you need to fetch out the latest transaction from the `issue` function for a checkup to know if user minted already
// if minted, cannot be trigger again... -> (if(count(issue)) > 1){ mint }else{ do not mint again }


function mint_token() {
    //test check

  var publicKey = window.leoWallet.publicKey; // Replace with the actual public key
        console.log(publicKey);
        
            if (!publicKey) {
                throw new WalletNotConnectedError();
            }

            var inputs = [publicKey, '10000u64'];
            
            var aleoTransaction = Transaction.createTransaction(publicKey, 'testnet3', 'aleo_monopoly_workshop12.aleo', 'issue', inputs, 500_000,);
            
            if (aleoTransaction) {
                window.leoWallet.requestTransaction(aleoTransaction);
                console.log('Transaction requested successfully.');
            } else {
                console.error('request Transaction function not available.');
        }      
}




//=========================================================================================================
//================================= function to purchase a building... ====================================
//=========================================================================================================
function purchase() {
    //setting amt
    var amount = document.getElementById('result').textContent; //we could fetch the balance from the past record and get the u64 amount
    var building = 1; //call from the past record to get the u64 building

  var publicKey = window.leoWallet.publicKey; // Replace with the actual public key
        console.log(publicKey);
        
            if (!publicKey) {
                throw new WalletNotConnectedError();
            }

            //main input
            var inputs = [publicKey, `${amount}u64`, `${building}u64`];

            var aleoTransaction = Transaction.createTransaction(publicKey, 'testnet3', 'aleo_monopoly_workshop12.aleo', 'monopoly_buy', inputs, 500_000,);
            
            if (aleoTransaction) {
                window.leoWallet.requestTransaction(aleoTransaction);
                console.log('Transaction requested successfully.');
            } else {
                console.error('request Transaction function not available.');
        }
}




//=========================================================================================================
//================================= function to sale a building... ====================================
//=========================================================================================================
// Function to be executed with the value from prompt
async function sale_mono() {
    //setting amt
    var amount = document.getElementById('result').textContent; //we could fetch the balance from the past record and get the u64 amount
    var building = 1; //call from the past record to get the u64 building

    let smart_contract = 'aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m';
    let test_value = 10000;

    var publicKey = window.leoWallet.publicKey; // Replace with the actual public key
          console.log(publicKey);
          
              if (!publicKey) {
                  throw new WalletNotConnectedError();
              }

//============================ FETCHING BUILDING ID OF A PLAYER  =====================================
const apiUrl = 'https://testnet3.aleoscan.io/testnet3/program/aleo_monopoly_workshop12.aleo/mapping/unique_building/'+publicKey;
console.log(apiUrl);

try {
    // Make a fetch request to the API endpoint
    const response = await fetch(apiUrl);

    // Check if the request was successful (status code 200)
    if (!response.ok) {
        throw new Error('Network response was not ok');
    }

    const inputString = await response.text();

    // Find the index of "building id" in the input string
    var BuildingIndex = inputString.indexOf("building_id:"); //fetch building_id
    // Find the index of the "building price"
    var BuildingIndexPrice = inputString.indexOf("building_price:"); //fetch building_price

    // If "opponent:" is found, extract the building id
    if (BuildingIndex !== -1 && BuildingIndexPrice !== -1) {
        // Define the start and end indices for the building id
        var startIndex = BuildingIndex + "building_id: ".length;
        var endIndex = inputString.indexOf(",", startIndex);

        // Define the start and end indices for the building price
        var price_startIndex = BuildingIndexPrice + "building_price: ".length;
        var price_endIndex = inputString.indexOf("u64", price_startIndex);

        // Extract the building id address using substring
        var BuildingId_Player = inputString.substring(startIndex, endIndex);

        // Extract the building price address using substring
        var BuildingPrice_Player = inputString.substring(price_startIndex, price_endIndex);

        console.log("Building Id:", BuildingId_Player);
        console.log("Building Price:", BuildingPrice_Player);
    } else {
        console.log("Substring 'building id:' or 'building_price:' not found in the input string");
    }
       
  
              //main input
              var contract_address = `aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m`;
              var inputs = [publicKey, `${contract_address}`]; //selling to smart contract owner
  
              var aleoTransaction = Transaction.createTransaction(publicKey, 'testnet3', 'aleo_monopoly_workshop12.aleo', 'monopoly_sale', inputs, 900_000,);
              
              if (aleoTransaction) {
                  window.leoWallet.requestTransaction(aleoTransaction);
                  console.log('Transaction requested successfully.');
              } else {
                  console.error('request Transaction function not available.');
          }

        } catch (error) {
            console.error('Error fetching data:', error.message);
          }
}




//=========================================================================================================
//================================= function to staking to earn token. ====================================
//=========================================================================================================
function stake_earn() {
    //setting amt
    var amount = document.getElementById('result').textContent; //we could fetch the balance from the past record and get the u64 amount
    var building = 1; //call from the past record to get the u64 building

  var publicKey = window.leoWallet.publicKey; // Replace with the actual public key
        console.log(publicKey);
        
            if (!publicKey) {
                throw new WalletNotConnectedError();
            }

            //main input
            var inputs = [publicKey, `${amount}u64`, `${building}u64`];

            var aleoTransaction = Transaction.createTransaction(publicKey, 'testnet3', 'aleo_monopoly_workshop12.aleo', 'staking_utility', inputs, 500_000,);
            
            if (aleoTransaction) {
                window.leoWallet.requestTransaction(aleoTransaction);
                console.log('Transaction requested successfully.');
            } else {
                console.error('request Transaction function not available.');
        }
}




//=========================================================================================================
//================================= function to unstaking to get token. ===================================
//=========================================================================================================
function unstake_earn() {
    //setting amt
    var amount = document.getElementById('result').textContent; //we could fetch the balance from the past record and get the u64 amount
    var building = 1; //call from the past record to get the u64 building

  var publicKey = window.leoWallet.publicKey; // Replace with the actual public key
        console.log(publicKey);
        
            if (!publicKey) {
                throw new WalletNotConnectedError();
            }

            //main input
            var inputs = [publicKey, `${amount}u64`, `${building}u64`];

            var aleoTransaction = Transaction.createTransaction(publicKey, 'testnet3', 'aleo_monopoly_workshop12.aleo', 'unstaking_utility', inputs, 500_000,);
            
            if (aleoTransaction) {
                window.leoWallet.requestTransaction(aleoTransaction);
                console.log('Transaction requested successfully.');
            } else {
                console.error('request Transaction function not available.');
        }
}





//=========================================================================================================
//================================= function to bidding to get x2 token. ==================================
//=========================================================================================================
function bid_earn() {
    //setting amt
    //var amount = document.getElementById('result').textContent; //we could fetch the balance from the past record and get the u64 amount
    var building = 1; //call from the past record to get the u64 building

    // Use the prompt function to get user input
    var BidInput = prompt("Enter bid value:");

  var publicKey = window.leoWallet.publicKey; // Replace with the actual public key
        console.log(publicKey);
        
            if (!publicKey) {
                throw new WalletNotConnectedError();
            }
           
            // Check if the user clicked OK and entered a value
            if (BidInput !== null) {
            //main input
            var inputs = [publicKey, `${BidInput}u64`, `${building}u64`];

            var aleoTransaction = Transaction.createTransaction(publicKey, 'testnet3', 'aleo_monopoly_workshop12.aleo', 'bidding_info', inputs, 500_000,);
            
            if (aleoTransaction) {
                window.leoWallet.requestTransaction(aleoTransaction);
                console.log('Transaction requested successfully.');
            } else {
                console.error('request Transaction function not available.');
        }
    }else{
              // Handle the case where the user clicked Cancel or closed the prompt
              console.log("Prompt canceled");
    }
}






//=========================================================================================================
//================================= function to unbidding to get back token. ==============================
//=========================================================================================================
function unbid_earn() {
    //setting amt
    var amount = document.getElementById('result').textContent; //we could fetch the balance from the past record and get the u64 amount
    var building = 1; //call from the past record to get the u64 building

  var publicKey = window.leoWallet.publicKey; // Replace with the actual public key
        console.log(publicKey);
        
            if (!publicKey) {
                throw new WalletNotConnectedError();
            }

            //main input
            var inputs = [publicKey, `${amount}u64`, `${building}u64`];

            var aleoTransaction = Transaction.createTransaction(publicKey, 'testnet3', 'aleo_monopoly_workshop12.aleo', 'unbidding_info', inputs, 500_000,);
            
            if (aleoTransaction) {
                window.leoWallet.requestTransaction(aleoTransaction);
                console.log('Transaction requested successfully.');
            } else {
                console.error('request Transaction function not available.');
        }
}



//=========================================================================================================
//================================= function to claim bidding reward token. ===============================
//=========================================================================================================
function claim_bid_earn() {
    //setting amt
    var amount = document.getElementById('result').textContent; //we could fetch the balance from the past record and get the u64 amount
    var building = 1; //call from the past record to get the u64 building

  var publicKey = window.leoWallet.publicKey; // Replace with the actual public key
        console.log(publicKey);
        
            if (!publicKey) {
                throw new WalletNotConnectedError();
            }

            //main input
            var inputs = [publicKey, `${amount}u64`, `${building}u64`];

            var aleoTransaction = Transaction.createTransaction(publicKey, 'testnet3', 'aleo_monopoly_workshop12.aleo', 'claim_bidding_reward', inputs, 500_000,);
            
            if (aleoTransaction) {
                window.leoWallet.requestTransaction(aleoTransaction);
                console.log('Transaction requested successfully.');
            } else {
                console.error('request Transaction function not available.');
        }
}




//========================================================================================================
//=================== CHECKING A USER PERMISSION TO PLAY THE REQUEST GAME ================================
//========================================================================================================
async function play_opponent() {
    var publicKey = window.leoWallet.publicKey; // Replace with the actual public key
    //============================ NOTIFY OPPONENT PLAYER FOR VERSUS GAME =====================================
    const apiUrl = 'https://testnet3.aleoscan.io/testnet3/program/aleo_monopoly_workshop12.aleo/mapping/versus_player/'+my_hash;
    console.log(apiUrl);
    try {
        // Make a fetch request to the API endpoint
        const response = await fetch(apiUrl);
    
        // Check if the request was successful (status code 200)
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }

        const inputString = await response.text();
    
// Find the index of "opponent:" in the input string
var opponentIndex = inputString.indexOf("player:"); //fetch owner address

// If "opponent:" is found, extract the opponent's address
if (opponentIndex !== -1) {
  // Define the start and end indices for the opponent's address
  var startIndex = opponentIndex + "player: ".length;
  var endIndex = inputString.indexOf(",", startIndex);

  // Extract the opponent's address using substring
  var opponentAddress = inputString.substring(startIndex, endIndex);

  console.log("Opponent's address:", opponentAddress);
} else {
  console.log("Substring 'opponent:' not found in the input string");
}


 // Check if a match is found and the captured groups are not null
if (opponentAddress !== null) {
    //main input
    var inputs = [publicKey, opponentAddress];
    var aleoTransaction = Transaction.createTransaction(publicKey, 'testnet3', 'aleo_monopoly_workshop12.aleo', 'accept_request', inputs, 500_000);

            if (aleoTransaction) {
                window.leoWallet.requestTransaction(aleoTransaction);
                console.log('Transaction requested successfully.');
            } else {
                console.error('request Transaction function not available.');
        }     
        } else {
            console.log("Failed to fetch owner and opponent address from network request...");
        }
    
      } catch (error) {
        console.error('Error fetching data:', error.message);
      }
}








//========================================================================================================
//================================= CHECK/CLAIM VERSUS CHALLENGE GAME ====================================
//========================================================================================================
async function claim_check() {
    var publicKey = window.leoWallet.publicKey; // Replace with the actual public key
    //============================ NOTIFY OPPONENT PLAYER FOR VERSUS GAME =====================================
    const apiUrl = 'https://testnet3.aleoscan.io/testnet3/program/aleo_monopoly_workshop12.aleo/mapping/versus_player/'+my_hash;
    console.log(apiUrl);
    try {
        // Make a fetch request to the API endpoint
        const response = await fetch(apiUrl);
    
        // Check if the request was successful (status code 200)
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }

        const inputString = await response.text();
    
// Find the index of "opponent:" in the input string
var opponentIndex = inputString.indexOf("player:"); //fetch owner address

// If "opponent:" is found, extract the opponent's address
if (opponentIndex !== -1) {
  // Define the start and end indices for the opponent's address
  var startIndex = opponentIndex + "player: ".length;
  var endIndex = inputString.indexOf(",", startIndex);

  // Extract the opponent's address using substring
  var opponentAddress = inputString.substring(startIndex, endIndex);

  console.log("Opponent's address:", opponentAddress);
} else {
  console.log("Substring 'opponent:' not found in the input string");
}


 // Check if a match is found and the captured groups are not null
if (opponentAddress !== null) {
    //main input
    var inputs = [publicKey, opponentAddress];
    var aleoTransaction = Transaction.createTransaction(publicKey, 'testnet3', 'aleo_monopoly_workshop12.aleo', 'check_request', inputs, 500_000);

            if (aleoTransaction) {
                window.leoWallet.requestTransaction(aleoTransaction);
                console.log('Transaction requested successfully.');
            } else {
                console.error('request Transaction function not available.');
        }     
        } else {
            console.log("Failed to fetch owner and opponent address from network request...");
        }
    
      } catch (error) {
        console.error('Error fetching data:', error.message);
      }
}







//=========================================================================================================
//======================== function to play/register tournament to check if win. ==========================
//=========================================================================================================
function tournament_play() {
  var publicKey = window.leoWallet.publicKey; // Replace with the actual public key
        console.log(publicKey);
            if (!publicKey) {
                throw new WalletNotConnectedError();
            }
            //main input
            var inputs = [publicKey];
            var aleoTransaction = Transaction.createTransaction(publicKey, 'testnet3', 'aleo_monopoly_workshop12.aleo', 'tournament_game', inputs, 500_000,);

            if (aleoTransaction) {
                window.leoWallet.requestTransaction(aleoTransaction);
                console.log('Transaction requested successfully.');
            } else {
                console.error('request Transaction function not available.');
        }
}






//=========================================================================================================
//===================== function to play/register versus opponent to check if win. ========================
//=========================================================================================================
function versus_game_start() {
    var publicKey = window.leoWallet.publicKey; // Replace with the actual public key
    var aleo_opponent = document.getElementById('aleo_opponent_start').value;
    console.log(aleo_opponent);
          console.log(publicKey);
              if (!publicKey) {
                  throw new WalletNotConnectedError();
              }
              //main input
              var inputs = [publicKey, aleo_opponent];
              var aleoTransaction = Transaction.createTransaction(publicKey, 'testnet3', 'aleo_monopoly_workshop12.aleo', 'play_request', inputs, 500_000,);
  
              if (aleoTransaction) {
                  window.leoWallet.requestTransaction(aleoTransaction);
                  console.log('Transaction requested successfully.');
              } else {
                  console.error('request Transaction function not available.');
          }
  }







//=========================================================================================================
//====================== function to reveal hashed address from the owner to matched. =====================
//=========================================================================================================
function reveal_me() {
    var publicKey = window.leoWallet.publicKey; // Replace with the actual public key
          console.log(publicKey);
              if (!publicKey) {
                  throw new WalletNotConnectedError();
              }
              //main input
              var inputs = [publicKey];
              var aleoTransaction = Transaction.createTransaction(publicKey, 'testnet3', 'aleo_monopoly_workshop12.aleo', 'hashed_address', inputs, 400_000,);
  
              if (aleoTransaction) {
                  window.leoWallet.requestTransaction(aleoTransaction);
                  console.log('Transaction requested successfully.');
              } else {
                  console.error('request Transaction function not available.');
          }
  }






//=========================================================================================================
//================================= function to claim monopoly reward. ====================================
//=========================================================================================================
function claim_reward() {
    //setting amt
    var amount = document.getElementById('result').textContent; //we could fetch the balance from the past record and get the u64 amount
    var claim_token = 150000; //call from the past record to get the u64 building

    if(amount < 12000){
        alert("sorry, you are ineligible to claim reward! accumulate 12000 token!");
    }else{

      var publicKey = window.leoWallet.publicKey; // Replace with the actual public key
        console.log(publicKey);
        
            if (!publicKey) {
                throw new WalletNotConnectedError();
            }

            //main input
            var inputs = [publicKey, `${claim_token}u64`];

            var aleoTransaction = Transaction.createTransaction(publicKey, 'testnet3', 'aleo_monopoly_workshop12.aleo', 'mint_reward', inputs, 500_000,);
            
            if (aleoTransaction) {
                window.leoWallet.requestTransaction(aleoTransaction);
                console.log('Transaction requested successfully.');
            } else {
                console.error('request Transaction function not available.');
        }
}
}




//================================================================================================
//============================= ROLL DICE SIMULATION FUNCTIONS ===================================
//================================================================================================
// Function to generate a random number between 1 and 6 using dice rolls
function rollDice() {
    return Math.floor(Math.random() * 6) + 1;
}

// Function to create a sophisticated encrypted integer using dice rolls
function createEncryptedInteger() {
    let encryptedInt = '';
    for (let i = 0; i < 6; i++) {
        encryptedInt += rollDice().toString();
    }
    return encryptedInt;
}

// Function to split the encrypted integer into an array
function splitEncryptedInteger(encryptedInt) {
    return encryptedInt.split('').map(Number);
}



  
//=================================================================================================
//======================= function to mystery card out of 3 choices... ============================
//=================================================================================================
  // Function to enable the mystery card link
  function enableMysteryCardLink() {
    const mysteryCardLink = document.getElementById('mysteryCardLink');

    // Enable the link
    mysteryCardLink.removeAttribute('disabled');
  }

// Function to add or deduct rent based on the specified conditions
function mysteryOperation(array) {
    //setting amt
    var amount = document.getElementById('result').textContent; //we could fetch the balance from the past record and get the u64 amount
    var building = 1; //call from the past record to get the u64 building

    const firstInt = array[0];
    const lastInt = array[array.length - 1];
    const result = Math.floor((firstInt + lastInt) / 2);

        // Deduct rent ~ aleo deduct rent function
        var publicKey = window.leoWallet.publicKey; // Replace with the actual public key
        console.log(publicKey);
            if (!publicKey) {
                throw new WalletNotConnectedError();
            }
            var inputs = [publicKey, `${amount}u64`, `${building}u64`];
            
            var aleoTransaction = Transaction.createTransaction(publicKey, 'testnet3', 'aleo_monopoly_workshop12.aleo', 'mystery_card', inputs, 500_000,);
            
            if (aleoTransaction) {
                window.leoWallet.requestTransaction(aleoTransaction);
                console.log('Transaction requested successfully.');
            } else {
                console.error('request Transaction function not available.');
        }
        return 'Mytery card... processing...';  
}

const mysteryCardLink = document.getElementById("mysteryCardLink");
// Re-disable the link after it's clicked
mysteryCardLink.setAttribute('disabled', true);

mysteryCardLink.addEventListener("click", () => {
    const originalInt = Math.floor(Math.random() * 1000000); // Generate a random integer (for demonstration)
    const encryptedInt = createEncryptedInteger();
    const encryptedArray = splitEncryptedInteger(encryptedInt);
    const mysteryAction = mysteryOperation(encryptedArray);

    console.log(`Encrypted Integer: ${encryptedInt}`);
    console.log(`Encrypted Array: ${encryptedArray.join(', ')}`);
    console.log(`Mystery Action: ${mysteryAction}`);
});
// Enable the link initially after 2 minutes
setTimeout(enableMysteryCardLink, 2 * 60 * 1000);






//==========================================================================================================
//==================== Function to add or deduct rent based on the specified conditions ====================
//==========================================================================================================

function rentOperation() {
    //setting amt
    var amount = document.getElementById('result').textContent; //we could fetch the balance from the past record and get the u64 amount
    var building = 1; //call from the past record to get the u64 building

        // Deduct rent ~ aleo deduct rent function
        var publicKey = window.leoWallet.publicKey; // Replace with the actual public key
        console.log(publicKey);
            if (!publicKey) {
                throw new WalletNotConnectedError();
            }
            var inputs = [publicKey, `${amount}u64`, `${building}u64`];
            
            var aleoTransaction = Transaction.createTransaction(publicKey, 'testnet3', 'aleo_monopoly_workshop12.aleo', 'monopoly_rent', inputs, 900_000,);
            
            if (aleoTransaction) {
                window.leoWallet.requestTransaction(aleoTransaction);
                console.log('Transaction requested successfully.');
            } else {
                console.error('request Transaction function not available.');
        }
        return 'Checking Rent...';
    }

const encryptButton = document.getElementById("encryptButton");
encryptButton.addEventListener("click", () => {
    const originalInt = Math.floor(Math.random() * 1000000); // Generate a random integer (for demonstration)
    const encryptedInt = createEncryptedInteger();
    const encryptedArray = splitEncryptedInteger(encryptedInt);
    const rentAction = rentOperation(encryptedArray);

    console.log(`Encrypted Integer: ${encryptedInt}`);
    console.log(`Encrypted Array: ${encryptedArray.join(', ')}`);
    console.log(`Rent Action: ${rentAction}`);
});


