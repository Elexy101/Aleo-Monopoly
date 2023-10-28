//==============================================================================================================================
//==============================================================================================================================
//===============================================    ALEO MONOPOLY REBUILD II  =================================================
//======================================================  VER: 0.2.0. ==========================================================
//==============================================================================================================================
// This is the rebuild version of the Aleo-Monopoly-V0.2, now in this version, new attribute are added and new implementations
//==============================================================================================================================
//=============================================     Powered By Leo Programming    ==============================================

program aleo_monopoly1.aleo{

    // Game Record
   record Buildings{
        owner : address, //address
        amount : u64, 
        //white_color: bool, //if the building is white, the amt per cost will be 1500 token
        buildings: u64,
    }

    // Reward Record
    record Reward {
        supply: u64,
        owner: address,
        amount: u64,
    }

    // On-chain storage of an `account` map, with `address` as the key,
    // and `u64` as the value.
    mapping account: address => u64;

    //user claimable reward
    mapping get_reward: address => u64;

    //remaining supply of claimable reward
    mapping remaining_supply: u64 => u64; 

    //issue a monopoly token to a player ~ to_address 
    transition issue(to_address: address, amount: u64) -> (address, u64){ 
        // Compute the owner as `owner`.
        assert_eq(self.caller, to_address);
        //let hash: address = BHP256::hash_to_address(to_address); => encrypting your owned address with another unique aleo address
        return (to_address, amount) then finalize (to_address, amount);
    }
        //================= MAPPING BALANCES TO ACCOUNT TO_ADDRESS =======================
        finalize issue (public to_address: address, public amount: u64) {

        // Increments `account[to_address]` by `amount`.
        let to_address_amount: u64 = Mapping::get_or_use(account, to_address, 0u64);
        Mapping::set(account, to_address, to_address_amount + amount);
    }




    //================================================================================================
    //================================= PURCHASE (BUY) BUILDING ======================================
    //================================================================================================
    transition monopoly_buy (buy: Buildings, spend_amount: u64) -> (Buildings, u64) {
        // Compute the owner as `owner`.
        assert_eq(self.caller, buy.owner);

        let buy_to : Buildings = Buildings{
            owner: buy.owner,
            amount:  buy.amount - spend_amount,
            buildings: buy.buildings,
        };
        return (buy_to, spend_amount)  then finalize (self.caller, spend_amount);
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize monopoly_buy (public owner: address, public spend_amount: u64) {
        // Decrements `account[to_address]` by `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount - spend_amount);
    }





    //====================================================================================================
    //============================= DEDUCT RENT (DEDUCT_RENT -> -150) BUILDING ==============================
    //====================================================================================================
    //address is deducted rent of 150 token per tx run
    transition monopoly_rent (rent: Buildings, rent_amount: u64) -> (Buildings, u64){
        // Compute the owner as `owner`.
        assert_eq(self.caller, rent.owner);

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
             return (rent_to, rent_amount) then finalize (self.caller, rent_amount);
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize monopoly_rent (public owner: address, public rent_amount: u64) {
        // Decrements `account[to_address]` by `rent amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount - rent_amount);

    }




    //====================================================================================================
    //=============================== ADD RENT (GET_RENT -> +150) BUILDING ===============================
    //====================================================================================================
    //address receive rent of 150 token per tx run
    transition monopoly_rent2 (rent: Buildings, rent_amount: u64) -> (Buildings, u64){
        // Compute the owner as `owner`.
        assert_eq(self.caller, rent.owner);

        if (rent_amount  == 150u64){
            assert(true);
        }else{
            assert(false);
        }

        let rent_to : Buildings = Buildings{
            owner: rent.owner,
            amount:  rent.amount + rent_amount,
            buildings: rent.buildings,
        };
             return (rent_to, rent_amount) then finalize (rent.owner, rent_amount);
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize monopoly_rent2 (public to_address: address, public rent_amount: u64) {
        // increment `account[to_address]` by `rent amount`.
        let to_address_amount: u64 = Mapping::get_or_use(account, to_address, 0u64);
        Mapping::set(account, to_address, to_address_amount + rent_amount);

    }



    //==========================================================================================
    //============================ MONOPOLY SALE TOKEN =========================================
    //==========================================================================================
    transition monopoly_sale (sale: Buildings, to_address: address, sale_amount: u64) -> (Buildings, address, u64){
        // Compute the owner as `owner`.
        assert_eq(self.caller, sale.owner);

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
             return (sale_to, to_address, sale_amt) then finalize (self.caller, to_address, sale_amt);
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize monopoly_sale (public owner: address, public to_address: address, public sale_amt: u64) {
        // Increments `account[owner]` by `amount`.
        let to_address_amount: u64 = Mapping::get_or_use(account, to_address, 0u64);
        Mapping::set(account, to_address, to_address_amount - sale_amt);

        // Decrements `account[to_address]` by `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount + sale_amt);
    }


//=============================================================================================
//========================== 1st MYSTERY CARD #1 ==============================================
//============================== TOKEN ADDER ==================================================
transition mystery_card_1 (mc1: Buildings,  token_adder: u64) -> (Buildings, u64){
        // Compute the owner as `owner`.
        assert_eq(self.caller, mc1.owner);

        // new amount ~ owner
        let new_amt: u64 = mc1.amount - token_adder;
  
        let mystery : Buildings = Buildings{
            owner: mc1.owner,
            amount:  new_amt,
            buildings: mc1.buildings,
        };
             return (mystery, token_adder)  then finalize (self.caller, token_adder);
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize mystery_card_1 (public owner: address, public token_adder: u64) {
        // Increments `account[owner]` by `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount + token_adder);
        
    }


//=============================================================================================
//========================== 2nd MYSTERY CARD #2 =============================================
//============================= TOKEN REMOVER ================================================
transition mystery_card_2 (mc2: Buildings,  token_remover: u64) -> (Buildings, u64){
        // Compute the owner as `owner`.
        assert_eq(self.caller, mc2.owner);
        
        //token remover :( ooopss
        let new_amt : u64 = mc2.amount + token_remover;

        let mystery : Buildings = Buildings{
            owner: mc2.owner,
            amount:  new_amt,
            buildings: mc2.buildings,
        };
             return (mystery, token_remover)  then finalize (self.caller, token_remover);
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize mystery_card_2 (public owner: address, public token_remover: u64) {
        // Decrements `account[owner]` by `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount - token_remover);
    }


//=============================================================================================
//========================== 5TH MYSTERY CARD #5 =============================================
//============================= ROB ME(STEALER TOKEN)============= DANGEROUS ==================
transition mystery_card_5 (mc5: Buildings,  ROB_ME: u64) -> (Buildings, u64){
        //token remover :( ooopss
        //=================================================================
        //======= MAPPING REQUIRED HERE to retrieve BALANCE[ADDRESS] ======
        //==================== account[BALANCE] ===========================
        //=================================================================
        // ROB_ME = ROB_ME;

        let owner_amt: u64 = mc5.amount + ROB_ME;
        // Compute the owner as `owner`.
        assert_eq(self.caller, mc5.owner);

        let mystery : Buildings = Buildings{
            owner: mc5.owner,
            amount:  owner_amt,
            buildings: mc5.buildings,
        };
             return (mystery, ROB_ME)  then finalize (self.caller, ROB_ME);
    }
        //================= MAPPING BALANCES TO ACCOUNT OWNER/TO_ADDRESS =======================
        finalize mystery_card_5 (public owner: address, public ROB_ME: u64) {
        // Decrements `account[owner]` by `amount`.
        let owner_amount: u64 = Mapping::get_or_use(account, owner, 0u64);
        Mapping::set(account, owner, owner_amount - ROB_ME);
    }

//=============================================================================================
//=========================== MINTED TOKEN TRANSFER_PUBLIC_2_PRIVATE ==========================
//=============================================================================================
// The function `transfer_public_to_private` turns a specified token amount from `account` into a token record for the specified receiver.
    // This function preserves privacy for the receiver's record, however it publicly reveals the caller and the specified token amount.
    transition transfer_public_to_private(public to_address: address, public amount: u64) -> Buildings {
        // Produces a token record for the token receiver.
        let transferred: Buildings = Buildings {
            owner: to_address,
            amount: amount,
            buildings: 1u64,
        };

        // Output the receiver's record.
        // Decrement the token amount of the caller publicly.
        return transferred then finalize(self.caller, amount);
    }

    finalize transfer_public_to_private(public sender: address, public amount: u64) {
        // Decrements `account[sender]` by `amount`.
        // If `account[sender]` does not exist, it will be created.
        // If `account[sender] - amount` underflows, `transfer_public_to_private` is reverted.
        let current_amount: u64 = Mapping::get_or_use(account, sender, 0u64);
        Mapping::set(account, sender, current_amount - amount);
    }



//==============================================================================================
//=================================== REWARD FOR TO_ADDRESS ====================================
//==============================================================================================
transition mint_reward(to_address: address, amount: u64) -> Reward {
       //set number of supplys
       let supply_reward: u64 = 1500000000u64;
       // Compute the hash of the token owner.
       let hash: address = BHP256::hash_to_address(to_address);

        // Produce a token record for the specified receiver.
        let receive_reward: Reward = Reward {
            supply: (supply_reward - amount),
            owner: to_address,
            amount: amount,
        };

        // Output the sender's change record and the receiver's record.
        return receive_reward then finalize(self.caller, amount, supply_reward);
    }

        finalize mint_reward(public to_address: address, public supply: u64, public amount: u64) {
        // Decrements `account[sender]` by `amount`.
        // If `get_reward[to_address]` does not exist, it will be created.
        // If `get_reward[to_address] + amount` underflows, `transfer_public_to_private` is reverted.
        let tot_remaining_supply: u64 = Mapping::get_or_use(remaining_supply, supply, 0u64);
        Mapping::set(remaining_supply, supply, tot_remaining_supply - amount);

        let reward_amount: u64 = Mapping::get_or_use(get_reward, to_address, 0u64);
        Mapping::set(get_reward, to_address, reward_amount + amount);
    }

}
