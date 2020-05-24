/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ugr.tstc.matilda.cobertura;

/**
 *
 * @author jjramos@ugr.es
 */
public class CharacterDescription {

    private String playerID;
    private String name;
    private String characterMesh;
    private String mainTexture;
    private String hairTexure;

    CharacterDescription(String username, String characterMesh, String mainTexture, String hairTexure, String playerID) {
        this.name=username;
        this.characterMesh=characterMesh;
        this.mainTexture=mainTexture;
        this.hairTexure=hairTexure;
        this.playerID=playerID;
    }

    CharacterDescription() {
    
    }

    public String getPlayerID() {
        return playerID;
    }

    public void setPlayerID(String playerID) {
        this.playerID = playerID;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getCharacterMesh() {
        return characterMesh;
    }

    public void setCharacterMesh(String characterMesh) {
        this.characterMesh = characterMesh;
    }

    public String getMainTexture() {
        return mainTexture;
    }

    public void setMainTexture(String mainTexture) {
        this.mainTexture = mainTexture;
    }

    public String getHairTexure() {
        return hairTexure;
    }

    public void setHairTexure(String hairTexure) {
        this.hairTexure = hairTexure;
    }

}
