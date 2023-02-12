#########################################################
###############---ALEO IMPORT MODULE---##################
#########################################################

#first check if aleo slingshot is installed...
aleo_address = ""
#check if address is from `aleo`
aleo_wallet_test = "aleo1"
aleo_wallet_num = 63

#addr2 address
addr2 = 'aleo1vtuct9867t6aldkqxuec87wesrpltk0vv4qul56wpugnn5gx05rsew3z4u'
addr2_bal = 10000

#ERROR BASED ON ALEO
ERROR_1 = 'Hey, this is not an official aleo address...'
ERROR_2 = 'Hey, aleo wallet address is 63-bit character. wallet address ~ incompplete'
ERROR_3 = 'Hey, you dont have enough cash...'
ERROR_4 = 'Hey, you dont have any building yet...'

#CHOOSE A MENU
menu_option = {1: '1. Get Money', 2: '2. Check Balance/Record',3: '3. Buy House', 4: '4. Rent House', 5: '5. Sale House', 6: '6. exit'}
aleo_bal = 0

#counting number of transactions
tx = 1


#################################################
###########--- ALL BUILDINGS FUNC ---############
#################################################
#owner building
white_building = 1500
white_building_rent = 150
#addr2 building
black_building = 1000
black_building_rent = 100


#random_rent -> a dice roll from {0-6}
dice_owner = 3    #owner dice number
dice_addr2 = 5    #addr2 dice number



#############################################
################---BANK---###################
#############################################
BANK_VAULT = 1000000 #Bank supply token
BANK_BORROW = 10000 #addr2 borrows 10000 token
BANK_INTEREST = 600 #interest deducted
BANK_BORROW_LIMIT = 0 #initial set @ zero


