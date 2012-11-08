package com.isointeractive.staralign;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;

import org.w3c.dom.Document;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;

import com.smartfoxserver.v2.SmartFoxServer;
import com.smartfoxserver.v2.entities.User;
import com.smartfoxserver.v2.entities.data.ISFSObject;
import com.smartfoxserver.v2.entities.data.SFSObject;
import com.smartfoxserver.v2.entities.variables.SFSRoomVariable;
import com.smartfoxserver.v2.extensions.SFSExtension;

public class StarAlignCore extends SFSExtension {
	
    // Keeps a reference to the task execution
    ScheduledFuture<?> taskHandle;
	
	private class ConstellationInterval implements Runnable{
        private int runningCycles = 0;
        private StarAlignCore pExt = StarAlignCore.instance();
         
        public void run(){
        	
        	Constellation c = pExt.getConstellation();
        	
        	if(c.restartTime == runningCycles){
        		c.startConstellation(runningCycles);
        	}else if(c.endTime == runningCycles){
        		ISFSObject rtn = new SFSObject();
        		List<User> pList = pExt.getParentRoom().getUserList();
        		rtn.putUtfString("id", c.id);
        		rtn.putUtfString("c",  c.color);
    			pExt.send("ce", rtn, pList);
        	}
        	
        	for(int i = 0; i < c.activeStars.size(); i++){
        		if(runningCycles == c.activeStars.get(i).activateTime){
        			//trace("1");
        			//trace(c.activeStars.get(i).toString());
        			//trace(c.activeStars.get(i).associatedStone.toString());
        			double stoneX = c.activeStars.get(i).associatedStone.xPos;
        			//trace("STAR ACTIVATED on Moonstone at " + stoneX);
        			List<User> pList = pExt.getParentRoom().getUserList();
        			for(int j = 0; j < pList.size(); j++){
        				User p = pList.get(j);
        				if(p.containsVariable("saX")){
	        				double ux = p.getVariable("saX").getDoubleValue();
	        				if(ux > stoneX-50 && ux < stoneX+50){
	        	        		ISFSObject rtn = new SFSObject();
	
	        	        		rtn.putInt("#", c.activeStars.get(i).id);
	        	    			pExt.send("as", rtn, pList);
	        	    			c.activeStars.get(i).hit = true;
	        	    			break;
	        				}
        				}
        			}

        			c.activeStars.remove(i);
        			i--;
        		}
        	}
        	
        	Star currStar = c.getNextStar();
        	//trace(currStar.dispatchTime + " vs. " + runningCycles);
        	while(currStar != null && currStar.dispatchTime == runningCycles){
        		//trace("DISPATCH NEW STAR " + runningCycles);
	    		List<User> pList = pExt.getParentRoom().getUserList();
            	
	    		List<MoonStone> stones = StarAlignCore.moonStones();
	    		List<Integer> inactiveList = new ArrayList<Integer>();
	    		
	    		for(int i = 0; i < stones.size(); i++){
	    			if(stones.get(i).isActivated()){
	    				if(runningCycles >= stones.get(i).deactivateTime){
	    					stones.get(i).deactivate();
	    					inactiveList.add(i);
	    				}
	    			}else{
	    				inactiveList.add(i);
	    			}
	    		}
	    		
	    		int stoneNum = -1;
	    		
	    		if(inactiveList.size() > 0){
	    			int rand = (int)(Math.random()*inactiveList.size());
	    			stoneNum = inactiveList.get(rand);
	    			stones.get(stoneNum).activate(runningCycles);
	    			//trace("Activating " + stoneNum);
	    		}
	    		
	    		if(stoneNum >= 0){
	    			currStar.associatedStone = stones.get(stoneNum);
	    		
		    		if(pList.size() > 0){
		    			
		        		ISFSObject rtn = new SFSObject();
		        		rtn.putDouble("y", currStar.yPosition);
		        		
		        		rtn.putUtfString("c", c.color);
		        		rtn.putInt("st", stoneNum);
		        		rtn.putInt("sp", pExt.getParentRoom().getVariable("starSpeed").getIntValue());
		        		rtn.putInt("#", c.currentStar);
		    			pExt.send("ns", rtn, pList);
		    		}
	    		}
	    		
	    		c.incrementStar();
	    		currStar = c.getNextStar();
        	}
        	
        	runningCycles++;
        	
        }
        
    }
	
	private class MoonStone{
		private Boolean activated;
		private double xPos;
		private int deactivateTime;
		
		public MoonStone(double x){
			activated = false;
			xPos = x;
		}
		
		public Boolean isActivated(){
			return activated;
		}
		
		public void activate(int time){
			activated = true;
			deactivateTime = time + (StarAlignCore.instance().getParentRoom().getVariable("starSpeed").getIntValue()*1000/50) + 1;
		}
		
		public void deactivate(){
			activated = false;
		}
	}
	
	private class Star{
		public double timeDelay;
		public double yPosition;
		public int dispatchTime;
		public int activateTime;
		public int id;
		public MoonStone associatedStone;
		public Boolean hit;
		
		public Star(double t, double y){
			timeDelay = t;
			yPosition = y;
			hit = false;
		}
	}
	
	private class Constellation{
		public List<Star> starList;
		public List<Star> activeStars;
		private int currentStar;
		private int startTime;
		private int restartTime;
		private int endTime;
		private String color;
		private String id;
		
		public Constellation(){
			starList = new ArrayList<Star>();
			activeStars = new ArrayList<Star>();
			restartTime = 0;
		}
		
		public void startConstellation(int s){
			getNewConstellation();
			startTime = s;
			int constTime = StarAlignCore.instance().getParentRoom().getVariable("constellationSpeed").getIntValue();
			int intervalTotal = constTime*1000/50;
			for(int i = 0; i < starList.size(); i++){
				starList.get(i).id = i;
				starList.get(i).dispatchTime = (int)(starList.get(i).timeDelay*intervalTotal+startTime);
				starList.get(i).activateTime = (int)(starList.get(i).dispatchTime + StarAlignCore.instance().getParentRoom().getVariable("starSpeed").getIntValue()*1000*.5/50);
				//trace("Time delay: " + starList.get(i).timeDelay);
				//trace("Dispatch star at: " + starList.get(i).dispatchTime);
			}
			int starSpeedInterval = StarAlignCore.instance().getParentRoom().getVariable("starSpeed").getIntValue()*1000/50;
			endTime = startTime + intervalTotal + starSpeedInterval;
			restartTime = endTime + starSpeedInterval;
		}
		
		public void getNewConstellation(){
			currentStar = 0;
			starList.clear();
			activeStars.clear();
			 
			  try {
		 
				File fXmlFile = new File("xml/Constellations.xml");
				DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
				DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
				Document doc = dBuilder.parse(fXmlFile);
				doc.getDocumentElement().normalize();
				
				NodeList constList = doc.getElementsByTagName("constellation");
				Node randConst = constList.item((int)(Math.random()*constList.getLength()));
				
				id = randConst.getAttributes().getNamedItem("id").getNodeValue();
				color = randConst.getAttributes().getNamedItem("color").getNodeValue();
		 
				//trace("Root element :" + doc.getDocumentElement().getNodeName());
				NodeList nList = randConst.getChildNodes();
				//trace("Star count: " + nList.getLength());
				for(int i=0; i < nList.getLength(); i++){
					if(nList.item(i).getNodeName() == "star"){
						Star s = new Star(Double.parseDouble(nList.item(i).getAttributes().getNamedItem("tDelay").getNodeValue()), Double.parseDouble(nList.item(i).getAttributes().getNamedItem("yPos").getNodeValue()));
						starList.add(s);
					}
				}

			  } catch (Exception e) {
				e.printStackTrace();
			  }
		}
		
		public Star getNextStar(){
			if(currentStar < starList.size()){
				return starList.get(currentStar);
			}
			return null;
		}
		
		public void incrementStar(){
			activeStars.add(starList.get(currentStar));
			currentStar++;
		}

	}
	
	private static StarAlignCore saInstance;
	private static List<MoonStone> moonStoneList;
	private static Constellation constellation;

	@Override
	public void init() {
		
		trace("Star Align Extension initialized.");
		this.addRequestHandler("pos", PositionHandler.class);
		
		saInstance = this;
		
        SmartFoxServer sfs = SmartFoxServer.getInstance();
        
        try{
        	this.getParentRoom().setVariable(new SFSRoomVariable("constellationSpeed", 30));
        	this.getParentRoom().setVariable(new SFSRoomVariable("starSpeed", 10));
        }catch(Exception ex){
        	trace("Exception thrown during room variable set: " + ex.getStackTrace());
        }
        
        moonStoneList = new ArrayList<MoonStone>();
        moonStoneList.add(new MoonStone(960.25));
        moonStoneList.add(new MoonStone(720.25));
        moonStoneList.add(new MoonStone(412.25));
        moonStoneList.add(new MoonStone(119.25));
        moonStoneList.add(new MoonStone(515.25));
        moonStoneList.add(new MoonStone(840.25));
        moonStoneList.add(new MoonStone(210.25));
        moonStoneList.add(new MoonStone(310.25));
        moonStoneList.add(new MoonStone(615.25));
        moonStoneList.add(new MoonStone(28.25));
    	
    	constellation = new Constellation();
        
        // Schedule the task to run every second, with no initial delay
        taskHandle = sfs.getTaskScheduler().scheduleAtFixedRate(new ConstellationInterval(), 0, 50, TimeUnit.MILLISECONDS);
     
	}
	
	public static StarAlignCore instance(){
		return saInstance;
	}
	
	public static List<MoonStone> moonStones(){
		return moonStoneList;
	}
	
	public Constellation getConstellation(){
		return constellation;
	}

}
