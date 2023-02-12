program functions.aleo{

    record Dummy_Record_1 {
        owner: address,
        amt: u32,
        gates: u64,
    }
    

    //Build a monopoly game of two players a, b address
    transition test(owner: address,amt: u32) -> Dummy_Record_1{
        return Dummy_Record_1{
            owner: owner,
            gates: 0u64,
            amt: amt,
        };
    }

    //===============================================================
    //Function to select the color attribute of building for owner
    //===============================================================
    function owner_color(amt: u32) -> u32{
        amt  = 1500u32;
        let white_color: bool = true;
        let black_color: bool = false;
        let white_amt: u32 = 1500u32;
        let black_amt: u32 = 1000u32;
        let owner_amt: u32 = amt;

        
        if(owner_amt == white_amt && white_color){
            return white_amt;
        }else{
            return black_amt;
        }
    }



    //================================================================
    //Function to select the color attribute of building for address2
    //================================================================
    function addr2_color(amt: u32) -> u32{
        amt  = 1000u32;
        let white_color: bool = true;
        let black_color: bool = false;
        let white_amt: u32 = 1500u32;
        let black_amt: u32 = 1000u32;
        let buy_amt: u32 = amt;

        
        if(buy_amt != white_amt && white_color){
            return black_amt;
        }else{
            return white_amt;
        }
    }






    //=====================================================================
    //Function to get rent payment for the owner 
    //=====================================================================
    function give_owner_rent(amt: u32) -> u32{
        amt  = 150u32;
        let white_color: bool = true;
        let black_color: bool = false;
        //rent amount
        let rent_amt: u32 = amt;
        let no_amt: u32 = 0u32;

        
        if(rent_amt != no_amt && white_color){
            return rent_amt;
        }else{
            return no_amt;
        }
    }


    //=====================================================================
    //Function to get rent payment for the addr2 
    //=====================================================================
    function give_addr2_rent(amt: u32) -> u32{
        amt  = 100u32;
        let white_color: bool = false;
        let black_color: bool = true;
        //rent amount
        let rent_amt: u32 = amt;
        let no_amt: u32 = 0u32;

        
        if(rent_amt != no_amt && black_color){
            return rent_amt;
        }else{
            return no_amt;
        }
    }






    //=============================================================================
    //Function to get sale building from owner to addr2 
    //=== owner bid up amount up to 15,000, but addr2 doesnt have up to that... ===
    //=== OPTION: Borrow from bank vault and top up
    //=============================================================================
    function sale_owner(amt: u32) -> u32{
        amt  = 15000u32;

        let white_color: bool = true;
        let black_color: bool = false;
        //rent amount
        let sale_amt: u32 = amt;
        let no_amt: u32 = 0u32;

        
        if(sale_amt != no_amt && white_color){
            return sale_amt;
        }else{
            return no_amt;
        }
    }


    //=============================================================================
    //Function to get sale building from addr2 to owner 
    //=== addr2 bid up amount up to 12,000, but owner doesnt have up to that or may have... ===
    //=== OPTION: Borrow from bank vault and top up
    //=============================================================================
    function sale_addr2(amt: u32) -> u32{
        amt  = 12000u32;
        let white_color: bool = false;
        let black_color: bool = true;
        //rent amount
        let sale_amt: u32 = amt;
        let no_amt: u32 = 0u32;

        
        if(sale_amt != no_amt && black_color){
            return sale_amt;
        }else{
            return no_amt;
        }
    }

}
