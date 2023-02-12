######### A python program for testing #################
print("########################################")
print("##########!### ALEO-PYTHON #############")
print("########################################")

import aleo
import os
import random
import time

white_building_count = 0
black_building_count = 0

def aleo_sling():
    if os.system('slingshot'):
        print('slingshot is installed...')
    else:
        print('slingshot is not installed...')
        exit()

aleo_sling()
print('\n')

aleo_addr = input("Enter Aleo address: ")
print("Checking Address...")
time.sleep(2)
aleo.aleo_address += aleo_addr

#check if user aleo address is real
if(aleo.aleo_address[0:5] != aleo.aleo_wallet_test):
    print(aleo.ERROR_1)
    exit()
elif len(aleo.aleo_address) < aleo.aleo_wallet_num or len(aleo.aleo_address) > aleo.aleo_wallet_num:
    print(aleo.ERROR_2)
else:
    print(aleo.aleo_address)
    print(str(aleo.aleo_bal)+' token')

    #get ALEO-CREDIT
    get_aleo_cr = os.system('slingshot pour '+ aleo.aleo_address + ' 10000')


def print_menu():
    for key in aleo.menu_option.keys():
        print(key, '--', aleo.menu_option[key])

def option1():
    print("===== GET SOME MONEY =====")
    print("getting money...")
    time.sleep(2)
    print("processing...")
    time.sleep(4)
    print("confirmed tx..")
    time.sleep(1)
    aleo.aleo_bal += 10000
    aleo.tx += 1
    print('Hey '+aleo.aleo_address+ ' , '+str(aleo.aleo_bal) + ' has been added to your balance')

if __name__ == '__main__':
    while(True):
        print_menu()
        option = ''
        try:
            option = int(input('Enter your choice: '))
        except:
            print('Wrong input. Please enter a number...')

        #checking choice ~ test choice
        if option == 1:
            if aleo.tx > 1:
                print('sorry, you can only get 10000 token only once, test the program...')
            else:
                option1()
                ############################################################################
                #####################--CHECK FOR A WINNER---################################
                ############################################################################
                if aleo.aleo_bal <= 150:
                    time.sleep(3)
                    print("==== GAME OVER =====")
                    time.sleep(1)
                    print("Hey, Addr2 won the game... try next time!")
                    time.sleep(2)
                    print("==== THANKS FOR PLAYING ====")
                elif aleo.addr2_bal <= 150:
                    time.sleep(3)
                    print("==== GAME OVER =====")
                    time.sleep(1)
                    print("Hey, you won the game... Congratulations!")
                    time.sleep(2)
                    print("==== THANKS FOR PLAYING ====")
                else:
                    print('')

        elif option == 2:
            print("==== OWNER BALANCE TOTAL ====")
            print('address: ',aleo.aleo_address)
            print('balance: ',aleo.aleo_bal)
            print('building count: ', white_building_count)


            print("==== ADDR2 BALANCE TOTAL ====")
            print('address: ',aleo.addr2)
            print('balance: ',aleo.addr2_bal)
            print('building count: ',black_building_count)

        elif option == 3:
            print("==== BUY A HOUSE ====")
            if aleo.aleo_bal < aleo.white_building:
                print(aleo.ERROR_3)
            else:
                white_building_count += 1
                black_building_count += 1

                aleo.aleo_bal -= aleo.white_building
                aleo.addr2_bal -= aleo.black_building
                #owner purchased building
                os.system('slingshot execute shib.aleo monopoly_owner_buy ' + aleo.aleo_address + ' ' + aleo.addr2 + ' ' + str(aleo.aleo_bal) + 'u32 ' + str(aleo.addr2_bal) + 'u32 ' + 'false ' + 'false')
                #addr2 purchased building
                os.system('slingshot execute shib.aleo monopoly_addr2_buy ' + aleo.aleo_address + ' ' + aleo.addr2 + ' ' + str(aleo.aleo_bal) + 'u32 ' + str(aleo.addr2_bal) + 'u32 ' + 'false ' + 'false')
                time.sleep(2)
                print("===== OWNER PURCHASED BUILDING =====")
                print('address: ',aleo.aleo_address)
                print('balance: ',aleo.aleo_bal)
                print('building owned: ', white_building_count)
                time.sleep(3)
                print("===== ADDR2 PURCHASED BUILDING =====")
                print('address: ',aleo.addr2)
                print('balance: ',aleo.addr2_bal)
                print('building owned: ', black_building_count)

        elif option == 4:
            print("=== GET RENT ===")
            if white_building_count >= 1:
                time.sleep(3)
                print("Rolling dice...")
                time.sleep(4)
                random_num = random.randint(0,6)
                if random_num == aleo.dice_owner:
                    print("=== GET RENT => OWNER ===")
                    aleo.aleo_bal += aleo.white_building_rent
                    aleo.addr2_bal -= aleo.white_building_rent
                    #slingshot -> get rent (owner)
                    os.system('slingshot execute shib.aleo monopoly_owner_rent '+aleo.aleo_address+' '+aleo.addr2+' '+str(aleo.aleo_bal)+ 'u32 '+str(aleo.addr2_bal)+'u32 '+'false ' + 'false')
                    print("Congratulations!. you rolled "+str(aleo.dice_owner)+", and won a rent of 150 token from addr2 deposited in your balance.")
                elif random_num == aleo.dice_addr2:
                    print("=== GET RENT => ADDR2 ===")
                    aleo.aleo_bal -= aleo.black_building_rent
                    aleo.addr2_bal += aleo.black_building_rent
                    #slingshot -> get rent (addr2)
                    os.system('slingshot execute shib.aleo monopoly_addr2_rent '+aleo.aleo_address+' '+aleo.addr2+' '+str(aleo.aleo_bal)+ 'u32 '+str(aleo.addr2_bal)+'u32 '+'false ' + 'false')
                    print("unfortunately. you rolled "+str(aleo.dice_addr2)+", and lost a rent of 100 token deposited in addr2 balance.")
                else:
                    print("=== NO RENT => NULL ===")
                    aleo.aleo_bal -= aleo.white_building_rent
                    aleo.addr2_bal -= aleo.black_building_rent
                    #slingshot -> no rent (empty)
                    os.system('slingshot execute shib.aleo monopoly_no_rent '+aleo.aleo_address+' '+aleo.addr2+' '+str(aleo.aleo_bal)+ 'u32 '+str(aleo.addr2_bal)+'u32 '+'false ' + 'false')
                    print("unfortunately. you rolled "+str(random_num)+", and both you and addr2 lost a rent of 150 & 100 token respectively.")
            else:
                time.sleep(2)
                print("sorry owner, you dont have building yet...")

        elif option == 5:
            print("=== SALE OF BUILDING ===")
            OWNER_SALE = input("Do you want to sell your building: (y/n)")
            time.sleep(3)
            if white_building_count >= 1:
                if OWNER_SALE == 'y':
                    time.sleep(2)
                    print('Processing...')
                    if aleo.addr2_bal >= 12000:
                        white_building_count -= 1
                        black_building_count += 1
                        aleo.addr2_bal -= 12000
                        aleo.aleo_bal += 12000
                        time.sleep(3)
                        print("=== SALE VERIFIED ===")
                        os.system('slingshot execute shib.aleo monopoly_sale ' + aleo.aleo_address + ' ' + aleo.addr2 + ' ' + str(aleo.aleo_bal) + 'u32 ' + str(aleo.addr2_bal) + 'u32 ' + 'false ' + 'false')
                        print("Processing...")
                        time.sleep(2)
                        print("=== SALE COMPLETED AND RECORDED... ====")

                        #GAME OVER
                        print("==== GAME OVER ====")
                        print("checking winner...")
                        time.sleep(3)
                        print("Unfortunately, addr2 won the game ")
                    else:
                        aleo.BANK_BORROW_LIMIT += 1
                        if aleo.BANK_BORROW_LIMIT > 1:
                            time.sleep(1)
                            print("Sorry addr2, you can only borrow once...")
                        else:
                            #BORROW FROM BANK AUTOMATICALLY TO PURCHASE
                            INTEREST = aleo.BANK_INTEREST
                            #add money to addr2 to complete purchases
                            interest_addr2 = INTEREST

                            #Add borrow to aleo.addr2_bal
                            aleo.addr2_bal = (aleo.addr2_bal + aleo.BANK_BORROW) - interest_addr2

                            #reduce supply token from bank
                            aleo.BANK_VAULT -= aleo.BANK_BORROW
                            print("=== BANK BORROW ===")
                            os.system('slingshot execute shib.aleo monopoly_bank_borrow ' + aleo.aleo_address + ' ' + aleo.addr2 + ' ' + str(aleo.BANK_VAULT) + 'u32 ' + str(aleo.addr2_bal) + 'u32 ' + str(INTEREST)+ 'u32')
                            print("Processing...")
                            time.sleep(2)
                            print("=== BANK BORROW COMPLETED ===")

                else:
                    print_menu()

            else:
                print(aleo.ERROR_4)

        elif option == 6:
            exit()

        else:
            print('Invalid option. Please enter a number between 1..')



