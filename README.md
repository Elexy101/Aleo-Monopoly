# Monopoly.aleo
The Aleo Monopoly Rebuild II program (version 0.2.0) is a smart contract written in Leo programming language. This smart contract is designed for a game resembling a monopoly where players can interact with tokens, buildings, and various in-game actions

## Build Guide
<!-- # 🏦 Monopoly Game -->


A simple monopoly game in Leo.

Please `replace` your address and private key in the code ~ both in the `.env` and `input` file 

## Summary

This program is a game of owner where each gets 10,000 token to buy buildings of 1,500 token

### User Flow
1. Each user in the game is issue 10,000 token to `buy` a property of 1500 token
2. The owner may buy a property and `rent` to earn by rolling dice. if you roll exact dice, you earn 150 token, otherwise you lose 150 token
3. `Sale` of property is possible when the other user send a request to buy off owner property, doubling his `rent` fee ownership
4. `Mystery card` Implements actions related to mystery cards, again influenced by a random choice.
5. `Mint Reward Transition`: Mints rewards for players based on certain conditions.

Note that the program can be easily extended to include addition features such as a `fractional investing` function, which would allow owner to invest partly to other users or owner.


#Token and Building Structures
`aMONO Token Structure (TokenInfo):`
- Represents a custom token named aMONO.
- Contains information such as token name, symbol, decimals, circulating supply, total supply, and admin address.

`Building Information Structure (BuildingInfo):`
- Describes a building in the Monopoly game.
- Includes a unique building ID, maximum building count, and the receiver's address.

#Game Records and Mappings
`Game Record (Buildings):`
- Records the owner's address, the amount of tokens, and the number of buildings owned.

#Mappings:
- `account:` Maps addresses to their respective token balances.
- `get_reward:` Maps addresses to claimable reward amounts.
- `tokens:` Maps token IDs to their corresponding TokenInfo.
- `unique_building:` Maps unique building IDs to their BuildingInfo.
  
#Token Issuance and Management
`Token Issuance (issue transition):`
- Allows the issuance of aMONO tokens to a specified player.
- Checks the caller's address before processing the issuance.


## Bugs

You may have already guessed that this program has a few bugs. We list some of them below: 
- `rent fee after sale maybe a problem since no desired input`

Can you find any others?

## Language Features and Concepts
- `record declarations`
- `record ownership`
- `struct implementation`
- `mapping data`

## Running the Program

Leo provides users with a command line interface for compiling and running Leo programs.
Users may either specify input values via the command line or provide an input file in `inputs/`.

### Configuring Accounts
The `program.json`/`.env` file contains a private key and address.
This is the account that will be used to sign transactions and is checked for record ownership.
When executing programs as different parties, be sure to set the `private_key` and `address` fields in `program.json` to the appropriate values.


See `./run.sh` for an example of how to run the program as different parties.


The [Aleo SDK](https://github.com/AleoHQ/leo/tree/testnet3) provides a command line interface for generating new accounts.
To generate a new account, run
```
leo account new
```

### Using an input file.
1. Modify `inputs/shib.in` with the desired inputs.
2. Run
```bash
leo run <function_name>
```
For example,
```bash
leo run issue
leo run monopoly_buy
leo run monopoly_rent
leo run monopoly_sale
leo run mystery_card
leo run mint_reward => test
```

#Conclusion
This Aleo Monopoly Rebuild II smart contract provides a robust foundation for implementing an intriguing and feature-rich Monopoly game on the Aleo blockchain. It incorporates various game mechanics, including token issuance, building management, and mystery card interactions. Developers can contribute to its evolution and enhancement by following the provided contribution guidelines.

Have fun playing the game...

#screenshot
![new_monopoly](https://github.com/Elexy101/Aleo-Monopoly/assets/24855083/dedf40f8-653e-4a59-a8ab-fa7361cb36a1)


#Screen record
https://github.com/Elexy101/Aleo-Monopoly/assets/24855083/29c474fa-fdf7-4ef9-9036-48dacee79c5e

### BUG Feedback
Any bug or any problem, you can DM me or send @ Discord community @AleoHQ :)
