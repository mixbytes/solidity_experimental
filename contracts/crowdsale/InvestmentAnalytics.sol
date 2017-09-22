pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/ownership/Ownable.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';



contract AnalyticProxy {

    function AnalyticProxy() {
        m_analytics = InvestmentAnalytics(msg.sender);
    }

    function() payable {
        m_analytics.investedBy.value(msg.value)(msg.sender);
    }

    InvestmentAnalytics m_analytics;
}


contract InvestmentAnalytics is Ownable {
    using SafeMath for uint256;

    function InvestmentAnalytics(){
    }

    function createMoreSlices(uint number) external onlyOwner returns (uint) {
        uint slicesCreated;
        for (uint i = 0; i < number; i++) {
            /*
             * ~150k of gas per slice,
             * using gas price = 4Gwei 2k slices will cost ~1.2 ETH.
             */
            address analyticSlice = new AnalyticProxy();
            m_validAnalyticSlices[analyticSlice] = true;
            m_analyticSlices.push(analyticSlice);
            slicesCreated++;
        }
        return slicesCreated;
    }

    function investedBy(address investor) external payable {
        address analyticSlice = msg.sender;
        if (m_validAnalyticSlices[analyticSlice]) {
            uint value = msg.value;
            m_investmentsByAnalyticSlice[analyticSlice] = m_investmentsByAnalyticSlice[analyticSlice].add(value);
            onInvested(investor, value);
        } else {
            onInvested(msg.sender, msg.value);
        }
    }

    /// @dev callback
    function onInvested(address investor, uint value) internal {
    }

    function slicesCount() external constant returns (uint) {
        return m_analyticSlices.length;
    }

    mapping(address => uint256) public m_investmentsByAnalyticSlice;
    mapping(address => bool) m_validAnalyticSlices;

    address[] public m_analyticSlices;
}
