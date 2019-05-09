pragma solidity ^0.5.0;

contract TilesChain {
  string tileState;

  event OnTileMapStateUpdate(string state);

  function SetTileMapState(string memory _tileState) public {
    tileState = _tileState;
    emit OnTileMapStateUpdate(tileState);
  }

  function GetTileMapState() public view returns(string memory) {
    return tileState;
  }
}
