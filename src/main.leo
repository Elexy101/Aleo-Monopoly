//==============================================================================================================================
//==============================================================================================================================
//===============================================    ALEO MONOPOLY REBUILD III  =================================================
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

program aleo_monopoly_test02.aleo{

    // Game Record
   record Buildings{
        owner : address, //address
        amount : u64, 
        buildings: u64,
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
        testers: u64, //only limited to 1,000 testers FCFS to claim reward
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

    // true => GlobalState
    mapping global_state: bool => GlobalState;

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
    async transition monopoly_buy (owner: address,  amount: u64) -> (Buildings, u64, Future) {
        //setting the max for unique buildings
        let buildings: u64 = 1u64;
        //spend amount
        let spend_amount: u64 = 5000u64;

        let buy_to : Buildings = Buildings{
            owner: owner,
            amount:  amount - spend_amount,
            buildings: buildings,
        };
        return (buy_to, spend_amount, finalize_monopoly_buy(owner, spend_amount, buildings)); 
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        async function finalize_monopoly_buy (owner: address, spend_amount: u64, buildings: u64) {
        let hash_user_field: field = Keccak512::hash_to_field(owner);
        
        //check if user have requested issue yet above 0u64, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists > 0u64);

        //random id for B_ID => Building ID
        let B_ID: field = ChaCha::rand_field();

        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, hash_user_field, BuildingInfo {
            building_id: B_ID,
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

        //check only if total building >= 0u64
        assert(building_info.total_building >= 0u64);

        //Increment `unique_building[owner]` building by +1
        Mapping::set(unique_building, hash_user_field, BuildingInfo {
            building_id: building_info.building_id,
            receiver: building_info.receiver,
            building_price: (building_info.building_price + 500u64), //for every purchase, the building price is inflated 2000 token up [ie 6000u64 + 2000u64 = 8000u64]
            total_building: building_info.total_building + buildings,
        });
    }


    //====================================================================================================
    //===================================  RENT (PAY_RENT -> 150u64) BUILDING ============================
    //====================================================================================================
    //address is deducted/added rent of 150 token per tx run which is based on random function using Chacha::Random
    //the roll up is based on head/tail event such that if a user roll less than given random, user amount is either deducted or added
    async transition monopoly_rent (owner: address, amount: u64, buildings: u64) -> (Buildings, u64, Future){

        // setting amount.
        let rent_amount: u64 = 150u64; //i pay some rent fee

        let rent_to : Buildings = Buildings{
            owner: owner,
            amount:  amount,
            buildings: buildings,
        };
             return (rent_to, rent_amount, finalize_monopoly_rent(owner, rent_amount));
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        async function finalize_monopoly_rent (owner: address, rent_amount: u64) {
        let hash_user_field: field = Keccak512::hash_to_field(owner);
        
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, hash_user_field, BuildingInfo {
            building_id: 123field,
            receiver: owner,
            building_price: 0u64,
            total_building: 0u64,
        });
        //check if receiver is owner
        assert(building_info.receiver == owner);
        //check only if max building = 1u64
        assert(building_info.total_building >= 1u64);

        //check if user have requested issue yet above 0u64, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists > 0u64);

        //self.caller mapped balance
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
 
        //roll the head/tail event, you can either win/lose 
        let randomness: u64 = ChaCha::rand_u64();
        //hash the roll dice,set in array at first => 18446744073709551615u64{FULL},    9223372036854775807.5{HALF}
        Mapping::set(account, owner, 9223372036854775808u64 > randomness ? owner_amount + (building_info.total_building * 150u64) : owner_amount - (building_info.total_building * 150u64));
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
            receiver: owner,
            building_price: 0u64,
            total_building: 0u64,
        });
        //check if receiver is owner
        assert(building_info.receiver == owner);
        //check only if max building = 1u64
        assert(building_info.total_building >= 1u64);

        //check if user => owner have requested issue yet above 0u64, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists > 0u64);

        //check if user => to_address have requested issue yet above 0u64, otherwise throw error
        let issue_exists_to: u64 = Mapping::get_or_use(account, to_address, 0u64);
        assert(issue_exists_to >= 5000u64);

        //assigned that I CAN ONLY SALE TO `to_address` my building => The contract admin
        assert_eq(to_address, aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m);

        //ASSIGNED BUILDING FEE PER BUILDING 
        let building_fee: u64 = 1000u64;

        // Decrements `account[to_address]` by `amount`.
        let to_address_amount: u64 = Mapping::get_or_use(account, to_address, 0u64);
        //Mapping::set(account, to_address, (building_info.max_building * (to_address_amount - sale_amt)));
         Mapping::set(account, to_address, to_address_amount - ((building_info.total_building * building_info.building_price) - (building_info.total_building * building_fee)));

        // Increments `account[owner]` by `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount + ((building_info.total_building * building_info.building_price) - building_fee));

        //Remove Building mapped => owner 
        let new_building_owner: u64 = building_info.total_building;
        assert(new_building_owner <= building_info.total_building);
        Mapping::set(unique_building, hash_user_field, BuildingInfo {
            building_id: building_info.building_id,
            receiver: owner,
            building_price: (building_info.building_price - (building_info.total_building * 600u64)),
            total_building: (building_info.total_building - building_info.total_building),
        });

        //Add Building mapped => to_address 
        let new_building_to_address: u64 = building_info.total_building + new_building_owner;
        assert(new_building_to_address >= building_info.total_building);
        Mapping::set(unique_building, hash_receiver_field, BuildingInfo {
            building_id: building_info.building_id,
            receiver: to_address,  //my own address or some dummy address to be storing buildings (my address: aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m)
            building_price: building_info.building_price,
            total_building: new_building_to_address
        });

        //Remove mapping for => owner
        Mapping::remove(unique_building, hash_user_field);
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
    async transition accept_request(owner: address, opponent: address) -> (Future){
        return (finalize_accept_request(self.caller, opponent));
    }

    //finalize  `player_request`
    async function finalize_accept_request(owner: address, opponent: address) {
        //hash the owner address such that its not reveal the identity of owner address to public
        let hash_owner: field = Keccak512::hash_to_field(owner);
        //hash the opponent
        let hash_opponent: field = Keccak512::hash_to_field(opponent);
        //add both owner_hash and opponent_hash
        let add_hash: field = hash_owner + hash_opponent;
   
        // init versus request
        let versus_request : Versus = Mapping::get_or_use(versus_player, add_hash, Versus {
            game_id: add_hash, //monopoly game tournament name
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
        

        //check if hash match with user opponent address and game_id
        assert_eq(add_hash, versus_request.game_id);

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
    async transition check_request(owner: address, opponent: address) -> (Future) {
        return (finalize_check_request(self.caller, opponent));
    }

    //finalize  `player_request`
    async function finalize_check_request(owner: address, opponent: address) {
        
        //hash the owner address such that its not reveal the identity of owner address to public
        let hash_owner: field = Keccak512::hash_to_field(owner);
        //hash the opponent
        let hash_opponent: field = Keccak512::hash_to_field(opponent);
        //add both owner_hash and opponent_hash
        let add_hash: field = hash_owner + hash_opponent;  

        // init versus request
        let versus_request : Versus = Mapping::get_or_use(versus_player, add_hash, Versus {
            game_id: add_hash, //monopoly game tournament name
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

        //check if hash match with user opponent address and game_id
        assert_eq(add_hash, versus_request.game_id);

        //check that it cant be called again
        assert_eq(versus_request.game_begins, true);

        //check if owner or opponent is higher than its goal
        assert((owner_balance >= versus_request.player_goal) || (opponent_balance >= versus_request.opponent_goal));

        // check versus request if whether owner wins
        Mapping::set(account, owner, (owner_balance >= versus_request.player_goal) ? (owner_balance + 1000u64) : owner_balance + 0u64);
        // check versus request if whether opponent wins
        Mapping::set(account, opponent, (opponent_balance >= versus_request.opponent_goal) ? opponent_balance + 1000u64 : opponent_balance + 0u64);


        // remove versus request after winner found!
        Mapping::remove(versus_player, versus_request.game_id);   
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
            receiver: to_address,
            building_price: 0u64,
            total_building: 0u64,
        });
        assert(building_info.total_building >= 1u64);

        // Decrements admin` by `amount`.
        Mapping::set(account, owner, issue_exists - amount); 

        //Increment `account[owner]` by `amount`
        Mapping::set(account, to_address, issue_to_address + amount);
    }





}
