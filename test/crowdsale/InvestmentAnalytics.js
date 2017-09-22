'use strict';

const l = console.log;

const InvestmentAnalytics = artifacts.require("./crowdsale/InvestmentAnalytics.sol");
const AnalyticProxy = artifacts.require("AnalyticProxy");


contract('InvestmentAnalytics', function(accounts) {

    it("test ", async function() {
        const instance = await InvestmentAnalytics.new({from: accounts[0]});
        await instance.createMoreSlices(10, {from: accounts[0]});

        assert.equal(await instance.slicesCount(), 10);
        const slice1 = await instance.m_analyticSlices(1);
        const slice5 = await instance.m_analyticSlices(5);

        await AnalyticProxy.at(slice1).sendTransaction({from: accounts[1], value: web3.toWei(20, 'finney')});
        await AnalyticProxy.at(slice5).sendTransaction({from: accounts[2], value: web3.toWei(50, 'finney')});
        await AnalyticProxy.at(slice1).sendTransaction({from: accounts[3], value: web3.toWei(20, 'finney')});

        assert.equal(await instance.m_investmentsByAnalyticSlice(slice1), web3.toWei(40, 'finney'));
        assert.equal(await instance.m_investmentsByAnalyticSlice(slice5), web3.toWei(50, 'finney'));
    });
});
