//==============================================================================================================================
//==============================================================================================================================
//===============================================    ALEO MONOPOLY REBUILD II  =================================================
//======================================================  VER: 0.2.0. ==========================================================
//==============================================================================================================================
// This is the rebuild version of the Aleo-Monopoly-V0.2, now in this version, new attribute are added and new implementations
//==============================================================================================================================
//=============================================     Powered By Leo Programming    ==============================================

program aleo_monopoly2.aleo{

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
        circulating_supply: u128,
        total_supply: u128,
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
        amount: u128,
    }


    // On-chain storage of an `account` map, with `address` as the key
    mapping account: address => u64;

    //user claimable reward
    mapping get_reward: address => u128;

    //remaining supply of claimable reward
    mapping tokens: u128 => TokenInfo;

    //buildings ids mapped => buildings
    mapping unique_building: u128 => BuildingInfo;

    //issue a monopoly token to a player ~ to_address 
    transition issue(to_address: address, amount: u64) -> (address, u64){ 
        //check self.caller
        check_address(to_address);

        return (to_address, amount) then finalize (to_address, amount);
    }
        //================= MAPPING BALANCES TO ACCOUNT TO_ADDRESS =======================
        finalize issue (public to_address: address, public amount: u64) {

        //check if user have issue already, otherwise throw error
        let issue_exists: u64 = Mapping::get(account, to_address) | 0u64;
        assert_eq(issue_exists, 0u64);

        // Increments `account[to_address]` by `amount`.
        let to_address_amount: u64 = Mapping::get_or_use(account, to_address, 0u64);
        Mapping::set(account, to_address, to_address_amount + amount);
    }




    //================================================================================================
    //================================= PURCHASE (BUY) BUILDING ======================================
    //================================================================================================
    transition monopoly_buy (buy: Buildings, spend_amount: u64) -> (Buildings, u64) {
        //check self.caller
        check_address(buy.owner);

        //setting the max for unique buildings
        let max_building: u128 = 1u128;

        let buy_to : Buildings = Buildings{
            owner: buy.owner,
            amount:  buy.amount - spend_amount,
            buildings: buy.buildings,
        };
        return (buy_to, spend_amount)  then finalize (self.caller, spend_amount, max_building);
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize monopoly_buy (public owner: address, public spend_amount: u64, max_building: u128) {
        
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get(unique_building, max_building);
        assert_eq(building_info.max_building, 0u128);

        //check if user have requested issue yet above 0u64, otherwise throw error
        let issue_exists: u64 = Mapping::get(account, owner) | 0u64;
        assert_eq(issue_exists, 0u64);

        // Decrements `account[to_address]` by `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount - spend_amount);

        //Increment `account[to_address]` building by +1
        Mapping::set(unique_building, max_building, BuildingInfo {
        building_id: building_info.building_id,
        max_building: (building_info.max_building + max_building),
        receiver: building_info.receiver,
    });
    }





    //====================================================================================================
    //=============================  RENT (ADD/DEDUCT_RENT -> 150u64) BUILDING ===========================
    //====================================================================================================
    //address is deducted rent of 150 token per tx run
    transition monopoly_rent (rent: Buildings, random_roll: u64, rent_amount: u64) -> (Buildings, u64, u64){
        //check self.caller
        check_address(rent.owner);

        //setting the max for unique buildings
        let max_building: u128 = 1u128;

        if (rent_amount  == 150u64){
           assert(true);
        }else{
           assert(false);
        }
        
        let rent_to : Buildings = Buildings{
            owner: rent.owner,
            amount:  rent.amount - rent_amount,
            buildings: rent.buildings,
        };
             return (rent_to, random_roll, rent_amount) then finalize (self.caller, random_roll, rent_amount, max_building);
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize monopoly_rent (public owner: address, public random_roll: u64, public rent_amount: u64, max_building: u128) {

        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get(unique_building, max_building);
        assert(building_info.max_building > 0u128);

        //check if user have requested issue yet above 0u64, otherwise throw error
        let issue_exists: u64 = Mapping::get(account, owner) | 0u64;
        assert_neq(issue_exists, 0u64);

        if(random_roll == 1u64 || random_roll == 6u64){
            // Increments `account[owner` by `rent amount` => Rent added.
            let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
            Mapping::set(account, owner, owner_amount + rent_amount);
        }
        else if (random_roll == 2u64 || random_roll == 3u64 || random_roll == 4u64 || random_roll == 5u64) {
            // Decrements `account[owner]` by `rent amount` => Rent deducted.
            let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
            Mapping::set(account, owner, owner_amount - rent_amount);
        }
        else{
            // nothing occurs if error/bug happens
            let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
            Mapping::set(account, owner, owner_amount +  0u64);
        }

    }



    //==========================================================================================
    //============================ MONOPOLY SALE TOKEN(coming soon)=============================
    //==========================================================================================
    transition monopoly_sale (sale: Buildings, to_address: address, sale_amount: u64) -> (Buildings, address, u64){
        //check self.caller
        check_address(sale.owner);

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
            owner: sale.owner,
            amount:  (sale.amount + sale_amt),
            buildings: (sale.buildings - new_buildings),
        };
             return (sale_to, to_address, sale_amt) then finalize (self.caller, to_address, sale_amt, max_building);
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize monopoly_sale (public owner: address, public to_address: address, public sale_amt: u64, max_building: u128) {
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get(unique_building, max_building);
        assert(building_info.max_building > 0u128);

        //check if user have requested issue yet above 0u64, otherwise throw error
        let issue_exists: u64 = Mapping::get(account, owner) | 0u64;
        assert_neq(issue_exists, 0u64);

        // Decrements `account[to_address]` by `amount`.
        let to_address_amount: u64 = Mapping::get_or_use(account, to_address, 0u64);
        Mapping::set(account, to_address, to_address_amount - sale_amt);

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
            receiver: to_address,
        });

        // Increments `account[owner]` by `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount + sale_amt);
    }



//============================================================================================
//============================ MONOPOLY MYSTERY CARD =========================================
//============================================================================================
transition mystery_card(mc: Buildings, random_choose: u64, token_action: u64) -> (Buildings, u64, u64) {
            //check self.caller
        check_address(mc.owner);

        //setting the max for unique buildings
        let max_building: u128 = 1u128;

        
        let mystery : Buildings = Buildings{
            owner: mc.owner,
            amount: mc.amount,
            buildings: mc.buildings,
        };

     return(mystery, random_choose, token_action) then finalize(self.caller, random_choose, token_action, max_building);
}
     //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize mystery_card (public owner: address, public random_choose: u64, public token_action: u64, max_building: u128) {
        
        //checks if `owner` building had purchased the Building, if not revert()
        let building_info: BuildingInfo = Mapping::get(unique_building, max_building);
        assert(building_info.max_building > 0u128);

        //check if user have requested issue yet above 0u64, otherwise throw error
        let issue_exists: u64 = Mapping::get(account, owner) | 0u64;
        assert_neq(issue_exists, 0u64);

        if(random_choose == 1u64 || random_choose == 3u64){
            // Increments `account[owner]` by `amount` => goodluck mystery.
            let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
            Mapping::set(account, owner, owner_amount + token_action);
        }
        else if(random_choose == 2u64 || random_choose == 4u64 || random_choose == 5u64){
            // Decrement `account[owner]` by `amount` => badluck mystery.
            let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
            Mapping::set(account, owner, owner_amount - token_action);
        }else if(random_choose == 6u64){
            // Decrement `account[owner]` by `amount` => deadly mystery.
            let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
            Mapping::set(account, owner, owner_amount - 5000u64);
        }else{
            // Data remains constant in case bug occurs.
            let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
            Mapping::set(account, owner, owner_amount + 0u64);
        }
        
    }


//==============================================================================================
//=================================== REWARD FOR TO_ADDRESS ====================================
//==============================================================================================
transition mint_reward(to_address: address, amount: u128) -> Reward {
       //check self.caller
       //check_address(to_address);

       //set number of supplys
       let supply_reward: u128 = 1500000000u128;
       // Compute the hash of the token owner.
       let hash: address = BHP256::hash_to_address(to_address);

        // Produce a token record for the specified receiver.
        let receive_reward: Reward = Reward {
            owner: to_address,
            amount: amount,
        };

        // Output the sender's change record and the receiver's record.
        return receive_reward then finalize(self.caller, amount, supply_reward);
    }

        finalize mint_reward(public to_address: address, public amount: u128, public supply: u128,) {
        let token_info: TokenInfo = Mapping::get(tokens, supply);

        let circulating_supply: u128 = token_info.circulating_supply - amount;
        assert(circulating_supply <= token_info.total_supply);

        Mapping::set(tokens, supply, TokenInfo {
            name: token_info.name,
            symbol: token_info.symbol,
            decimals: token_info.decimals,
            circulating_supply: circulating_supply,
            total_supply: token_info.total_supply,
            admin: token_info.admin,
        });

        //to check if user have accumulated a rent via monopoly above 15000u64 aside from 10000u64 
        assert_eq(Mapping::get(account, to_address), 15000u64);

        //check if user have reward already once, otherwise throw error
        let reward_exists: u128 = Mapping::get(get_reward, to_address) | 0u128;
        assert_eq(reward_exists, 0u128);

        // Decrements `account[sender]` by `amount`.
        // If `get_reward[to_address]` does not exist, it will be created.
        // If `get_reward[to_address] + amount` underflows, `transfer_public_to_private` is reverted.
        let reward_amount: u128 = Mapping::get_or_use(get_reward, to_address, 0u128);
        Mapping::set(get_reward, to_address, reward_amount + amount);
    }


    //check address = self.caller (Helper function)
    function check_address(owner: address) -> bool {
        if(owner == self.caller){
            assert(true);
        }else{
            assert(false);
        }
        return true;
    }

}
