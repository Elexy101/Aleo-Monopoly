# Monopoly.aleo

##shib.aleo 

## Build Guide
<!-- # 🏦 Monopoly Game -->


A simple monopoly game in Leo.

## Summary

This program is a game of two(owner and addr2) where each gets 10,000 NGN to buy buildings

### User Flow
1. Each user in the game is issue 10,000 NGN to `buy` a property
2. The owner may buy a property and `rent` it to the next user(addr2). `rent` cost 150 NGN for addr2, `rent` cost 100 NGN for owner
3. `Sale` of property is possible when the other addr2 send a request to buy off owner property, doubling his `rent` fee ownership

Note that the program can be easily extended to include addition features such as a `fractional investing` function, which would allow owner to invest partly to other users or owner.

## Bugs

You may have already guessed that this program has a few bugs. We list some of them below: 
- `rent fee after sale maybe a problem since no desired input`

Can you find any others?

## Language Features and Concepts
- `record` declarations
- record ownership

## Running the Program

Leo provides users with a command line interface for compiling and running Leo programs.
Users may either specify input values via the command line or provide an input file in `inputs/`.

### Configuring Accounts
The `program.json` file contains a private key and address.
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
leo run monopoly
leo run monopoly_buy
leo run monopoly_rent
leo run monopoly_sale
```

### import new files
- functions.leo


### slingshot-testnet3 run
- you can deploy your program function with the command below

- ``` slingshot pour <address> 100000000 ```
- ``` slingshot deploy functions.aleo -f 10000000 ```
- ``` slingshot deploy shib.aleo -f 10000000 ```


### Run Aleo-py program
You can run the aleo-py program to run execution, store record `on-chain` 
playing the game. 
In the game, owner & addr2 has a dice number
`owner dice no. -> 3`
`addr2 dice no. -> 5`

Anything aside this no. For rent execute `monopoly_no_rent` function 

Have fun playing the game...

#screenshot
![Screenshot from 2023-02-12 08-59-31](https://user-images.githubusercontent.com/24855083/218329735-f3b4d2d9-08a8-4b9c-b2e7-0881aef7a173.png)



### BUG Feedback
Any bug or any problem, you can DM me or send @ Discord community @AleoHQ :)
