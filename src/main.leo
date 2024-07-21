//==============================================================================================================================
//==============================================================================================================================
//===============================================    ALEO MONOPOLY REBUILD II  =================================================
//======================================================  VER: 0.2.0. ==========================================================
//==============================================================================================================================
// This is the rebuild version of the Aleo-Monopoly-V0.2, now in this version, new attribute are added and new implementations
//==============================================================================================================================
// Welcome to Aleo-Monopoly Game, here there are two kind of tokens = (A) TEST GAME TOKEN & (B) REWARD GAME TOKEN
// Player must connect wallet and sign wallet and thereafter mint a 10K TEST token to begin game
// Player must buy a building so as to have access to roll dice mechanism in the game which uses ChaCha random mechanism
// Player balance are updated and is private stored in the record after every roll dice[either lose/win]
// Player have access to in-use game tools like Stake-to-earn, Bid-to-win, Versus(2 Players), Tournament Games
// `Stake-to-earn` is a function that allows player to stake 3,000 token to hedge against loss in game (ie 75% token payoff in game roll dice), who cares even if you lose/win, you earn
// `Bid-to-win` is a function that support privacy among players bidding against a auctioned building for potential earnings, but claim earning for this buildings ends after 5x times
// `Versus [2 players]` allows 2 players to play against themselves using the hash functionality to check its game id if owner/opponent matches enhancing privacy and kicking off unwanted guests
// `Tournament games` are just public rewarded games every week by contract set by admin that allows unlimited players to play and set winners will be allowed to claim, reward claim is sent to to (B) Reward Token
// Finally, the main purpose of the game is play and roll dice and accumulate up to 12,000 token or higher, when reached, player can claim reward which is sent to the Reward Token Record,..

//If for any assistance, you have issues interacting with the contract or face any problem or limited knowledge about the game, you can mail me @ emmanuellinus013@gmail.com

//=============================================     Powered By Leo Programming    ==============================================

program aleo_monopoly_workshop6.aleo{

    // Game Record
   record Buildings{
        owner : address, //address
        amount : u64, 
        buildings: u64,
    }

    // Versus reveal 2 player hash field
    record Reveal_Versus {
        owner: address,
        versus_hash: field,
    }

    // no tokens are minted upon token creation
    // admin can mint any amount of tokens up to total_supply
    // other people can mint any amount up to total_supply but individual mint can't be larger than token
    //aMONO Token => Reward Token
    struct TokenInfo {
        name: field,
        symbol: field,
        decimals: u8,
        circulating_supply: u64,
        total_supply: u64,
        testers: u64 //only limited to 1,000 testers FCFS to claim reward
        admin: address,
    }


    //TestToken => Testing token (MAX PER USER -> 10,000 token)
    struct TestToken {
        name: field,
        symbol: field,
        decimals: u8,
        circulating_supply: u64,
        total_supply: u64,
        admin: address,
    }

    //building id
    struct BuildingInfo {
        building_id: field,
        max_building: u64,
        receiver: address,
        building_price: u64,
        total_building: u64,
    }

    // Reward Record
    record Reward {
        owner: address,
        amount: u64,
    }

    //admin control
    struct GlobalState {
        // The id of token to be created by the next call to create_token
        next_token_id: field,
        admin: address,
    }


    //player against opponent struct
    struct Versus {
        game_id: field,
        player: address,
        opponent: address,
        game_begins: bool,
        player_goal: u64,
        opponent_goal: u64,
        max_game: u8 //usually one player against opponent per time
    }

    //Tournament Struct
    struct Tournament {
        tournament_id: field //monopoly game tournament name
        target_amount: u64,
        criteria_amount: u64,
        winners: u64,
        winners_active: bool,
        active: bool,
        admin: address
    }

    // On-chain storage of an `account` map, with `address` as the key
    mapping account: address => u64;

    //user claimable reward
    mapping get_reward: address => u64;

    //remaining supply of claimable reward
    mapping tokens: u64 => TokenInfo;

    //now i am the admin of the test token owning over 1500000000000u64 token
    mapping test_token: u64 => TestToken;

    //buildings ids mapped => buildings
    mapping unique_building: field => BuildingInfo;

    //new feature => staking/buying building utilites
    mapping stake_utility: address => u64;

    // true => GlobalState
    mapping global_state: bool => GlobalState;

    //true => GLOBAL TOURNAMENT STATE
    mapping global_tournament_state: field => Tournament;

    //mapping versus to player
    mapping versus_player: field => Versus;


   
   //==========================================================================
   // ============================ admin control ==============================
   //==========================================================================
    // Initialize the program after deployment.
    async transition init(b: bool) -> (address, Future) {
        let caller: address = aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m ;
        return (self.caller, finalize_init(caller));
    }

    async function finalize_init(caller: address) {
        // init global state
        let gs: GlobalState = Mapping::get_or_use(global_state, true, GlobalState {
            next_token_id: 0field,
            admin: aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m,
        });
        assert_eq(gs.next_token_id, 0field);
        assert_eq(caller, gs.admin);
        Mapping::set(global_state, true, GlobalState {
            next_token_id: 1field,
            admin: gs.admin,
        });

        // init token
        let test_supply: u64 = 15000000000000u64; //15 billion token
        //admin token amt => for testing sale mechanism 60000000 token allocated to admin
        let admin_token_amt: u64 = 60000000u64;
        //test admin by adding some token to admin => 100000u64
        let owner_amount: u64 = Mapping::get_or_use(account, caller, 0u64);
        assert(owner_amount == 0u64);
        // Increments `account[to_address]` by `amount`.
        Mapping::set(account, caller, owner_amount + admin_token_amt); 

        Mapping::set(test_token, test_supply, TestToken {
            name: 4577111110111112111108121field,
            symbol: 4577111110111112111108121field,
            decimals: 6u8,
            circulating_supply: 0u64 + admin_token_amt,
            total_supply: test_supply,
            admin: gs.admin,
        });
    }

    //========================================================================================
    //====================== Change the main admin of the program. ===========================
    //========================================================================================
    async transition change_admin(admin: address) -> (address, Future){
        return (self.caller, finalize_admin(admin));
    }
    async function finalize_admin(caller: address) {
        let gs: GlobalState = Mapping::get(global_state, true);
        assert_eq(caller, gs.admin);
        Mapping::set(global_state, true, GlobalState {
            next_token_id: gs.next_token_id,
            admin: caller,
        });
    }


    //===============================================================================================
    //======================= issue a monopoly token to a player ~ owner ============================
    //===============================================================================================
    async transition issue(owner: address, amount: u64) -> (address, u64, Future){ 
        return (owner, amount, finalize_issue(owner, amount));
    }
        //================= MAPPING BALANCES TO ACCOUNT TO_ADDRESS =======================
        async function finalize_issue (owner: address, amount: u64) {
        //set number of supplys
        let test_supply: u64 = 15000000000000u64;        //set number of supplys

        //in case admin change wallet address to another, it will reflect here in test_token_info as well
        let gs: GlobalState = Mapping::get_or_use(global_state, true, GlobalState {
            next_token_id: 0field,
            admin: aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m,
        });

        //check if admin have approve admin state
        assert(gs.next_token_id == 1field);

        let test_token_info: TestToken = Mapping::get_or_use(test_token, test_supply, TestToken {
            name: 4577111110111112111108121field,
            symbol: 4577111110111112111108121field,
            decimals: 6u8,
            circulating_supply: 0u64,
            total_supply: test_supply,
            admin: gs.admin,
        });

        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);      
        
        // Ensure the circulating <= max_supply
        let updated_circulating: u64 = test_token_info.circulating_supply + amount;
        assert(updated_circulating <= test_token_info.total_supply);

        //asserting amount to owner balance as to avoid overminting owner token balances via aleo.tools 
        assert(amount == 10000u64);

        // test token supply 
        Mapping::set(test_token, test_supply, TestToken {
            name: test_token_info.name,
            symbol: test_token_info.symbol,
            decimals: test_token_info.decimals,
            circulating_supply: updated_circulating,
            total_supply: test_token_info.total_supply,
            admin: gs.admin,
        });

        //try limit user from minting twice also
        assert(owner_amount == 0u64);

        // Increments `account[to_address]` by `amount`.
        Mapping::set(account, owner, owner_amount + amount);

    }



    //================================================================================================
    //================================= PURCHASE (BUY) BUILDING ======================================
    //================================================================================================
    //user can purchase a building or even more building depending on how much token owned equivalent to building price
    //for every x purchase of building, the building price is appreciated
    async transition monopoly_buy (owner: address,  amount: u64,  buildings: u64) -> (Buildings, u64, Future) {
        //setting the max for unique buildings
        let max_building: u64 = 1u64;
        //spend amount
        let spend_amount: u64 = 5000u64;

        let buy_to : Buildings = Buildings{
            owner: owner,
            amount:  amount - spend_amount,
            buildings: buildings,
        };
        return (buy_to, spend_amount, finalize_monopoly_buy(owner, spend_amount, max_building)); 
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        async function finalize_monopoly_buy (owner: address, spend_amount: u64, max_building: u64) {
        let hash_user_field: field = Keccak512::hash_to_field(owner);
        
        //check if user have requested issue yet above 0u64, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists > 0u64);

        //random id for B_ID => Building ID
        let B_ID: field = ChaCha::rand_field();

        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, hash_user_field, BuildingInfo {
            building_id: B_ID,
            max_building: 0u64,
            receiver: owner,
            building_price: spend_amount,
            total_building: 0u64,
        });
        
        // Decrements `account[to_address]` by `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount - building_info.building_price);


        //check if a user have enough money to buy building
        assert(owner_amount > building_info.building_price);

        //check if receiver is owner
        assert(building_info.receiver == owner);

        //check only if max building >= 0u64
        assert(building_info.max_building >= 0u64);

        //check if total buildings still remain or bought all
        assert(building_info.total_building <= 100000u64);

        //Increment `unique_building[owner]` building by +1
        Mapping::set(unique_building, hash_user_field, BuildingInfo {
            building_id: building_info.building_id,
            max_building: (building_info.max_building + max_building),
            receiver: building_info.receiver,
            building_price: (building_info.building_price + 1000u64), //for every purchase, the building price is inflated 2000 token up [ie 6000u64 + 2000u64 = 8000u64]
            total_building: building_info.total_building + max_building,
        });
    }


    //====================================================================================================
    //===================================  RENT (PAY_RENT -> 150u64) BUILDING ============================
    //====================================================================================================
    //address is deducted/added rent of 150 token per tx run which is based on random function using Chacha::Random
    //the roll up is based on head/tail event such that if a user roll less than given random, user amount is either deducted or added
    async transition monopoly_rent (owner: address, amount: u64, buildings: u64) -> (Buildings, u64, Future){
        //setting the max for unique buildings
        let max_building: u64 = 1u64;

        // setting amount.
        let rent_amount: u64 = 150u64; //i pay some rent fee

        let rent_to : Buildings = Buildings{
            owner: owner,
            amount:  amount,
            buildings: buildings,
        };
             return (rent_to, rent_amount, finalize_monopoly_rent(owner, rent_amount, max_building));
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        async function finalize_monopoly_rent (owner: address, rent_amount: u64, max_building: u64) {
        let hash_user_field: field = Keccak512::hash_to_field(owner);
        
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, hash_user_field, BuildingInfo {
            building_id: 123field,
            max_building: 0u64,
            receiver: owner,
            building_price: 0u64,
            total_building: 0u64,
        });
        //check if receiver is owner
        assert(building_info.receiver == owner);
        //check only if max building = 1u64
        assert(building_info.max_building >= 1u64);

        //check if user have requested issue yet above 0u64, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists > 0u64);

        //self.caller mapped balance
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
 
        //roll the head/tail event, you can either win/lose 
        let randomness: u64 = ChaCha::rand_u64();
        //Mapping::set(account, owner, ((randomness==2u8) || (randomness==3u8) || (randomness==5u8) || (randomness==7u8) || (randomness==11u8) || (randomness==13u8) || (randomness==17u8) || (randomness==19u8) || (randomness==23u8) || (randomness==29u8) || (randomness==31u8) || (randomness==37u8) || (randomness==41u8) || (randomness==43u8) || (randomness==47u8) || (randomness==53u8) || (randomness==59u8) || (randomness==61u8) || (randomness==67u8) || (randomness==71u8) || (randomness==73u8) || (randomness==79u8) || (randomness==83u8) || (randomness==89u8) || (randomness==97u8) || (randomness==101u8) || (randomness==103u8) || (randomness==107u8) || (randomness==109u8) || (randomness==113u8) || (randomness==127u8) || (randomness==131u8) || (randomness==137u8) || (randomness==139u8) || (randomness==149u8) || (randomness==151u8) || (randomness==157u8) || (randomness==163u8) || (randomness==167u8) || (randomness==173u8) || (randomness==179u8) || (randomness==181u8) || (randomness==191u8) || (randomness==193u8) || (randomness==197u8) || (randomness==199u8) || (randomness==211u8) || (randomness==223u8) || (randomness==227u8) || (randomness==229u8) || (randomness==233u8) || (randomness==239u8) || (randomness==241u8) || (randomness==251u8)) ? owner_amount + 150u64 : owner_amount - 150u64);
        //hash the roll dice,set in array at first => 18446744073709551615u64{FULL},    9223372036854775807.5{HALF}
        Mapping::set(account, owner, 9223372036854775808u64 > randomness ? owner_amount + (building_info.max_building * 150u64) : owner_amount - (building_info.max_building * 150u64));

        //check if a user address stake the building utility
        let stake_exists: u64 = Mapping::get_or_use(stake_utility, owner, 0u64);

        //apply tenary to mapping => staking to earn
        //Mapping::set(account, owner, (stake_exists == 3000u64) ? owner_amount + 100u64 : owner_amount + 0u64);
        Mapping::set(stake_utility, owner, (stake_exists >= 3000u64) ? stake_exists + 100u64 : stake_exists + 0u64);
    }




   //======================================================================================================
    //============================ MONOPOLY SALE TOKEN(sale building to admin)=============================
    //=====================================================================================================
    async transition monopoly_sale (owner: address, to_address: address ) -> (address, address, Future){

        return (owner, to_address, finalize_monopoly_sale(owner, to_address));
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
    async function finalize_monopoly_sale (owner: address, to_address: address) {
        let hash_user_field: field = Keccak512::hash_to_field(owner);
        let hash_receiver_field: field = Keccak512::hash_to_field(to_address);

        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, hash_user_field, BuildingInfo {
            building_id: 123field,
            max_building: 0u64,
            receiver: owner,
            building_price: 0u64,
            total_building: 0u64,
        });
        //check if receiver is owner
        assert(building_info.receiver == owner);
        //check only if max building = 1u64
        assert(building_info.max_building >= 1u64);

        //check if user => owner have requested issue yet above 0u64, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists > 0u64);

        //check if user => to_address have requested issue yet above 0u64, otherwise throw error
        let issue_exists_to: u64 = Mapping::get_or_use(account, to_address, 0u64);
        assert(issue_exists_to >= 5000u64);

        //assigned that I CAN ONLY SALE TO `to_address` my building => The contract admin
        assert_eq(to_address, aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m);

        // Checking if all condition is true, user must unstake before sale of asset Building.
        let staking_amount: u64 = Mapping::get_or_use(stake_utility, owner, 0u64);
        assert(staking_amount == 0u64);

        // Decrements `account[to_address]` by `amount`.
        let to_address_amount: u64 = Mapping::get_or_use(account, to_address, 0u64);
        //Mapping::set(account, to_address, (building_info.max_building * (to_address_amount - sale_amt)));
         Mapping::set(account, to_address, to_address_amount - (building_info.max_building * building_info.building_price));

        // Increments `account[owner]` by `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount + (building_info.max_building * building_info.building_price));

        //Remove Building mapped => owner 
        let new_building_owner: u64 = building_info.max_building;
        assert(new_building_owner <= building_info.max_building);
        Mapping::set(unique_building, hash_user_field, BuildingInfo {
            building_id: building_info.building_id,
            max_building: new_building_owner,
            receiver: owner,
            building_price: (building_info.building_price - 600u64),
            total_building: (building_info.total_building - building_info.max_building),
        });

        //Add Building mapped => to_address 
        let new_building_to_address: u64 = building_info.max_building + new_building_owner;
        assert(new_building_to_address >= building_info.max_building);
        Mapping::set(unique_building, hash_receiver_field, BuildingInfo {
            building_id: building_info.building_id,
            max_building: new_building_to_address,
            receiver: to_address,  //my own address or some dummy address to be storing buildings (my address: aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m)
            building_price: building_info.building_price,
            total_building: building_info.total_building
        });

        //Remove mapping for => owner
        Mapping::remove(unique_building, hash_user_field);
    }





//=============================================================================================
//============================== MONOPOLY STAKE TO EARN MODE ==================================
//user can stake 3000 token to earn for every rent roll head/tail a 100 token added => just a hedge against loss in game
//staked amount must be withdraw all before you can sale your building to contract
//=============================================================================================
async transition staking_utility(owner: address, amount: u64, buildings: u64) -> (Buildings, u64, Future) {        
        //define token_action
        let token_action: u64 = 3000u64;

        let stake : Buildings = Buildings{
            owner: owner,
            amount: amount,
            buildings: buildings,
        };

     return(stake, token_action, finalize_staking_utility(owner, token_action));
}
     //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        async function finalize_staking_utility (owner: address,  token_action: u64) {
        let hash_user_field: field = Keccak512::hash_to_field(owner);
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, hash_user_field, BuildingInfo {
            building_id: 123field,
            max_building: 0u64,
            receiver: owner,
            building_price: 0u64,
            total_building: 0u64,
        });
        //check if receiver is owner
        assert(building_info.receiver == owner);
        //check only if max building = 1u64
        assert(building_info.max_building >= 1u64);

        //check if user have requested issue yet above 3000u64, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists >= 3000u64);

        //Decrement `account[owner]` by `amount` => to offer to staking account
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount - token_action);

        // Increments `stake_utility[owner]` by `amount` => earn 90 token for every roll dice to earn.
        let staking_amount: u64 = Mapping::get_or_use(stake_utility, owner, 0u64);
        assert(staking_amount == 0u64);
        Mapping::set(stake_utility, owner, staking_amount + token_action); 

    }




//=============================================================================================
//====================== MONOPOLY UNSTAKE TO GET EARNED TOKEN MODE ============================
//=============================================================================================
async transition unstaking_utility(owner: address, amount: u64, buildings: u64) -> (Buildings, u64, Future) {
        //define token_action
        let token_action: u64 = 3000u64;

        let unstake : Buildings = Buildings{
            owner: owner,
            amount: amount,
            buildings: buildings,
        };

     return(unstake, token_action, finalize_unstaking_utility(owner, token_action));
}
     //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        async function finalize_unstaking_utility (owner: address, token_action: u64) {
        let hash_user_field: field = Keccak512::hash_to_field(owner);
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, hash_user_field, BuildingInfo {
            building_id: 123field,
            max_building: 0u64,
            receiver: owner,
            building_price: 0u64,
            total_building: 0u64,
        });
        //check if receiver is owner
        assert(building_info.receiver == owner);
        //check only if max building = 1u64
        assert(building_info.max_building >= 1u64);

        //check if user have requested issue yet above 3000u64, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists >= 0u64);

        // Decrements `stake_utility[owner]` by `stake amount`.
        let unstaking_amount: u64 = Mapping::get_or_use(stake_utility, owner, 0u64);
        assert(unstaking_amount >= 3000u64);

        //Increment `account[owner]` by `amount` => to offer to owner main account
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount + unstaking_amount);

        Mapping::set(stake_utility, owner, unstaking_amount - unstaking_amount); 

    }







//==============================================================================================
//=================================== REWARD FOR TO_ADDRESS ====================================
//==============================================================================================
async transition mint_reward(owner: address, amount: u64) -> (Reward, Future) {
       
        // Produce a token record for the specified receiver.
        let receive_reward: Reward = Reward {
            owner: owner,
            amount: amount,
        };

        // Output the sender's change record and the receiver's record.
        return (receive_reward, finalize_mint_reward(owner, amount));
    }

        async function finalize_mint_reward(owner: address, amount: u64) {
        //set number of supplys
        let supply_reward: u64 = 15000000000000u64;

        let token_info: TokenInfo = Mapping::get_or_use(tokens, supply_reward, TokenInfo {
            name: 4577111110111112111108121field,
            symbol: 4577111110111112111108121field,
            decimals: 6u8,
            circulating_supply: 0u64,
            total_supply: supply_reward,
            testers: 0u64,
            admin: aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m,
        });

        let circulating_supply: u64 = token_info.circulating_supply + amount;
        assert(circulating_supply <= token_info.total_supply);

        Mapping::set(tokens, supply_reward, TokenInfo {
            name: token_info.name,
            symbol: token_info.symbol,
            decimals: token_info.decimals,
            circulating_supply: circulating_supply,
            total_supply: token_info.total_supply,
            testers: token_info.testers + 1u64,
            admin: token_info.admin,
        });

        //to check if user have accumulated a rent via monopoly above 12000u64 aside from 10000u64 after earning 2000u64
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64); 
        assert(owner_amount >= 12000u64);

        //check if testers have exceeded the amount needed to be tester, we only need 5,000 testers winner out of overall monopolists
        assert(token_info.testers <= 5000u64);

        //check if user have reward already once, otherwise throw error
        let reward_exists: u64 = Mapping::get_or_use(get_reward, owner, 0u64);
        assert_eq(reward_exists, 0u64);

        // Increments `account[sender]` by `amount`.
        // If `get_reward[owner]` does not exist, it will be created.
        let reward_amount: u64 = Mapping::get_or_use(get_reward, owner, 0u64);
        Mapping::set(get_reward, owner, reward_amount + amount);
    }



    //============================================================================================
    //==================== MONOPOLY PLAYER GAME AGAINST OPPONENT ADDRESS =========================
    //============================================================================================
    async transition play_request(owner: address, opponent: address) -> (Future) {
        return (finalize_play_request(owner, opponent));
    }

    //finalize  `player_request`
    async function finalize_play_request(owner: address, opponent: address) {
        
        // init versus request
        let versus_request : Versus = Mapping::get_or_use(versus_player, 123field, Versus {
            game_id: 123field, //monopoly game tournament name
            player: owner,
            opponent: opponent,
            game_begins: false,
            player_goal: 0u64,
            opponent_goal: 0u64,
            max_game: 0u8,
        });

        //check that owner is not same as `opponent`
        assert_neq(owner, opponent);

        //check that game is played against one opponent at a time
        assert_eq(versus_request.max_game, 0u8);

        //getting the mapped balance of owner, opponent
        let owner_balance: u64 = Mapping::get_or_use(account, owner, 0u64);
        let opponent_balance: u64 =  Mapping::get_or_use(account, opponent, 0u64);

        //check if owner and opponent have enough balance [>= 1000u64]
        assert(owner_balance >= 1000u64);
        assert(opponent_balance >= 1000u64);
        
        //setting goal
        //let owner_set_goal: u64 = (owner_balance + 1000u64);
        //let opponent_set_goal: u64 = (opponent_balance + 1000u64);
        
        //hash the owner address such that its not reveal the identity of owner address to public
        let hash_owner: field = Keccak512::hash_to_field(owner);
        //hash the opponent
        let hash_opponent: field = Keccak512::hash_to_field(opponent);
        //add both owner_hash and opponent_hash
        let add_hash: field = hash_owner + hash_opponent;

        // set versus request
        Mapping::set(versus_player, add_hash, Versus {
            game_id: add_hash, //monopoly game tournament name
            player: owner,
            opponent: opponent,
            game_begins: false,
            player_goal: 0u64,
            opponent_goal: 0u64,
            max_game: 0u8,
        });

        
    }





    //============================================================================================
    //==================== MONOPOLY ACCEPT GAME AGAINST OPPONENT ADDRESS =========================
    //============================================================================================
    async transition accept_request(owner: address, opponent: address, game_hash: field) -> (Future){
        return (finalize_accept_request(self.caller, opponent, game_hash));
    }

    //finalize  `player_request`
    async function finalize_accept_request(owner: address, opponent: address, game_hash: field) {
        
        // init versus request
        let versus_request : Versus = Mapping::get_or_use(versus_player, game_hash, Versus {
            game_id: game_hash, //monopoly game tournament name
            player: owner,
            opponent: opponent,
            game_begins: false,
            player_goal: 0u64,
            opponent_goal: 0u64,
            max_game: 0u8,
        });

        //check that owner is not same as `opponent`
        assert_neq(owner, opponent);

        //check that game is played against one opponent at a time
        assert_eq(versus_request.max_game, 0u8);

        //getting the mapped balance of owner, opponent
        let owner_balance: u64 = Mapping::get_or_use(account, owner, 0u64);
        let opponent_balance: u64 =  Mapping::get_or_use(account, opponent, 0u64);

        //check if owner and opponent have enough balance [>= 1000u64]
        assert(owner_balance >= 1000u64);
        assert(opponent_balance >= 1000u64);
        
        //setting goal => +1000 to each respective balance against as a `goal`
        let owner_set_goal: u64 = (owner_balance + 1000u64);
        let opponent_set_goal: u64 = (opponent_balance + 1000u64);
        
        //hash the owner address such that its not reveal the identity of owner address to public
        let hash_owner: field = Keccak512::hash_to_field(owner);
        //hash the opponent
        let hash_opponent: field = Keccak512::hash_to_field(opponent);
        //add both owner_hash and opponent_hash
        let add_hash: field = hash_owner + hash_opponent;

        //check if hash match with user opponent address and game_id
        assert_eq(add_hash, versus_request.game_id);
        assert_eq(add_hash, game_hash);

        //check that it cant be called again
        assert_eq(versus_request.game_begins, false);

        // set versus request
        Mapping::set(versus_player, add_hash, Versus {
            game_id: add_hash, //monopoly game tournament name
            player: owner,
            opponent: opponent,
            game_begins: true,
            player_goal: owner_set_goal,
            opponent_goal: opponent_set_goal,
            max_game: 1u8,
        });   
    }





    //============================================================================================
    //==================== MONOPOLY CHECK  GAME AGAINST OPPONENT ADDRESS =========================
    //============================================================================================
    async transition check_request(owner: address, opponent: address, game_hash: field) -> (Future) {
        return (finalize_check_request(self.caller, opponent, game_hash));
    }

    //finalize  `player_request`
    async function finalize_check_request(owner: address, opponent: address, game_hash: field) {
        
        // init versus request
        let versus_request : Versus = Mapping::get_or_use(versus_player, game_hash, Versus {
            game_id: game_hash, //monopoly game tournament name
            player: owner,
            opponent: opponent,
            game_begins: false,
            player_goal: 0u64,
            opponent_goal: 0u64,
            max_game: 0u8,
        });

        //check that owner is not same as `opponent`
        assert_neq(owner, opponent);

        //getting the mapped balance of owner, opponent
        let owner_balance: u64 = Mapping::get_or_use(account, owner, 0u64);
        let opponent_balance: u64 =  Mapping::get_or_use(account, opponent, 0u64);

        //check that game is played against one opponent at a time (GAME PLAYED::TRUE)
        assert_eq(versus_request.max_game, 1u8);

        //check if owner and opponent have enough balance [>= 1000u64]
        assert((owner_balance >= 1000u64) || (opponent_balance >= 1000u64));
        
        //hash the owner address such that its not reveal the identity of owner address to public
        let hash_owner: field = Keccak512::hash_to_field(owner);
        //hash the opponent
        let hash_opponent: field = Keccak512::hash_to_field(opponent);
        //add both owner_hash and opponent_hash
        let add_hash: field = hash_owner + hash_opponent;

        //check if hash match with user opponent address and game_id
        assert_eq(add_hash, versus_request.game_id);
        assert_eq(add_hash, game_hash);

        //check that it cant be called again
        assert_eq(versus_request.game_begins, false);

        //check if owner or opponent is higher than its goal
        assert((owner_balance >= versus_request.player_goal) || (opponent_balance >= versus_request.opponent_goal));

        // check versus request if whether owner wins
        Mapping::set(account, owner, (owner_balance >= versus_request.player_goal) ? (owner_balance + 1000u64) : owner_balance + 0u64);
        // check versus request if whether opponent wins
        Mapping::set(account, opponent, (opponent_balance >= versus_request.opponent_goal) ? opponent_balance + 1000u64 : opponent_balance + 0u64);


        // remove versus request after winner found!
        Mapping::remove(versus_player, versus_request.game_id);   
    }






  //==========================================================================
   // ==================== tournament admin control ===========================
   //==========================================================================
    // Initialize the program after deployment.
    async transition init_tournament(tournament_id: field, target_amt: u64, criteria_amt: u64, winners: u64, active: bool) -> (Future) {
        return finalize_init_tournament(self.caller, tournament_id, target_amt, criteria_amt, winners, active);
    }

    async function finalize_init_tournament(caller: address, tournament_id: field, target_amt: u64, criteria_amt: u64, winners: u64, active: bool) {
        // init global state
        let gts: Tournament = Mapping::get_or_use(global_tournament_state, 123field, Tournament {
            tournament_id: tournament_id, //monopoly game tournament name
            target_amount: 0u64,
            criteria_amount: 0u64,
            winners: 0u64,
            winners_active: false,
            active: true,
            admin: aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m
        });
        assert_eq(caller, gts.admin);

        //tournament id for TOURNAMENT ID
        //let TOUR_ID: field = ChaCha::rand_field();
        Mapping::set(global_tournament_state, tournament_id, Tournament {
            tournament_id: tournament_id, //monopoly game tournament name
            target_amount: target_amt,
            criteria_amount: criteria_amt,
            winners: winners,
            winners_active: false,
            active: true,
            admin: gts.admin
        });
    }









   //==========================================================================
   // ========================= tournament control ============================
   //==========================================================================
    // Initialize the program after deployment.
    async transition tournament_game(owner: address) -> (Future){
        return (finalize_tournament_game(owner));
    }

    async function finalize_tournament_game(owner: address) {
        // init global state
        let gts: Tournament = Mapping::get_or_use(global_tournament_state, 123field, Tournament {
            tournament_id: 123field, //monopoly game tournament name
            target_amount: 0u64,
            criteria_amount: 0u64,
            winners: 0u64,
            winners_active: false,
            active: true,
            admin: aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m
        });

        assert_eq(gts.active, true); //make sure game is active
        //assert_eq(owner, gts.gamer); //check if player match player tournament 

        //check if user have reached criteria amount and have goal-match target amount in the game
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists >= gts.target_amount && issue_exists >= gts.criteria_amount);

        //check max winners if its up to selected winners selected
        assert(gts.winners_active == false);
        let add_winner: u64 = gts.winners - 1u64;

        //check if there is still pace to claim, if winners reach 0u64, end tournament
        assert(gts.winners > 0u64);
        //then add reward to winners automatically if they check tournament to win otherwise revert
        let tournament_reward: u64 = Mapping::get_or_use(get_reward, owner, 0u64);
        Mapping::set(get_reward, owner, tournament_reward + 5000u64); //every tournament has a goal reward of 5000 token allocated to user reward mapped key
       

        Mapping::set(global_tournament_state, gts.tournament_id, Tournament {
            tournament_id: gts.tournament_id, //monopoly game tournament name
            target_amount: gts.target_amount,
            criteria_amount: gts.criteria_amount,
            winners: add_winner,
            winners_active: true,
            active: true,
            admin: aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m
        });
    }



   //==========================================================================
   // =================== END tournament admin control  =======================
   //==========================================================================
   // Bug in this admin end control is that its manually controlled by admin,
   // Admin must be active/online to end the tournament round

    async transition end_tournament(tournament_id: field, b: bool) -> (Future) {
        return finalize_end_tournament(tournament_id, self.caller);
    }

    async function finalize_end_tournament(tournament_id: field, caller: address) {
        // init global state
        let gts: Tournament = Mapping::get_or_use(global_tournament_state, 123field, Tournament {
            tournament_id: 123field, //monopoly game tournament name
            target_amount: 0u64,
            criteria_amount: 0u64,
            winners: 0u64,
            winners_active: false,
            active: true,
            admin: aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m
        });
        //check if admin matched admin address
        assert_eq(caller, gts.admin);

        //check the assigned tournament id to be removed, other tournament remains...
        assert_eq(tournament_id, gts.tournament_id);

        //check if winners have reached climax before ending tournament game, otherwise game cannot end!
        assert_eq(gts.winners, 0u64);

        //REMOVE TOURNAMENT ID
        Mapping::remove(global_tournament_state, gts.tournament_id);
    }







    //==============================================================================================
    //======================= ADDING HASHED ADDRESS[OWNER + OPPONENT] ==============================
    //==============================================================================================
    transition combine_owner_opponent_hash(owner: address, opponent: address) -> (Reveal_Versus) {
        //check that owner is self.caller
        assert_eq(owner, self.caller);
        //hash the owner address such that its not reveal the identity of owner address to public
        let hash_owner: field = Keccak512::hash_to_field(owner);
        //hash the opponent
        let hash_opponent: field = Keccak512::hash_to_field(opponent);
        //add both owner_hash and opponent_hash
        let add_hash: field = hash_owner + hash_opponent;

        //Add versus Reveal
        let update_hash : Reveal_Versus = Reveal_Versus {
            owner: owner,
            versus_hash: add_hash,
        };
        return (update_hash);
    }




    //=============================================================================================
    //====================== MONOPOLY SEND TOKEN FROM ADMIN TO PLAYER =============================
    //=============================================================================================
async transition send_token(owner: address, to_address: address, amount: u64) -> (u64, Future) {
        
     return(amount, finalize_send_token(owner, to_address, amount));
}
     //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        async function finalize_send_token(owner: address, to_address: address, amount: u64) {
        //make sure Only Admin can send
        assert_eq(owner, aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m);
        //check if admin have requested issue yet above amount, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);

        //getting the to_address balance
        let issue_to_address: u64 = Mapping::get_or_use(account, to_address, 0u64);

        assert(issue_exists >= amount);
        
        let hash_receiver_field: field = Keccak512::hash_to_field(to_address);
        //checks if `to_addresssend` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, hash_receiver_field, BuildingInfo {
            building_id: 123field,
            max_building: 0u64,
            receiver: to_address,
            building_price: 0u64,
            total_building: 0u64,
        });
        assert(building_info.max_building >= 1u64);

        // Decrements admin` by `amount`.
        Mapping::set(account, owner, issue_exists - amount); 

        //Increment `account[owner]` by `amount`
        Mapping::set(account, to_address, issue_to_address + amount);
    }



    //==============================================================================================
    //========================== SAMPLE CHECKING HASHED ADDRESS ====================================
    //==============================================================================================
    transition hashed_address(owner: address) -> (Reveal_Versus) {
        //hash the owner address/field such that its not reveal the identity of owner address/field to public
        let hash_user: address = Keccak512::hash_to_address(owner);
        let hash_user_field: field = Keccak512::hash_to_field(owner);
       
        //Add versus Reveal
        let update_hash : Reveal_Versus = Reveal_Versus {
            owner: hash_user,
            versus_hash: hash_user_field,
        };

        return (update_hash);
    }

}
