//The Idea behind this contract is basically to allow countries to Mine/Buy resources from countries if based on the no of tokens they have
//For instance if The Netherlands want to mine gold in south africa they will have to buy tokens to mine a certain amount of gold otherwise they will not be allowed to do so
//Contries can also trade Tokens so if the usa has excess OilTokens they can trade them with the netherlands for south african gold tokens
//and vice versa
//Allot of functions are yet to be added
pragma solidity ^0.4.21;
contract ColonisationInterface
{
//returns the total no of available licenses for countries to purchase inorder to colonise a certain country 
function TotalColonisationTokens () constant returns (uint256 total);
// returns the totatal licenses bought by a specific country  with the address address_owner reason for the constant keyword the balance is not modified within this fucntion
//its a way of making a promise 
function GetBalanceOfCountry (address owner) constant returns (uint256 balance);
//transfers a certain amount of license tokens to a specific countries address
function Transfer(address to,uint256 amount) returns (bool success);
//transfers a certain amount of tokens from a specific account to a another account like trading
function TransferFrom(address from,address to,uint256 amount) returns (bool success);
//allows spender to withdraw from your account multiple times upto the maximum account available in your account
//If the function is called again it overwrites the current allowance with the amount
function Approve(address spender,uint256 amount) returns (bool success);
//returns the total amount the spender is still allowed to withdraw from the country
function Allowance (address country, address spender) constant returns (uint256 remaining); 
//Buy token
function BuyTokens(address buyer,uint256 amount) payable returns (bool success);
//Logs country name
event LogTokenNameDeclared (string indexed name);
//triggered when license tokens are being transfered
event TransferEvent(address indexed from , address indexed to , uint256 amount);
//Triggered whenever the approve function is called 
event Approval(address indexed country,address indexed spender,uint256 amount);
}
//Used for keeping track of how much ether is being moved around
contract TokenRecipt
{
    uint256 public Balance;
    event RecievedEther(address from,uint256 amount);
    event NewEtherBalance(address from,uint amount,uint256 newbalance);
    function () payable
    {
        RecievedEther(msg.sender,msg.value);
        Balance += msg.value;//didnt know i could += XD new version of the compiler here we just adding the amount of ether we recieveing to our current balance
        NewEtherBalance(msg.sender,msg.value,Balance);
    }
}
contract CountriesInterFace 
{
//registers a country name
function RegisterCountry(bytes32 name,bytes32 continent,bytes32 pass) returns (bool success);
//Get Resource
function GetResource (address id) constant returns(bytes32 name,uint256 count,bytes32 OriginCountry);
}

contract LimitedColonisationLicenseToken is ColonisationInterface,TokenRecipt
{

    string public constant symbol ="Fixed";
    string public Name =""; //The User will specify what to name each token
    uint8 public constant decimals =18;
    uint256 UnitPrice=1;
    uint256 TotalSupply =200; //assuming theres only 200 countries in the world XD
    address owner; //owner of the each account
    mapping (address => uint256) Balances; //Balances for each country
    //each country approves the transfer of a certain amount of tokens from their account to another 
    //first address is the countries address i.e. the owner the second address is the country whos was given
    //permission to withdraw a certain amount of tokens
    //the allowed variable is the maximum allowed amount for that particular country
    mapping (address => mapping (address => uint256)) Allowed;
    //Maps an address to a specific countries name
    mapping(address => string) CountriesName;
   //Only the owner can execute this function if anyone else tries to do so it will throw an exception
    //Todo: increase the supply amount
   
    modifier TokenName (string name,uint256 Price)
    {
    if (msg.sender != owner)
    {
        revert();
    }
    else
    {
        Name=name;
        UnitPrice=Price;//set the price of each Token
    }
    _;
    }
    //Constructor
    function LimitedColonisationLicenseToken()
    {
        owner = msg.sender;
        Balances[owner]=TotalSupply;
    }
    // returns the total supply of tokens available
    function TotalColonisationTokens() constant returns (uint256 totalsupply)
    {
        totalsupply=TotalSupply;
    }
    //gets a specific countries Broadcasting license token balance
    function GetBalanceOfCountry(address country) constant returns (uint256 balance)
    {
        balance = Balances[country];
    }
    function Transfer (address to,uint256 amount) returns (bool success)
    {
        if(Balances[msg.sender]>=amount && amount >0)
        {
            Balances[to] += amount;
            Balances[msg.sender] -= amount;
             TransferEvent(owner,to,amount);
            success =true;
        }
        else
        {
        success= false;
        }
    }
     // Send x amount of tokens from address from to address to
    // The transferFrom method is used for a withdraw workflow, allowing contracts to send
    // tokens on your behalf, for example to "deposit" to a contract address and/or to charge
    // fees in sub-currencies; the command should fail unless the from account has
    // deliberately authorized the sender of the message via some mechanism; we propose
    // these standardized APIs for approval:
    //Allowed[from][msg.sender] checks to see if the maximum amount that was Allowed for the specifi contract is greater than the amount thats being transfered
    //Balances[to] +amount > Balances[to]  ensures that the amount being added to the to account is going to result in an increase in their balance
    function TransferFrom(address from,address to, uint256 amount) returns (bool success)
    {
     if(Balances[from] >=amount && Allowed[from][msg.sender]>=amount && amount >0 &&Balances[to] +amount > Balances[to])
     {
    Balances[to] += amount;
    Balances[from] -= amount;
    Allowed[from][msg.sender] -=amount;
    Balances[to] += amount;
    TransferEvent(from,to,amount);
    success =true;
     }        
     else 
     {
       success=false;
     }
    }
    //Allows spender i.e. country from my account multiple times up to the maximum value thats in my account 
    //if the function is called again it overwrites  the current allowed amount with the new amount 
    function Approve(address spender , uint256 amount) returns (bool success)
    {
        Allowed[msg.sender][spender] =amount;
        Approval(msg.sender,spender,amount);
        success =true;
    }
    //gets the maximum amount allowed for the spender 
    function Allowance(address country ,address spender) constant returns  (uint256 amount)
    {
        amount = Allowed[country][spender];
    }
    // Buy a certain no of tokens marked as payable because we are transfering actual tokens to an account
    // allows a function to receive ether while being called
    function BuyTokens(address buyer,uint256 amount) payable returns (bool success)
    {
        if(TotalSupply > 0 && TotalSupply-amount >=0)
        {
          TotalSupply= TotalSupply-amount;
          Balances[buyer]=amount;
          msg.sender.transfer(msg.value);
          success=true;
        }
        else
        {
         success=false;
        }
    }
}
    contract CountryContract is CountriesInterFace,LimitedColonisationLicenseToken
    {
     struct Country
     {
     bytes32 Name;//Name of country
     bytes32 Continent;////Which continent it belongs to
     uint256 Rank;// Position its in in comparison to other countries interms of resources
     address MainResource;//The main Resource that can be mined
     address Id;
     bool Active;//indicates whether a record exists or not true if exists false if not
     //Resources that can be mined
     bytes32 Password;//Users Password
     mapping(address => Resource) Resources;
     
    }   
    struct Resource
    {
        bytes32 Name;
        uint256 Count;
        address Id;
        bytes32 OriginCountry;
        
    }
    //Keeps track of the countries that have resgistered on the system
    mapping(address => Country) Countries;
    uint256 CountriesCount;//keeps track of the no of countries that have registerd 
    address owner;//address of the person exectuing the contract
    mapping(address=>Resource) Resources;//keeps track of the resources belonging to the registered countries
    function  CountryContract()
    {
        CountriesCount=0;
    }
    function RegisterCountry(bytes32 name,bytes32 continent,bytes32 pass) returns (bool success)
    {
        if(!Countries[msg.sender].Active){
        Country memory country=Country(name,continent,0,0,msg.sender,true,pass);  
        CountriesCount =CountriesCount+1;//increase coutries by one
        success=true;
        Countries[msg.sender]=country;
        }
        else{
            success=false;
        }
    }
    //Ensures that only the owner of the contract is allowed to add new resources for a country
    modifier AddResource(bytes32 name,address resourceId, uint256 estimateCounttobemined,address origin)
    {
    if(msg.sender != owner)
    {
     revert();
    }
    else 
    {
        bytes32 Name = Countries[origin].Name;
       Resource memory res =Resource(name,estimateCounttobemined,resourceId,Name); //Create new resource
       Countries[origin].Resources[resourceId]=res; // add resource to list
       
    }
        _;
    }
    //Returns the requested resources details
   function GetResource (address id) constant returns(bytes32 name,uint256 count, bytes32 origin)
   {
     Resource storage res = Resources[id];
     name=res.Name;
     count=res.Count;
   }

    
    //Removes a Resource from the countries resources
    //Only the owner of the resource can remove the resource from their list of minable resources
    modifier RemoveResource(address resourceId)
    {
    if(msg.sender != owner)
    {
        revert();
    }
    else 
    {
       delete Resources[resourceId]; // remove resource from list
    }
    _;
  }
  
}

