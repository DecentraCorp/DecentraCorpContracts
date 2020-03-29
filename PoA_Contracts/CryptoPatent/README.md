# The CryptoPatent Blockchain Contract Set

The CryptoPatent Blockchain Contract set is written in solidity

These contracts are in a early beta-phase

The CryptoPatent Blockchain is a contractabstracted Blockchain protocol
capable of controlling the validator set of a Proof of Authority Network based of Parity's
Authority Round Engine.

The Contracts that make up the CryptoPatent Blockchain start at the IdeaBlock Contract which contains all
global variables and structs for the CryptoPatent Contract set as well as the logic for Idea proposals and
IdeaBlock generation

Following the IdeaBlockLogic contract is the RepBlockLogic and UseBlockLogic contracts which handle Replication and Use
block generation respectively.
 Ending out the contract set is the CryptoPatentBlockchain contract itself which handles IdeaBlockUpgrade logic as well as
 a few other miscellaneous functions.

 for more information on the CryptoPatent Blockchain please visit our documentation found
  @ https://github.com/DecentraCorp/Documentation/blob/master/CryptoPatentWhitePaper.md
