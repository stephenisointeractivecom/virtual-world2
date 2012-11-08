package com.isointeractive.staralign;

import java.util.List;

import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.entities.variables.SFSUserVariable;
import com.smartfoxserver.v2.exceptions.SFSVariableException;
import com.smartfoxserver.v2.extensions.BaseClientRequestHandler;

public class PositionHandler extends BaseClientRequestHandler {

	@Override
	public void handleClientRequest(User player, ISFSObject params) {
		double xPos = params.getDouble("x");
		double yPos = params.getDouble("y");
		
		//trace(player.getName() + " - " + xPos + ", "+ yPos);
		
		ISFSObject rtn = new SFSObject();
		rtn.putUtfString("p", player.getName());
		rtn.putDouble("x", xPos);
		rtn.putDouble("y", yPos);
		
		try{
			player.setVariable(new SFSUserVariable("saX", xPos));
			player.setVariable(new SFSUserVariable("saY", yPos));
		}catch(SFSVariableException ex){
			trace("Exception thrown setting user variable: " + ex.getMessage());
		}
		
		StarAlignCore pExt = (StarAlignCore)getParentExtension();
		
		List<User> pList = pExt.getParentRoom().getUserList();
		pList.remove(player);
		
		pExt.getParentRoom().getUserList();
		pExt.send("pu", rtn, pList);
	}

}
