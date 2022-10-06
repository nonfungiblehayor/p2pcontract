// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// contract address = "0xe85C0e9E7aDe175aE552D524148F59aDD4aa3880'
contract p2p {
    address payable[] public  p2pMerchants;

    mapping(address => uint) public p2pRate;

    enum locations {
        Nigeria,
        Ghana
    }

    mapping (address => locations) public Kyc;
    mapping (address => uint) public holders;

    function fromNigeria(address user) external {
       locations Nigerians = locations.Nigeria;
       Kyc[user] = Nigerians;
    }

     function fromGhana(address _user) external {
       locations Ghanians = locations.Ghana;
       Kyc[_user] = Ghanians;
    }    

    address payable marketAdmin;
    uint private exchangeToken;

    function setAdmin(address payable _ad, uint exToken) external {
        marketAdmin = _ad;
        exchangeToken = exToken;
    }

    modifier onlyAdmin() {
        require(msg.sender == marketAdmin);
        _;
    }

    function addp2pMerchant(address payable merch, uint rate) external onlyAdmin {
        require(Kyc[merch] != locations.Nigeria);
        p2pMerchants.push(merch);
        p2pRate[merch] = rate;
    }

    function transcact(uint fee, address _reciver, uint amount) external payable {
        fee = msg.value;
        require(fee == amount);
        require(Kyc[_reciver] == locations.Ghana);
        exchangeToken = exchangeToken - amount;
        holders[_reciver] = amount;
    }

    event log(uint indexed amnt);

    function transactWithP2p(uint _fee,uint amount, uint rate) external payable {
        _fee = msg.value;
        require(_fee == amount);   
        require(Kyc[msg.sender] == locations.Nigeria);
        for(uint i = 0; i < p2pMerchants.length; i++) {
            require(p2pRate[p2pMerchants[i]] == rate);
            p2pMerchants[i].transfer(_fee);
        }
        emit log(amount);    
    }

    function sendWithp2p(uint _amount, address buyer) external {
        require(Kyc[msg.sender] == locations.Ghana);
        require(holders[msg.sender] >= _amount);
        holders[msg.sender] = holders[msg.sender] - _amount;
        holders[buyer] = _amount;
        emit log(_amount);
    }

    
}
