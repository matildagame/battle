/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ugr.tstc.matilda.cobertura;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 *
 * @author matilda
 */
public class CoberturaServer {

    String room;
    Map<String,String> userDatabase;
    Map<String,CharacterDescription> playersList;
    Map<String,float[]> playersSpawnPositionList;
    
    List<float[]> availableSpawnPointsList;
    
    CoberturaProtocolServer coberturaProtocolServer;
    
    void init(){
        playersList=new HashMap<String,CharacterDescription>();
        playersSpawnPositionList=new HashMap<String,float[]>();
        userDatabase=new HashMap<String,String>();
        
        initUserDatabase();
        initPlayersSpawnPositionList();
        
    }
    
    boolean existeUsuario(String username) {
        return (userDatabase.get(username)!=null);
    }

    boolean existeHabitacion(String room) {
        return (this.room.compareTo(room)==0);
    }

    String generatePlayerID(String username, String room) {
        return username+";"+room+";"+(Math.random()*50000);
    }

    String generatePlayerID(String username, CharacterDescription characterDescription, String room) {
        return username+";"+room+";"+(Math.random()*50000);
    }

    int addPlayer(String playerID, CharacterDescription characterDescription) {
        int error=0;
        
        if(playersList.get(playerID)==null){
            
        playersList.put(playerID, characterDescription);
        } else {
            error=1;
        }
      
        return error;
    }

    void removePlayer(String username, String room) {
        String playerID=userDatabase.get(username);
        playersList.remove(playerID);
        userDatabase.remove(username);
        
        notifyPlayerListChange();
        
    }

    List<CharacterDescription> getPlayerList() {
        List<CharacterDescription> list=new ArrayList<CharacterDescription>();
        
        for(CharacterDescription c:playersList.values()){
            list.add(c);
        }
        
        return list;
    }

    Map<String, float[]> getSpawnPlayerList() {
        return playersSpawnPositionList;
    }

    String getRoom() {
        return room;
    }

    private Map<String, String> initUserDatabase() {
        return userDatabase;
    }

    private Map<String, float[]> initPlayersSpawnPositionList() {
        return playersSpawnPositionList;
    }

    private void notifyPlayerListChange() {
        coberturaProtocolServer.notifyPlayerList(playersList);
    }

    void setRoom(String room) {
        this.room=room;
    }
}
