pragma solidity ^0.5.16;

contract KYC {

    address kycadmin;
    
    constructor() public {
        kycadmin = msg.sender;
    }
    
    modifier onlyadmin(){
        require(msg.sender==kycadmin);
        _;
    }

    struct Bank {
        string name;
        uint256 kycCount;
        address Address;
        bool isAllowedToAddCustomer;
        bool kycPrivilege;
    }

    struct Customer {
        string name;
        string data;
        address validatedBank;
        bool kycStatus;
    }

    mapping(address => Bank) banks; //  Mapping a bank's address to the Bank
    mapping(string => Customer) customersInfo;  //  Mapping a customer's username to the Customer     

    
    
    /********************************************************************************************************************
     *
     *  Name        :   addNewBank
     *  Description :   This function is used by the admin to add a new bank to the KYC Contract. This function can be called by admin only.
     *  Parameters  :
     *      param  {string} bankName :  The name of the bank/organisation.
     *      param  {address} add :  The  unique Ethereum address of the bank/organisation
     *
     *******************************************************************************************************************/
    function addNewBank(string memory bankName,address add) public onlyadmin {
        require(!areBothStringSame(banks[add].name,bankName), "A Bank already exists with same name");
        banks[add] = Bank(bankName,0,add,true,true);
    }

    /********************************************************************************************************************
     *
     *  Name        :   blockBankFromKYC
     *  Description :   This function can only be used by the admin to change the status of kyc Permission of any of the
     *                  banks at any point of the time.
     *  Parameters  :
     *      @param  {address} add :  The  unique Ethereum address of the bank/organisation
     *
     *******************************************************************************************************************/
    function blockBankFromKYC(address add) public onlyadmin returns(int) {
        require(banks[add].Address != address(0), "Bank not found");
        banks[add].kycPrivilege = false;
        return 1;
    }
    
    
    /********************************************************************************************************************
     *
     *  Name        :   allowBankFromKYC
     *  Description :   This function can only be used by the admin to change the status of kyc Permission of any of the
     *                  banks at any point of the time.
     *  Parameters  :
     *      @param  {address} add :  The  unique Ethereum address of the bank/organisation
     *
     *******************************************************************************************************************/
    function allowBankFromKYC(address add) public onlyadmin returns(int) {
        require(banks[add].Address != address(0), "Bank not found");
        banks[add].kycPrivilege = true;
        return 1;
    }

    /********************************************************************************************************************
     *
     *  Name        :   blockBankFromAddingNewCustomers
     *  Description :   This function can only be used by the admin to block any bank to add any new customer.
     *  Parameters  :
     *      @param  {address} add :  The  unique Ethereum address of the bank/organisation
     *
     *******************************************************************************************************************/
    function blockBankFromAddingNewCustomers(address add) public onlyadmin returns(int){
        require(banks[add].Address != address(0), "Bank not found");
        require(banks[add].isAllowedToAddCustomer, "Requested Bank is already blocked to add new customers");
        banks[add].isAllowedToAddCustomer = false;
        return 1;
    }
    
       /********************************************************************************************************************
     *
     *  Name        :   allowBankFromAddingNewCustomers
     *  Description :   This function can only be used by the admin to allow any bank to add any new customer.
     *  Parameters  :
     *      @param  {address} add :  The  unique Ethereum address of the bank/organisation
     *
     *******************************************************************************************************************/
    function allowBankFromAddingNewCustomers(address add) public onlyadmin returns(int){
        require(banks[add].Address != address(0), "Bank not found");
        require(!banks[add].isAllowedToAddCustomer, "Requested Bank is already allowed to add new customers");
        banks[add].isAllowedToAddCustomer = true;
        return 1;
    }
    
    /********************************************************************************************************************
     *
     *  Name        :   addNewCustomerToBank
     *  Description :   This function will add a customer to the customer list. If IsAllowed is false then don't process
     *                  the request.
     *  Parameters  :
     *      param {string} custName :  The name of the customer
     *      param {string} custData :  The hash of the customer data as a string.
     *
     *******************************************************************************************************************/
    function addNewCustomerToBank(string memory custName,string memory custData) public {
        require(banks[msg.sender].isAllowedToAddCustomer, "Requested Bank is blocked to add new customers");
        require(customersInfo[custName].validatedBank == address(0), "Requested Customer already exists");

        customersInfo[custName] = Customer(custName, custData,msg.sender,false);
    }

    /********************************************************************************************************************
     *
     *  Name        :   viewCustomerData
     *  Description :   This function allows a bank to view details of a customer.
     *  Parameters  :
     *      @param  {string} custName :  The name of the customer
     *
     *******************************************************************************************************************/

    function viewCustomerData(string memory custName) public view returns(string memory,bool){
        require(customersInfo[custName].validatedBank != address(0), "Requested Customer not found");
        return (customersInfo[custName].data,customersInfo[custName].kycStatus);
    }


    /********************************************************************************************************************
     *
     *  Name        :   addNewCustomerRequestForKYC
     *  Description :   This function is used to add the KYC request to the requests list. If kycPermission is set to false bank won’t be allowed to add requests for any customer.
     *  Parameters  :
     *      @param  {string} custName :  The name of the customer for whom KYC is to be done
     *
     *******************************************************************************************************************/
    function addNewCustomerRequestForKYC(string memory custName) public returns(int){
        require(banks[msg.sender].kycPrivilege, "Requested Bank does'nt have KYC Privilege");
        customersInfo[custName].kycStatus= true;
        banks[msg.sender].kycCount++;

        return 1;
    }

    /********************************************************************************************************************
     *
     *  Name        :   getCustomerKycStatus
     *  Description :   This function is used to fetch customer kyc status from the smart contract. If true then the customer
     *                  is verified.
     *  Parameters  :
     *      @param  {string} custName :  The name of the customer
     *
     *******************************************************************************************************************/

    function getCustomerKycStatus(string memory custName) public view returns(bool){
        require(customersInfo[custName].validatedBank != address(0), "Requested Customer not found");
        return (customersInfo[custName].kycStatus);
    }

    /********************************************************************************************************************
     *
     *  Name        :   areBothStringSame
     *  Description :   This is an internal function is verify equality of strings
     *  Parameters  :
     *      @param {string} a :   1st string
     *      @param  {string} b :   2nd string
     *
     *******************************************************************************************************************/

    function areBothStringSame(string memory a, string memory b) private pure returns (bool) {
        if(bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return keccak256(bytes(a)) == keccak256(bytes(b));
        }
    }
}