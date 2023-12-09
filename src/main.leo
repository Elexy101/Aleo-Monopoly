//==============================================================================================================================
//==============================================================================================================================
//===============================================    ALEO MONOPOLY REBUILD II  =================================================
//======================================================  VER: 0.2.0. ==========================================================
//==============================================================================================================================
// This is the rebuild version of the Aleo-Monopoly-V0.2, now in this version, new attribute are added and new implementations
//==============================================================================================================================
//=============================================     Powered By Leo Programming    ==============================================

program aleo_monopoly_test3.aleo{

    // Game Record
   record Buildings{
        owner : address, //address
        amount : u64, 
        buildings: u64,
    }

    // no tokens are minted upon token creation
    // admin can mint any amount of tokens up to total_supply
    // other people can mint any amount up to total_supply but individual mint can't be larger than token
    //aMONO Token
    struct TokenInfo {
        name: field,
        symbol: field,
        decimals: u8,
        circulating_supply: u64,
        total_supply: u64,
        admin: address,
    }


    //TestToken
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
        block_height: u32,
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
    mapping unique_building: u128 => BuildingInfo;

    //new feature => staking/buying building utilites
    mapping stake_utility: address => u64;

    // true => GlobalState
    mapping global_state: bool => GlobalState;

    //new feature => bidding special building
    mapping special_building: u64 => BiddingInfo; 

   
   //==========================================================================
   // ============================ admin control ==============================
   //==========================================================================
    // Initialize the program after deployment.
    transition init(public b: bool) {
        return then finalize(self.caller);
    }

    finalize init(public caller: address) {
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
        let test_supply: u64 = 15000000000u64; //15 billion token
        Mapping::set(test_token, test_supply, TestToken {
            name: 4577111110111112111108121field,
            symbol: 4577111110111112111108121field,
            decimals: 6u8,
            circulating_supply: 0u64,
            total_supply: test_supply,
            admin: gs.admin,
        });

    }

    //========================================================================================
    //====================== Change the main admin of the program. ===========================
    //========================================================================================

    transition change_admin(public admin: address) {
        return then finalize(self.caller, admin);
    }

    finalize change_admin(public caller: address, public admin: address) {
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
    transition issue(public owner: address, public amount: u64) -> (address, u64){ 
        return (owner, amount) then finalize (owner, amount);
    }
        //================= MAPPING BALANCES TO ACCOUNT TO_ADDRESS =======================
        finalize issue (public owner: address, public amount: u64) {
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
        //asserting amount to owner balance as to avoid overminting owner token balances via aleo.tools 
        assert(amount == 10000u64);

        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);      
        
        // Ensure the circulating <= max_supply
        let updated_circulating: u64 = test_token_info.circulating_supply + amount;
        assert(updated_circulating <= test_token_info.total_supply);

        //try limit user from minting twice also
        assert(owner_amount == 0u64);

        // test token supply 
        Mapping::set(test_token, test_supply, TestToken {
            name: test_token_info.name,
            symbol: test_token_info.symbol,
            decimals: test_token_info.decimals,
            circulating_supply: updated_circulating,
            total_supply: test_token_info.total_supply,
            admin: gs.admin,
        });

        // Increments `account[to_address]` by `amount`.
        Mapping::set(account, owner, owner_amount + amount);

    }



    //================================================================================================
    //================================= PURCHASE (BUY) BUILDING ======================================
    //================================================================================================
    transition monopoly_buy (public owner: address, public amount: u64, public buildings: u64) -> (Buildings, u64) {
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
        finalize monopoly_buy (public owner: address, public spend_amount: u64, public max_building: u128) {
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

        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, max_building, BuildingInfo {
            building_id: B_ID,
            max_building: new_building,
            receiver: owner,
        });
        
        assert(building_info.max_building < 1u128);


        //Increment `unique_building[owner]` building by +1
        Mapping::set(unique_building, max_building, BuildingInfo {
            building_id: building_info.building_id,
            max_building: (building_info.max_building + max_building),
            receiver: building_info.receiver,
        });
    }




    //====================================================================================================
    //===================================  RENT (PAY_RENT -> 150u64) BUILDING ============================
    //====================================================================================================
    //address is deducted rent of 150 token per tx run
    transition monopoly_rent (public owner: address, public amount: u64, public buildings: u64, public random_roll: u64) -> (Buildings, u64){
        //setting the max for unique buildings
        let max_building: u128 = 1u128;

        // setting amount.
        let rent_amount: u64 = 150u64; //i pay some rent fee
        
        let rent_to : Buildings = Buildings{
            owner: owner,
            amount:  amount,
            buildings: buildings,
        };
             return (rent_to, rent_amount) then finalize (owner, rent_amount, random_roll, max_building);
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize monopoly_rent (public owner: address, public rent_amount: u64, public random_roll: u64, public max_building: u128) {
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, max_building, BuildingInfo {
            building_id: 123field,
            max_building: 0u128,
            receiver: owner,
        });
        assert(building_info.max_building > 0u128);

        //check if user have requested issue yet above 0u64, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists > 0u64);

        //self.caller mapped balance
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        //hash the roll dice,set in array at first
      
        //apply tenary to mapping
        Mapping::set(account, owner, (random_roll == 1u64) ? owner_amount + 150u64 : owner_amount - 150u64);
       
        //check if a user address stake the building utility
        let stake_exists: u64 = Mapping::get_or_use(stake_utility, owner, 0u64);

        //apply tenary to mapping => staking to earn
        Mapping::set(account, owner, (stake_exists == 3000u64) ? owner_amount + 100u64 : owner_amount + 0u64);

    }



    //==========================================================================================
    //============================ MONOPOLY SALE TOKEN(coming soon)=============================
    //==========================================================================================
    transition monopoly_sale (public owner: address, public amount: u64, public buildings: u64, public sale_amount: u64, public to_address: address ) -> (Buildings, address, u64){
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
        finalize monopoly_sale (public owner: address, public to_address: address, public sale_amt: u64, public max_building: u128) {
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, max_building, BuildingInfo {
            building_id: 123field,
            max_building: 0u128,
            receiver: owner,
        });
        assert(building_info.max_building > 0u128);

        //check if user => owner have requested issue yet above 0u64, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists > 0u64);

        //check if user => to_address have requested issue yet above 0u64, otherwise throw error
        let issue_exists_to: u64 = Mapping::get_or_use(account, to_address, 0u64);
        assert(issue_exists_to >= 8000u64);

        // Decrements `account[to_address]` by `amount`.
        let to_address_amount: u64 = Mapping::get_or_use(account, to_address, 0u64);
        Mapping::set(account, to_address, to_address_amount - sale_amt);

        // Increments `account[owner]` by `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount + sale_amt);

        //Remove Building mapped => owner 
        let new_building_owner: u128 = building_info.max_building - max_building;
        assert(new_building_owner <= building_info.max_building);
        Mapping::set(unique_building, max_building, BuildingInfo {
            building_id: building_info.building_id,
            max_building: new_building_owner,
            receiver: owner,
        });

        //Add Building mapped => to_address 
        let new_building_to_address: u128 = building_info.max_building + max_building;
        assert(new_building_to_address >= building_info.max_building);
        Mapping::set(unique_building, max_building, BuildingInfo {
            building_id: building_info.building_id,
            max_building: new_building_to_address,
            receiver: to_address,  //my own address or some dummy address to be storing buildings (my address: aleo1az8p9vlllyqwtj0c2g9svkd0e5v0p3zzdflwwrpa7kpe8xrfxgfqqpru7m)
        });

    }



//============================================================================================
//============================ MONOPOLY MYSTERY CARD =========================================
//============================================================================================
transition mystery_card(public owner: address, public amount: u64, public buildings: u64, public random_choose: u64) -> (Buildings, u64, u64) {
        //setting the max for unique buildings
        let max_building: u128 = 1u128;

        // setting amount.
        let mystery_amount : u64 = 1500u64;
        let mystery : Buildings = Buildings{
            owner: owner,
            amount: amount,
            buildings: buildings,
        };

     return(mystery, mystery_amount, random_choose) then finalize(owner, mystery_amount, random_choose, max_building);
}
     //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize mystery_card (public owner: address, public mystery_amount: u64, public random_choose: u64, public max_building: u128) {
        
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, max_building, BuildingInfo {
            building_id: 123field,
            max_building: 0u128,
            receiver: owner,
        });
        assert(building_info.max_building > 0u128);

        //check if user have requested issue yet above 0u64, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists > 0u64);
        
        // get your mystery token.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);

        //apply tenary to mapping
        let add_rent: u64 = owner_amount + 1500u64;
        let deduct_rent: u64 = owner_amount - 1500u64;
        Mapping::set(account,owner, (random_choose == 5u64) ? owner_amount + 1500u64 : owner_amount - 1500u64);
    }




//=============================================================================================
//============================== MONOPOLY STAKE TO EARN MODE ==================================
//=============================================================================================
transition staking_utility(public owner: address, public amount: u64, public buildings: u64) -> (Buildings, u64) {
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
        finalize staking_utility (public owner: address,  public token_action: u64, public max_building: u128) {
        
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, max_building, BuildingInfo {
            building_id: 123field,
            max_building: 0u128,
            receiver: owner,
        });
        assert(building_info.max_building > 0u128);

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
transition unstaking_utility(public owner: address, public amount: u64, public buildings: u64) -> (Buildings, u64) {
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
        finalize unstaking_utility (public owner: address, public token_action: u64, public max_building: u128) {
        
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, max_building, BuildingInfo {
            building_id: 123field,
            max_building: 0u128,
            receiver: owner,
        });
        assert(building_info.max_building > 0u128);

        //check if user have requested issue yet above 3000u64, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists >= 0u64);

        // Decrements `stake_utility[owner]` by `stake amount`.
        let unstaking_amount: u64 = Mapping::get_or_use(stake_utility, owner, 0u64);
        assert(unstaking_amount == 3000u64);
        Mapping::set(stake_utility, owner, unstaking_amount - token_action); 

        //Increment `account[owner]` by `amount` => to offer to owner main account
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount + token_action);
    }




//=============================================================================================
//============================== MONOPOLY BIDDING TO EARN 2X ==================================
//=============================================================================================
transition bidding_info(public owner: address, public amount: u64, public buildings: u64) -> (BiddingInfo, u64) {
        //setting the max for unique buildings
        let max_building: u128 = 1u128;

        let bidding : BiddingInfo = BiddingInfo{
            building_id: 123field,
            bidder: owner,
            amount: amount,
            block_height: 0u32,
        };
     return(bidding, amount) then finalize(owner, amount, max_building);
}
     //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize bidding_info (public owner: address,  public amount: u64, public max_building: u128) {
        
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, max_building, BuildingInfo {
            building_id: 123field,
            max_building: 0u128,
            receiver: owner,
        });
        assert(building_info.max_building > 0u128);

        //check if user have permission to bid yet above 20000u64, otherwise throw error
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        assert(issue_exists >= 20000u64);

        //Decrement `account[owner]` by `amount` used for bidding
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount - amount);

        //random id for B_ID => Building ID
        let B_ID: field = ChaCha::rand_field();

        //let new block.height = 0u32
        let new_block_height: u32 = 0u32;

        //get the bidding mapping id
        let bid_info: BiddingInfo = Mapping::get_or_use(special_building, amount, BiddingInfo {
            building_id: B_ID,
            bidder: owner,
            amount: 0u64,
            block_height: new_block_height,
        });
        //check if amount(owner) > BiddingInfo owner amount
        assert(amount > bid_info.amount);

        // add the new bid amount by owner.
        Mapping::set(special_building, amount, BiddingInfo {
            building_id: bid_info.building_id,
            bidder: owner,
            amount: amount,
            block_height: bid_info.block_height,
        }); 
    }





//=============================================================================================
//============================== CLAIM BIDDING REWARD TO EARN 2X ==============================
//=============================================================================================
transition claim_bidding_reward(public owner: address, public amount: u64, public buildings: u64) -> (BiddingInfo, u64) {
        //setting the max for unique buildings
        let max_building: u128 = 1u128;

        let bidding : BiddingInfo = BiddingInfo{
            building_id: 123field,
            bidder: owner,
            amount: amount,
            block_height: 0u32,
        };

     return(bidding, amount) then finalize(owner, amount, max_building);
}
     //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize claim_bidding_reward (public owner: address,  public amount: u64, public max_building: u128) {
        
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get_or_use(unique_building, max_building, BuildingInfo {
            building_id: 123field,
            max_building: 0u128,
            receiver: owner,
        });
        assert(building_info.max_building > 0u128);

        //let new block.height = 86400u32
        let new_block_height: u32 = 86400u32;

        //random id for B_ID => Building ID
        let B_ID: field = ChaCha::rand_field();

        //get the bidding mapping id
        let bid_info: BiddingInfo = Mapping::get_or_use(special_building, amount, BiddingInfo {
            building_id: B_ID,
            bidder: owner,
            amount: 0u64,
            block_height: new_block_height,
        });
        //check if amount(owner) > BiddingInfo owner amount
        assert_eq(bid_info.bidder, owner);

        //claim bidding reward to account owner => 300u64 token
        let issue_exists: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, issue_exists + 300u64);
    }




//==============================================================================================
//=================================== REWARD FOR TO_ADDRESS ====================================
//==============================================================================================
transition mint_reward(public owner: address, public amount: u64) -> Reward {
       
        // Produce a token record for the specified receiver.
        let receive_reward: Reward = Reward {
            owner: owner,
            amount: amount,
        };

        // Output the sender's change record and the receiver's record.
        return receive_reward then finalize(self.caller, amount);
    }

        finalize mint_reward(public owner: address, public amount: u64) {
        //set number of supplys
        let supply_reward: u64 = 1500000000u64;

        let token_info: TokenInfo = Mapping::get_or_use(tokens, supply_reward, TokenInfo {
            name: 4577111110111112111108121field,
            symbol: 4577111110111112111108121field,
            decimals: 6u8,
            circulating_supply: 0u64,
            total_supply: supply_reward,
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
            admin: token_info.admin,
        });

        //to check if user have accumulated a rent via monopoly above 12000u64 aside from 10000u64 after earning 2000u64
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64); 
        assert(owner_amount >= 12000u64);

        //check if user have reward already once, otherwise throw error
        let reward_exists: u64 = Mapping::get_or_use(get_reward, owner, 0u64);
        assert_eq(reward_exists, 0u64);

        // Increments `account[sender]` by `amount`.
        // If `get_reward[owner]` does not exist, it will be created.
        let reward_amount: u64 = Mapping::get_or_use(get_reward, owner, 0u64);
        Mapping::set(get_reward, owner, reward_amount + amount);
    }

}
