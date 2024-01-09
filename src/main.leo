//==============================================================================================================================
//==============================================================================================================================
//===============================================    ALEO MONOPOLY REBUILD II  =================================================
//======================================================  VER: 0.2.0. ==========================================================
//==============================================================================================================================
// This is the rebuild version of the Aleo-Monopoly-V0.2, now in this version, new attribute are added and new implementations
//==============================================================================================================================
//=============================================     Powered By Leo Programming    ==============================================

program aleo_monopoly_workshop7.aleo{

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
        max_building: u128,
        receiver: address,
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

    //bidding struct
    struct BiddingInfo {
        building_id: field,
        bidder: address,
        amount: u64,
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
    mapping unique_building: address => BuildingInfo;

    //new feature => staking/buying building utilites
    mapping stake_utility: address => u64;

    // true => GlobalState
    mapping global_state: bool => GlobalState;

    //true => GLOBAL TOURNAMENT STATE
    mapping global_tournament_state: field => Tournament;

    //new feature => bidding special building
    mapping special_building: field => BiddingInfo; 

   
   //==========================================================================
   // ============================ admin control ==============================
   //==========================================================================
    // Initialize the program after deployment.
    transition init(b: bool) {
        return then finalize(self.caller);
    }

    finalize init(caller: address) {
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

    transition change_admin(admin: address) {
        return then finalize(self.caller, admin);
    }

    finalize change_admin(caller: address, admin: address) {
        let gs: GlobalState = Mapping::get(global_state, true);
        assert_eq(caller, gs.admin);
        Mapping::set(global_state, true, GlobalState {
            next_token_id: gs.next_token_id,
            admin: admin,
        });
    }



    //===============================================================================================
    //======================= issue a monopoly token to a player ~ owner ============================
    //===============================================================================================
    transition issue(owner: address, amount: u64) -> (address, u64){ 
        return (owner, amount) then finalize (owner, amount);
    }
        //================= MAPPING BALANCES TO ACCOUNT TO_ADDRESS =======================
        finalize issue (owner: address, amount: u64) {
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
    transition monopoly_buy (owner: address, amount: u64, buildings: u64) -> (Buildings, u64) {
        //setting the max for unique buildings
        let max_building: u128 = 1u128;
        //spend amount
        let spend_amount: u64 = 1500u64;

        let buy_to : Buildings = Buildings{
            owner: owner,
            amount:  amount - spend_amount,
            buildings: buildings,
        };
        return (buy_to, spend_amount)  then finalize (owner, spend_amount, max_building);
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize monopoly_buy (owner: address, spend_amount: u64, max_building: u128) {
        //check if user have requested issue yet above 0u64, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists > 0u64);

        // Decrements `account[to_address]` by `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount - spend_amount);

        //checks if `owner` building had purchased the Building, if not revert()
        let new_building: u128 = 0u128;

        //random id for B_ID => Building ID
        let B_ID: field = ChaCha::rand_field();

        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, owner, BuildingInfo {
            building_id: B_ID,
            max_building: new_building,
            receiver: owner,
        });

        //check if receiver is owner
        assert(building_info.receiver == owner);
        //check only if max building = 1u128
        assert(building_info.max_building == 0u128);

        //Increment `unique_building[owner]` building by +1
        Mapping::set(unique_building, owner, BuildingInfo {
            building_id: building_info.building_id,
            max_building: (building_info.max_building + max_building),
            receiver: building_info.receiver,
        });
    }




    //====================================================================================================
    //===================================  RENT (PAY_RENT -> 150u64) BUILDING ============================
    //====================================================================================================
    //address is deducted rent of 150 token per tx run
    transition monopoly_rent (owner: address, amount: u64, buildings: u64) -> (Buildings, u64){
        //setting the max for unique buildings
        let max_building: u128 = 1u128;

        // setting amount.
        let rent_amount: u64 = 150u64; //i pay some rent fee

        let rent_to : Buildings = Buildings{
            owner: owner,
            amount:  amount,
            buildings: buildings,
        };
             return (rent_to, rent_amount) then finalize (owner, rent_amount, max_building);
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize monopoly_rent (owner: address, rent_amount: u64, max_building: u128) {
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, owner, BuildingInfo {
            building_id: 123field,
            max_building: 0u128,
            receiver: owner,
        });
        //check if receiver is owner
        assert(building_info.receiver == owner);
        //check only if max building = 1u128
        assert(building_info.max_building == 1u128);

        //check if user have requested issue yet above 0u64, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists > 0u64);

        //self.caller mapped balance
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
 
        //hash the roll dice,set in array at first
        let randomness: u64 = ChaCha::rand_u64();
        //Mapping::set(account, owner, ((randomness==2u8) || (randomness==3u8) || (randomness==5u8) || (randomness==7u8) || (randomness==11u8) || (randomness==13u8) || (randomness==17u8) || (randomness==19u8) || (randomness==23u8) || (randomness==29u8) || (randomness==31u8) || (randomness==37u8) || (randomness==41u8) || (randomness==43u8) || (randomness==47u8) || (randomness==53u8) || (randomness==59u8) || (randomness==61u8) || (randomness==67u8) || (randomness==71u8) || (randomness==73u8) || (randomness==79u8) || (randomness==83u8) || (randomness==89u8) || (randomness==97u8) || (randomness==101u8) || (randomness==103u8) || (randomness==107u8) || (randomness==109u8) || (randomness==113u8) || (randomness==127u8) || (randomness==131u8) || (randomness==137u8) || (randomness==139u8) || (randomness==149u8) || (randomness==151u8) || (randomness==157u8) || (randomness==163u8) || (randomness==167u8) || (randomness==173u8) || (randomness==179u8) || (randomness==181u8) || (randomness==191u8) || (randomness==193u8) || (randomness==197u8) || (randomness==199u8) || (randomness==211u8) || (randomness==223u8) || (randomness==227u8) || (randomness==229u8) || (randomness==233u8) || (randomness==239u8) || (randomness==241u8) || (randomness==251u8)) ? owner_amount + 150u64 : owner_amount - 150u64);
        //hash the roll dice,set in array at first => 18446744073709551615u64{FULL},    9223372036854775807.5{HALF}
        Mapping::set(account, owner, 9223372036854775808u64 > randomness ? owner_amount + 150u64 : owner_amount - 150u64);

        //check if a user address stake the building utility
        let stake_exists: u64 = Mapping::get_or_use(stake_utility, owner, 0u64);

        //apply tenary to mapping => staking to earn
        //Mapping::set(account, owner, (stake_exists == 3000u64) ? owner_amount + 100u64 : owner_amount + 0u64);
        Mapping::set(stake_utility, owner, (stake_exists >= 3000u64) ? stake_exists + 100u64 : stake_exists + 0u64);
    }



    //==========================================================================================
    //============================ MONOPOLY SALE TOKEN(coming soon)=============================
    //==========================================================================================
    transition monopoly_sale (owner: address, amount: u64, buildings: u64, sale_amount: u64, to_address: address ) -> (Buildings, address, u64){
        //setting the max for unique buildings
        let max_building: u128 = 1u128;

        let sale_amt: u64 = sale_amount;
        
        if (sale_amt >= 8000u64){
            assert(true);
        }else{
            assert(false); 
        }

        //SALE THE BUILDING AND OFFER BUILDING TO THE (owner)
        let new_buildings : u64 = 1u64;

        let sale_to : Buildings = Buildings{
            owner: owner,
            amount:  (amount + sale_amt),
            buildings: (buildings - new_buildings),
        };
             return (sale_to, to_address, sale_amt) then finalize (owner, to_address, sale_amt, max_building);
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize monopoly_sale (owner: address, to_address: address, sale_amt: u64, max_building: u128) {
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, owner, BuildingInfo {
            building_id: 123field,
            max_building: 0u128,
            receiver: owner,
        });
        //check if receiver is owner
        assert(building_info.receiver == owner);
        //check only if max building = 1u128
        assert(building_info.max_building == 1u128);

        //check if user => owner have requested issue yet above 0u64, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists > 0u64);

        //check if user => to_address have requested issue yet above 0u64, otherwise throw error
        let issue_exists_to: u64 = Mapping::get_or_use(account, to_address, 0u64);
        assert(issue_exists_to >= 8000u64);

        //assigned that I CAN ONLY SALE TO `to_address` my building 
        assert_eq(to_address, aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m);

        // Checking if all condition is true, user must unstake before sale of asset Building.
        let staking_amount: u64 = Mapping::get_or_use(stake_utility, owner, 0u64);
        assert(staking_amount == 0u64);

        // Decrements `account[to_address]` by `amount`.
        let to_address_amount: u64 = Mapping::get_or_use(account, to_address, 0u64);
        Mapping::set(account, to_address, to_address_amount - sale_amt);

        // Increments `account[owner]` by `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount + sale_amt);

        //Remove Building mapped => owner 
        let new_building_owner: u128 = building_info.max_building - max_building;
        assert(new_building_owner <= building_info.max_building);
        Mapping::set(unique_building, owner, BuildingInfo {
            building_id: building_info.building_id,
            max_building: new_building_owner,
            receiver: owner,
        });

        //Add Building mapped => to_address 
        let new_building_to_address: u128 = building_info.max_building + max_building;
        assert(new_building_to_address >= building_info.max_building);
        Mapping::set(unique_building, to_address, BuildingInfo {
            building_id: building_info.building_id,
            max_building: new_building_to_address,
            receiver: to_address,  //my own address or some dummy address to be storing buildings (my address: aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m)
        });

        //Remove mapping for => owner
        Mapping::remove(unique_building, owner);
    }



//============================================================================================
//============================ MONOPOLY MYSTERY CARD =========================================
//============================================================================================
transition mystery_card(owner: address, amount: u64, buildings: u64) -> (Buildings, u64) {
        //setting the max for unique buildings
        let max_building: u128 = 1u128;

        // setting amount.
        let mystery_amount : u64 = 1500u64;

        let mystery : Buildings = Buildings{
            owner: owner,
            amount: amount,
            buildings: buildings,
        };

     return(mystery, mystery_amount) then finalize(owner, mystery_amount, max_building);
}
     //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize mystery_card (owner: address, mystery_amount: u64, max_building: u128) {
        
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, owner, BuildingInfo {
            building_id: 123field,
            max_building: 0u128,
            receiver: owner,
        });
        //check if receiver is owner
        assert(building_info.receiver == owner);
        //check only if max building = 1u128
        assert(building_info.max_building == 1u128);

        //check if user have requested issue yet above 0u64, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists > 0u64);
        
        // get your mystery token.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        
        //hash the roll dice,set in array at first => 18446744073709551615u64{FULL},    9223372036854775807.5{HALF}
        let randomness: u64 = ChaCha::rand_u64(); //need to convert every u64 => u8 amount and re

        //Mapping::set(account,owner, ((randomness==9u8) || (randomness==18u8) || (randomness==27u8) || (randomness==36u8) || (randomness==45u8) || (randomness==54u8) || (randomness==63u8) || (randomness==72u8) || (randomness==81u8) || (randomness==90u8) || (randomness==99u8) || (randomness==108u8) || (randomness==117u8) || (randomness==126u8) || (randomness==135u8) || (randomness==144u8) || (randomness==153u8) || (randomness==162u8) || (randomness==171u8) || (randomness==180u8) || (randomness==189u8) || (randomness==192u8) || (randomness==201u8) || (randomness==210u8) || (randomness==219u8) || (randomness==228u8) || (randomness==237u8) || (randomness==246u8) || (randomness==255u8)) ? owner_amount + 1500u64 : owner_amount - 1500u64);
        Mapping::set(account, owner, randomness >= 18446744073709551615u64 ? owner_amount + 1500u64 : owner_amount - 1500u64);
    }




//=============================================================================================
//============================== MONOPOLY STAKE TO EARN MODE ==================================
//=============================================================================================
transition staking_utility(owner: address, amount: u64, buildings: u64) -> (Buildings, u64) {
        //setting the max for unique buildings
        let max_building: u128 = 1u128;
        
        //define token_action
        let token_action: u64 = 3000u64;

        let stake : Buildings = Buildings{
            owner: owner,
            amount: amount,
            buildings: buildings,
        };

     return(stake, token_action) then finalize(owner, token_action, max_building);
}
     //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize staking_utility (owner: address,  token_action: u64, max_building: u128) {
        
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, owner, BuildingInfo {
            building_id: 123field,
            max_building: 0u128,
            receiver: owner,
        });
        //check if receiver is owner
        assert(building_info.receiver == owner);
        //check only if max building = 1u128
        assert(building_info.max_building == 1u128);

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
transition unstaking_utility(owner: address, amount: u64, buildings: u64) -> (Buildings, u64) {
        //setting the max for unique buildings
        let max_building: u128 = 1u128;
        
        //define token_action
        let token_action: u64 = 3000u64;

        let unstake : Buildings = Buildings{
            owner: owner,
            amount: amount,
            buildings: buildings,
        };

     return(unstake, token_action) then finalize(owner, token_action, max_building);
}
     //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize unstaking_utility (owner: address, token_action: u64, max_building: u128) {
        
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, owner, BuildingInfo {
            building_id: 123field,
            max_building: 0u128,
            receiver: owner,
        });
        //check if receiver is owner
        assert(building_info.receiver == owner);
        //check only if max building = 1u128
        assert(building_info.max_building == 1u128);

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




//=============================================================================================
//============================== MONOPOLY BIDDING TO EARN 2X ==================================
//=============================================================================================
transition bidding_info(owner: address, amount: u64, buildings: u64) -> (BiddingInfo, u64) {
        //setting the max for unique buildings
        let max_building: u128 = 1u128;

        let bidding : BiddingInfo = BiddingInfo{
            building_id: 1151121019910597108field,
            bidder: owner,
            amount: amount,
        };
     return(bidding, amount) then finalize(owner, amount, max_building);
}
     //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize bidding_info (owner: address,  amount: u64, max_building: u128) {
        
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, owner, BuildingInfo {
            building_id: 123field,
            max_building: 0u128,
            receiver: owner,
        });
        //check if receiver is owner
        assert(building_info.receiver == owner);
        //check only if max building = 1u128
        assert(building_info.max_building == 1u128);

        //check if user have permission to bid yet above 15000u64, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists >= 15000u64);

        //Decrement `account[owner]` by `amount` used for bidding
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount - amount);

        //`special`keyword id for B_ID 
        let B_ID: field = 1151121019910597108field;

        //hash the owner address such that its not reveal the identity of owner address to public
        let hash_user: address = Keccak512::hash_to_address(owner);

        //get the bidding mapping id
        let bid_info: BiddingInfo = Mapping::get_or_use(special_building, B_ID, BiddingInfo {
            building_id: B_ID,
            bidder: hash_user,
            amount: 0u64,
        });
        //check if amount(owner) > BiddingInfo owner amount
        assert(amount > bid_info.amount);

        //check that mapped bidder doesnt bid more than once in the game bidding
        assert_neq(hash_user, bid_info.bidder);

        //sending the bidding amount back to previous bidder `account` balance in case a new bidder bid higher
        let previous_bidder: u64 = Mapping::get_or_use(account, bid_info.bidder, 0u64);
        Mapping::set(account, bid_info.bidder, previous_bidder + bid_info.amount);

        // add the new bid amount by owner.
        Mapping::set(special_building, B_ID, BiddingInfo {
            building_id: bid_info.building_id,
            bidder: hash_user,
            amount: amount,
        }); 
    }




//=============================================================================================
//============================ MONOPOLY UNBIDDING  ADDED EARNED GAIN ==========================
//=============================================================================================
transition unbidding_info(owner: address, amount: u64, buildings: u64) -> (BiddingInfo, u64) {
        //setting the max for unique buildings
        let max_building: u128 = 1u128;

        let bidding : BiddingInfo = BiddingInfo{
            building_id: 1151121019910597108field,
            bidder: owner,
            amount: amount,
        };

     return(bidding, amount) then finalize(owner, amount, max_building);
}
     //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize unbidding_info (owner: address,  amount: u64, max_building: u128) {
        
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, owner, BuildingInfo {
            building_id: 123field,
            max_building: 0u128,
            receiver: owner,
        });
        //check if receiver is owner
        assert(building_info.receiver == owner);
        //check only if max building = 1u128
        assert(building_info.max_building == 1u128);

        //`special`keyword id for B_ID 
        let B_ID: field = 1151121019910597108field;
        
        //hash the owner address such that its not reveal the identity of owner address to public
        let hash_user: address = Keccak512::hash_to_address(owner);
        
        //get the bidding mapping id
        let bid_info: BiddingInfo = Mapping::get_or_use(special_building, B_ID, BiddingInfo {
            building_id: B_ID,
            bidder: hash_user,
            amount: 0u64,
        });
        //check if bidder owner matched with hash_user
        assert_eq(bid_info.bidder, hash_user);

        //claim bidding reward to account owner => 450u64 token
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, issue_exists + bid_info.amount);

        //removing the mapping for bidded owner
        Mapping::remove(special_building, B_ID);
    }






//=============================================================================================
//============================== CLAIM BIDDING REWARD TO EARN 2X ==============================
//=============================================================================================
transition claim_bidding_reward(owner: address, amount: u64, buildings: u64) -> (BiddingInfo, u64) {
        //setting the max for unique buildings
        let max_building: u128 = 1u128;

        let bidding : BiddingInfo = BiddingInfo{
            building_id: 1151121019910597108field,
            bidder: owner,
            amount: amount,
        };

     return(bidding, amount) then finalize(owner, amount, max_building);
}
     //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize claim_bidding_reward (owner: address,  amount: u64, max_building: u128) {
        
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, owner, BuildingInfo {
            building_id: 123field,
            max_building: 0u128,
            receiver: owner,
        });
        //check if receiver is owner
        assert(building_info.receiver == owner);
        //check only if max building = 1u128
        assert(building_info.max_building == 1u128);

        //`special`keyword id for B_ID 
        let B_ID: field = 1151121019910597108field;
        
        //hash the owner address such that its not reveal the identity of owner address to public
        let hash_user: address = Keccak512::hash_to_address(owner);
        
        //get the bidding mapping id
        let bid_info: BiddingInfo = Mapping::get_or_use(special_building, B_ID, BiddingInfo {
            building_id: B_ID,
            bidder: hash_user,
            amount: 0u64,
        });
        //check if bidder owner matched with hash_user
        assert_eq(bid_info.bidder, hash_user);

        //claim bidding reward to account owner => 450u64 token
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, issue_exists + 450u64);
    }




//==============================================================================================
//=================================== REWARD FOR TO_ADDRESS ====================================
//==============================================================================================
transition mint_reward(owner: address, amount: u64) -> Reward {
       
        // Produce a token record for the specified receiver.
        let receive_reward: Reward = Reward {
            owner: owner,
            amount: amount,
        };

        // Output the sender's change record and the receiver's record.
        return receive_reward then finalize(self.caller, amount);
    }

        finalize mint_reward(owner: address, amount: u64) {
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




  //==========================================================================
   // ==================== tournament admin control ===========================
   //==========================================================================
    // Initialize the program after deployment.
    transition init_tournament(tournament_id: field, target_amt: u64, criteria_amt: u64, winners: u64, active: bool) {
        return then finalize(self.caller, tournament_id, target_amt, criteria_amt, winners, active);
    }

    finalize init_tournament(caller: address, tournament_id: field, target_amt: u64, criteria_amt: u64, winners: u64, active: bool) {
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
    transition tournament_game(owner: address) {
        return then finalize(owner);
    }

    finalize tournament_game(owner: address) {
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

    transition end_tournament(tournament_id: field, b: bool) {
        return then finalize(tournament_id, self.caller);
    }

    finalize end_tournament(tournament_id: field, caller: address) {
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



    //============================================================================================
    //==================== MONOPOLY PLAYER GAME AGAINST OPPONENT ADDRESS =========================
    //============================================================================================
    transition play_request(owner: address, opponent: address, game_begins: bool) {
        return then finalize(self.caller, opponent, game_begins);
    }

    //finalize  `player_request`
    finalize play_request(owner: address, opponent: address, game_begins: bool) {
        //check that owner is not same as `opponent`
        assert_neq(owner, opponent);
        
    }




    //=============================================================================================
    //====================== MONOPOLY SEND TOKEN FROM ADMIN TO PLAYER =============================
    //=============================================================================================
transition send_token(owner: address, to_address: address, amount: u64) -> (u64) {
        
     return(amount) then finalize(self.caller, to_address, amount);
}
     //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize send_token(owner: address, to_address: address, amount: u64) {
        //make sure Only Admin can send
        assert_eq(owner, aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m);
        //check if admin have requested issue yet above amount, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);

        //getting the to_address balance
        let issue_to_address: u64 = Mapping::get_or_use(account, to_address, 0u64);

        assert(issue_exists >= amount);
        
        //checks if `to_addresssend` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, to_address, BuildingInfo {
            building_id: 123field,
            max_building: 0u128,
            receiver: to_address,
        });
        assert(building_info.max_building == 1u128);

        // Decrements admin` by `amount`.
        Mapping::set(account, owner, issue_exists - amount); 

        //Increment `account[owner]` by `amount`
        Mapping::set(account, to_address, issue_to_address + amount);
    }



    //==============================================================================================
    //============================== CHECKING HASHED ADDRESS =======================================
    //==============================================================================================
    transition hashed_address(owner: address) -> (address) {
        //hash the owner address such that its not reveal the identity of owner address to public
        let hash_user: address = Keccak512::hash_to_address(owner);

        return (hash_user);
    }


}
