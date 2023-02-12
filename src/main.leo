//==============================================================================================================================
//==============================================================================================================================
//===============================================    ALEO MONOPOLY REBUILD   ===================================================
//======================================================  VER: 0.1.0. ==========================================================
//==============================================================================================================================
//This is the rebuild version of the Aleo-Monopoly-V0.2, now in this version, new attribute are added and new implementations
//New Attrbutes:
//- Building color (Black, White) implementation: owner picks white color, addr2 picks black color. white color is superior and
//                                                has more rewards than the black color...
//==============================================================================================================================
//- Import function Implementation: we have the purchase(buy), rent and sale functions to enable owner and addr2 to build up 
//                                  their interactions among themselves, both works simultaneously for now....
//==============================================================================================================================
//- amt: amt for every purchase, rent and sale are different in the Building color, as said white_color > black_color
//==============================================================================================================================

//We hope to input months into this program so that both the owner and addr2 will play around paying themselves for 12 months
//and also I will setup some disasters based on random number so a given address is chance to lose against another address
//Dont cheat my code haha, i will build up on PHP too to deploy this program there, have fun, ~ aleo team
//==============================================================================================================================
//=============================================     Powered By Leo Programming    ==============================================
import functions.leo;


program shib.aleo{

    record Buildings{
        owner : address,
        addr2 : address,
        gates: u64,
        amt : u32, 
        addr2_amt : u32,
        white_color: bool,
        black_color: bool,
    }

    record Bank{
        owner: address,
        receiver: address,
        gates: u64,
        bank_amt: u32,
        receiver_amt: u32,
        interest: u32,
    }

    
    //Build a monopoly game of two players owner(a), addr2(b) address
    transition main(owner: address, addr2: address, amt: u32, addr2_amt: u32, white_color: bool, black_color: bool) -> Buildings{
        return Buildings{
            owner: owner,
            addr2: addr2,
            gates: 0u64,
            amt: amt,
            addr2_amt: addr2_amt,
            white_color: white_color,
            black_color: black_color,
        };
    }

    //===========================================================================================
    //====================== OWNER PURCHASE (BUY) WHITE COLOR BUILDING ==========================
    //===========================================================================================
    transition monopoly_owner_buy (owner: address, addr2: address, amt: u32, addr2_amt: u32, white_color: bool, black_color: bool) -> Buildings{
        //set the owner amount based on the attribute rendered
        //white building -> 1,500 token - owner buys 
        //black building -> 1,000 token
        let color_attr_amt: u32 = amt - functions.leo/owner_color(amt);

        let white_color_set: bool = false;

        //setting the boolean attr to owner, if bought, set at `true, otherwise default @ `false`
        if (functions.leo/owner_color(amt) == 1500u32){
            white_color_set  = true;
        }else{
            white_color_set  = white_color;
        }

        let buy : Buildings = Buildings{
            owner: owner,
            addr2: addr2,
            gates: 0u64,
            amt:  color_attr_amt,
            addr2_amt: addr2_amt,
            white_color: white_color_set,
            black_color: black_color,
        };
        return buy;
    }


    
    //===========================================================================================
    //====================== ADDR2 PURCHASE (BUY) BLACK COLOR BUILDING ==========================
    //===========================================================================================
       transition monopoly_addr2_buy (owner: address, addr2: address, amt: u32, addr2_amt: u32, white_color: bool, black_color: bool) -> Buildings{
        let all_int: u32 = 123u32;
        let all_int2: u32 = ((all_int * all_int) / 10u32) % 10000u32;

        //set the buyer(addr2) amount based on the attribute rendered
        //white building -> 1,500 token 
        //black building -> 1,000 token - addr2 buys
        let color_attr_amt: u32 = addr2_amt - functions.leo/addr2_color(amt);

        let black_color_set: bool = false;

        //setting the boolean attr to owner, if bought, set at `true, otherwise default @ `false`
        if (functions.leo/addr2_color(amt) == 1000u32){
            black_color_set  = true;
        }else{
            black_color_set  = black_color;
        }

        let buy : Buildings = Buildings{
            owner: owner,
            addr2: addr2,
            gates: 0u64,
            amt:  amt , //addr2 pays owner 100 NGN for rent
            addr2_amt: color_attr_amt, //remaining balance of addr2
            white_color: white_color,
            black_color: black_color_set,

        };
        return buy;
    
    }


    
    //====================================================================================================
    //====================== OWNER RENT (GET_RENT -> +150) WHITE COLOR BUILDING ==========================
    //====================================================================================================
    //player a receive rent of 100 token per annum
    transition monopoly_owner_rent (owner: address, addr2: address, amt: u32, addr2_amt: u32, white_color: bool, black_color: bool) -> Buildings{
        //take rent from addr2 (-150u32)
        let take_rent: u32 = addr2_amt - functions.leo/give_owner_rent(amt);

        //give rent to owner (+150u32)
        let get_rent: u32 = amt + functions.leo/give_owner_rent(amt);
        
        //setting the bool to false by default
        let bool_get_rent: bool = false;

        if (functions.leo/give_owner_rent(amt)  == 150u32){
            bool_get_rent = true;
        }else{
            bool_get_rent = white_color;
        }

        let rent : Buildings = Buildings{
            owner: owner,
            addr2: addr2,
            gates: 0u64,
            amt: get_rent,
            addr2_amt: take_rent,
            white_color: bool_get_rent,
            black_color: black_color,
        };
        return rent;
    }


       
    //====================================================================================================
    //====================== ADDR2 RENT (GET_RENT -> +100) BLACK COLOR BUILDING ==========================
    //====================================================================================================
    transition monopoly_addr2_rent (owner: address, addr2: address, amt: u32, addr2_amt: u32, white_color: bool, black_color: bool) -> Buildings{
        //take rent from owner (-100u32)
        let take_rent: u32 = amt - functions.leo/give_addr2_rent(amt);

        //give rent to owner (+150u32)
        let get_rent: u32 = addr2_amt + functions.leo/give_addr2_rent(amt);
        
        //setting the bool to false by default
        let bool_get_rent: bool = false;

        if (functions.leo/give_addr2_rent(amt)  == 100u32){
            bool_get_rent = true;
        }else{
            bool_get_rent = black_color;
        }

        let rent : Buildings = Buildings{
            owner: owner,
            addr2: addr2,
            gates: 0u64,
            amt: take_rent,
            addr2_amt: get_rent,
            white_color: white_color,
            black_color: bool_get_rent,
        };
        return rent;
    }




transition monopoly_no_rent (owner: address, addr2: address, amt: u32, addr2_amt: u32, white_color: bool, black_color: bool) -> Buildings{
        //take rent from owner (-100u32)
        let owner_no_rent: u32 = amt - 150u32;

        //give rent to owner (+150u32)
        let addr2_no_rent: u32 = addr2_amt - 100u32;
        
        //setting the bool to false by default
        let bool_no_rent: bool = true;

        let rent : Buildings = Buildings{
            owner: owner,
            addr2: addr2,
            gates: 0u64,
            amt: owner_no_rent,
            addr2_amt: addr2_no_rent,
            white_color: bool_no_rent,
            black_color: bool_no_rent,
        };
        return rent;
    }





    transition monopoly_sale (owner: address, addr2: address, amt: u32, addr2_amt: u32, white_color: bool, black_color: bool) -> Buildings{
        //owner amt
        let sale_ownership: u32 = functions.leo/sale_owner(amt);

        //subtract bidding amount from `addr2`
        let new_addr2_amt: u32 = addr2_amt - sale_ownership;
        //add total amount to the owner 
        let new_owner_amt: u32 = amt + sale_ownership;

                //setting the bool to false by default
        let bool_get_sale: bool = false;

        if (functions.leo/sale_owner(amt)  == 15000u32){
            bool_get_sale = true;
        }else{
            bool_get_sale = white_color;
        }

        return Buildings{
            owner: owner,
            addr2: addr2,
            gates: 0u64,
            amt: new_owner_amt,
            addr2_amt: new_addr2_amt,
            white_color: bool_get_sale,
            black_color: black_color,
        };
    }



    //==========================================================================================
    //============= The receiver `addr2` has to borrow from the bank to ========================
    //=============== to pay the owner the remaining bal due ===================================
    
    transition monopoly_bank_borrow (owner: address, receiver: address, bank_amt: u32, receiver_amt: u32, interest: u32) -> Bank {
        let borrow_amt: u32 = 10000u32;

        //receiver amt
        let receiver_tot_amt: u32 = (receiver_amt + borrow_amt) - interest;

        let bank_borrow: Bank = Bank {
            owner: owner,
            receiver: receiver,
            gates: 0u64,
            bank_amt: bank_amt - borrow_amt,
            receiver_amt: receiver_tot_amt, //the bank takes its first interest that month
            interest: interest,
        };
        
        return bank_borrow;
    }
}
