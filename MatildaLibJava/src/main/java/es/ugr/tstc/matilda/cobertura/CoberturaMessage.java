/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
/** *********************
 * ABNF Description:
 *
 * mCobertura= mRequest / mReply / mNotify
 * mRequest= mJoinRequest / mLeave
 * mJoinRequest= “JOIN” SP username SP characterDescription SP room ENDOL
 * mLeave = “LEAVE” SP username SP room ENDOL
 * mReply = mJoinResponse
 * mJoinResponse = mJoinResponseOk / mJoinResponseErr
 * mJoinResponseOk = “JOINED” SP “OK” SP playerID ENDOL
 * mJoinResponseErr = ????
 * mNotify = mStartMatch / mMovementUpdate / mFinishMatch / mPlayerList
 * mStartMatch = “START” SP room SP playerSpawnList ENDOL
 * mMovementUpdate= “UPDATE” SP playerID SP coordinateOrigin SP 							coordinateDestination ENDOL
 * mFinishMatch = “FINISH” SP playerRankList ENDOL
 * mPlayerList = “PLAYERS” SP characterDescription *(DEL characterDescription)  ENDOL
 *
 * coordinateOrigin = coordinate
 * coordinateDestination = coordinate
 *
 * coordinate = numero ”.” numero DEL2 numero ”.” numero DEL2 numero ”.” numero
 *
 * characterDescription=username DEL meshName DEL bodyTextureName DEL hairTextureName DEL playerID
 *
 * playerID = letter number
 * username=alfanumerico 3*20
 * room=alfanumerico 3*20
 *
 * number =1*5 digit
 * digit = “0”/”1”/”2”/”3”/”4”/”5”/”6”/”7”/”8”/”9”
 * letter= “a”-”z” / “A”-”Z”
 *
 * playerSpawnList = playerPosition *(DEL playerPosition)
 * playerPosition = playerID DEL2 coordinate
 *
 * SP= “ “
 * DEL= “;”
 * DEL2 = “:”
 * ENDOL= %0x0A
 **************** */
package es.ugr.tstc.matilda.cobertura;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 *
 * @author jjramos@ugr.es
 */
class CoberturaMessage {

    private String username;
    private String room;

    private String characterMesh;
    private String mainTexture;
    private String hairTexure;

    private String playerID;

    private List<CharacterDescription> playersList;

    static final String ENDOL = "\n";
    static final String DEL = ";";
    static final String DEL2 = ":";
    static final String SP = " ";
    private float[] coordinateOrigin;
    private float[] coordinateDestination;
    private Map<String, float[]> spawnPlayersList;

  

    // Type identifier
    enum TYPES {
        mInvalidMessage, mJoinRequest, mLeave, mStartMatch, mMovementUpdate, mFinishMatch,
        mJoinResponse, mPlayerList
    };
    TYPES type = TYPES.mInvalidMessage;

    // Codes of the command part of the message.
    static final String mJoinRequestCommand = "JOIN";
    static final String mLeaveCommand = "LEAVE";
    static final String mStartMatchCommand = "START";
    static final String mMovementUpdateCommand = "UPDATE";
    static final String mFinishMatchCommand = "FINISH";
    static final String mJoinResponseCommand = "JOINED";
    static final String mPlayerListCommand = "PLAYERS";

    // Error codes in response:
    enum CODES {
        OKCode, ErrorCode
    };

    static final String OKCodeString = "OK";
    static final String ErrorCodeString = "ERR";

    CODES code;

    /**
     *
     */
    CoberturaMessage() {
        type = TYPES.mInvalidMessage;
    }

    /**
     *
     * @param mensajeCrudo
     */
    CoberturaMessage(String mensajeCrudo) {
        parsePacket(mensajeCrudo);
    }

    /**
     * Creates a message from a String:
     *
     * @param mensajeCrudo String which represents a line of an ASCII message
     * @return 0 if there was no error, -1 otherwise.
     */
    public int parsePacket(String mensajeCrudo) {
        int error = 0;

        String[] campos = mensajeCrudo.split(SP);

        if (campos[0].compareTo(mJoinRequestCommand) == 0) {
            type = TYPES.mJoinRequest;
            error = parseMJoinRequest(campos);
        } else if (campos[0].compareTo(mLeaveCommand) == 0) {
            type = TYPES.mLeave;
            error = parseMLeave(campos);
        } else if (campos[0].compareTo(mStartMatchCommand) == 0) {
            type = TYPES.mStartMatch;
            error = parseMStartMatch(campos);
        } else if (campos[0].compareTo(mMovementUpdateCommand) == 0) {
            type = TYPES.mMovementUpdate;
            error = parseMMovementUpdate(campos);
        } else if (campos[0].compareTo(mFinishMatchCommand) == 0) {
            type = TYPES.mFinishMatch;
            error = parseMFinishMatch(campos);
        } else if (campos[0].compareTo(mJoinResponseCommand) == 0) {
            type = TYPES.mJoinResponse;
            error = parseMJoinResponse(campos);
        } else if (campos[0].compareTo(mPlayerListCommand) == 0) {
            type = TYPES.mPlayerList;
            error = parseMPlayerList(campos);
        }

        return error;
    }

    /**
     *
     * @param campos
     * @return
     */
    private int parseMJoinRequest(String[] campos) {
        int error = 0;

        if (campos.length == 4) {

            username = campos[1];
            room = campos[3];

            CharacterDescription characterDescription = parseCharacterDescription(campos[2]);
            hairTexure = characterDescription.getHairTexure();
            mainTexture = characterDescription.getMainTexture();
            characterMesh = characterDescription.getCharacterMesh();
            playerID = characterDescription.getPlayerID();

        } else {
            error = -1;
        }
        return error;
    }

    /**
     *
     * @param characterDescription
     * @return
     */
    private CharacterDescription parseCharacterDescription(String characterDescriptionString) {
        int error = 0;
        CharacterDescription characterDescription = null;

        String[] desc = characterDescriptionString.split(DEL);

        if (desc.length == 5) {

            characterDescription = new CharacterDescription();
            characterDescription.setName(desc[0]);
            characterDescription.setCharacterMesh(desc[1]);
            characterDescription.setMainTexture(desc[2]);
            characterDescription.setHairTexure(desc[3]);
            characterDescription.setPlayerID(desc[4]);

        } else {
            error = -1;
        }

        return characterDescription;
    }
    
    /**
     * 
     * @return 
     */
      public CharacterDescription getCharacterDescription() {
        CharacterDescription characterDescription=new CharacterDescription(username,characterMesh,mainTexture,hairTexure,playerID);
        return characterDescription;
    }

    /**
     *
     * @param campos
     * @return
     */
    private int parseMLeave(String[] campos) {
        int error = 0;

        if (campos.length == 3) {
            username = campos[1];
            room = campos[2];
        } else {
            error = -1;
        }

        return error;
    }

    /**
     *
     * @param campos
     * @return
     */
    private int parseMStartMatch(String[] campos) {
        int error = 0;

        if (campos.length == 3) {
            room = campos[1];
            spawnPlayersList = parseSpawnPlayerList(campos[2]);
        } else {
            error = -1;
        }

        return error;
    }

    private Map<String, float[]> parseSpawnPlayerList(String campo) {
        Map<String, float[]> spawnPlayerList_ = new HashMap<String, float[]>();

        String[] playerInfo = campo.split(DEL);

        for (String player : playerInfo) {
            String[] playerPosition_ = player.split(DEL2);
            String playerID_ = playerPosition_[0];
            float[] coordinate_ = parseCoordinate(playerPosition_[1]);

            spawnPlayerList_.put(playerID_, coordinate_);
        }

        return spawnPlayerList_;
    }

    /**
     *
     * @param playerList
     * @return
     */
    private List<CharacterDescription> parsePlayerList(String playerList) {
        int error = 0;

        String[] campos = playerList.split(DEL);

        ArrayList<CharacterDescription> playersList_ = new ArrayList<CharacterDescription>();

        for (String player : campos) {
            CharacterDescription characterDescription = null;
            characterDescription = parseCharacterDescription(player);

            playersList_.add(characterDescription);
        }

        return playersList_;
    }

    /**
     *
     * mMovementUpdate= “UPDATE” SP playerID SP coordinateOrigin SP
     * coordinateDestination ENDOL
     *
     * @param campos
     * @return
     */
    private int parseMMovementUpdate(String[] campos) {
        int error = 0;

        if (campos.length == 3) {
            playerID = campos[1];
            coordinateOrigin = parseCoordinate(campos[2]);
            coordinateDestination = parseCoordinate(campos[3]);

        } else {
            error = -1;
        }

        return error;
    }

    /**
     * coordinate = numero ”.” numero DEL2 numero ”.” numero DEL2 numero ”.”
     * numero
     *
     * @param coordinate_
     * @return
     */
    private float[] parseCoordinate(String coordinate_) {
        float[] vector = new float[3];

        String[] numbers = coordinate_.split(DEL2);

        for (int i = 0; i < numbers.length; i++) {
            vector[i] = Float.parseFloat(numbers[i]);
        }

        return vector;
    }

    /**
     *
     * mFinishMatch = “FINISH” SP playerRankList ENDOL
     *
     * to finish...
     *
     * @param campos
     * @return
     */
    private int parseMFinishMatch(String[] campos) {
        int error = 0;

        // To finish...
        return error;
    }

    /**
     *
     * mJoinResponseOk = “JOINED” SP “OK” SP playerID ENDOL mJoinResponseErr =
     * ????
     *
     * @param campos
     * @return
     */
    private int parseMJoinResponse(String[] campos) {
        int error = 0;

        if (campos[1].compareTo(OKCodeString) == 0) {
            playerID = campos[2];
            code = CODES.OKCode;
        } else {
            code = CODES.ErrorCode;
        }

        return error;
    }

    /**
     *
     * @param campos
     * @return
     */
    private int parseMPlayerList(String[] campos) {
        int error = 0;

        if (campos.length == 2) {
            playersList = parsePlayerList(campos[1]);
        } else {
            error = -1;
        }

        return error;
    }

    /**
     * ************
     *
     */
    /**
     *
     * @param username
     * @param characterDescription
     * @param room
     */
    void buildMJoinRequest(String username, CharacterDescription characterDescription, String room) {
        type = TYPES.mJoinRequest;
        this.username = username;
        hairTexure = characterDescription.getHairTexure();
        characterMesh = characterDescription.getCharacterMesh();
        mainTexture = characterDescription.getMainTexture();
        this.room = room;

    }

    /**
     *
     * @param username
     * @param room
     */
    void buildMLeave(String username, String room) {
        type = TYPES.mLeave;
        this.username = username;
        this.room = room;
    }

    /**
     *
     * @param room
     * @param spawnPlayersList
     */
    void buildMStartMatch(String room, Map<String, float[]> spawnPlayersList) {
        type = TYPES.mStartMatch;
        this.room = room;
        this.spawnPlayersList = spawnPlayersList;
    }

    /**
     *
     * @param playerID
     * @param coordinateOrigin
     * @param coordinateDestination
     */
    void buildMMovementUpdate(String playerID, float[] coordinateOrigin, float[] coordinateDestination) {
        type = TYPES.mMovementUpdate;
        this.playerID = playerID;
        this.coordinateOrigin = coordinateOrigin;
        this.coordinateDestination = coordinateDestination;
    }

    /**
     * !!!! Todo!!!!!!!
     */
    void buildMFinishMatch() {
        type = TYPES.mFinishMatch;
    }

    /**
     *
     * @param playerID
     * @param error
     */
    void buildMJoinResponse(String playerID, CODES error) {

        type = TYPES.mJoinResponse;

        this.playerID = playerID;
        code = error;
    }

    /**
     *
     * @param playersList
     */
    void buildMPlayerList(List<CharacterDescription> playersList) {
        type = TYPES.mPlayerList;
        this.playersList = playersList;
    }

    /**
     * *********************************************
     *
     * @return
     */
    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getRoom() {
        return room;
    }

    public void setRoom(String room) {
        this.room = room;
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

    public String getPlayerID() {
        return playerID;
    }

    public void setPlayerID(String playerID) {
        this.playerID = playerID;
    }

    public List<CharacterDescription> getPlayersList() {
        return playersList;
    }

    public void setPlayersList(List<CharacterDescription> playersList) {
        this.playersList = playersList;
    }

    public float[] getCoordinateOrigin() {
        return coordinateOrigin;
    }

    public void setCoordinateOrigin(float[] coordinateOrigin) {
        this.coordinateOrigin = coordinateOrigin;
    }

    public float[] getCoordinateDestination() {
        return coordinateDestination;
    }

    public void setCoordinateDestination(float[] coordinateDestination) {
        this.coordinateDestination = coordinateDestination;
    }

    public Map<String, float[]> getSpawnPlayersList() {
        return spawnPlayersList;
    }

    public void setSpawnPlayersList(Map<String, float[]> spawnPlayersList) {
        this.spawnPlayersList = spawnPlayersList;
    }

    public TYPES getType() {
        return type;
    }

    public void setType(TYPES type) {
        this.type = type;
    }

    public CODES getCode() {
        return code;
    }

    public void setCode(CODES code) {
        this.code = code;
    }

    /**
     *
     * @return
     */
    String serialize() {
        String packet = null;

        switch (type) {
            case mFinishMatch:
                packet = serializeMFinishMatch();
                break;
            case mJoinRequest:
                packet = serializeMJoinRequest();
                break;
            case mJoinResponse:
                packet = serializeMJoinResponse();
                break;
            case mLeave:
                packet = serializeMLeave();
                break;
            case mMovementUpdate:
                packet = serializeMMovementUpdate();
                break;
            case mPlayerList:
                packet = serializeMPlayerList();
                break;
            case mStartMatch:
                packet = serializeMStartMatch();
                break;
            case mInvalidMessage:
            default:
                packet = null;
                break;

        }
        return packet + ENDOL;
    }

    private String serializeMFinishMatch() {
        return mFinishMatchCommand + SP + "foo-list";
    }

    /**
     * mJoinRequest= “JOIN” SP username SP characterDescription SP room ENDOL
     *
     * @return
     */
    private String serializeMJoinRequest() {
        return mJoinRequestCommand + SP + username + SP + serializeCharacterDescription(username, characterMesh, mainTexture, hairTexure, username) + SP + room;
    }

    private String serializeCharacterDescription(String username, String characterMesh, String mainTexture, String hairTexure, String username0) {
        return username + DEL + characterMesh + DEL + mainTexture + DEL + hairTexure + DEL + playerID;
    }

    /**
     *
     * mJoinResponseOk = “JOINED” SP “OK” SP playerID ENDOL mJoinResponseErr =
     * ????
     *
     * @return
     */
    private String serializeMJoinResponse() {
        return mJoinResponseCommand + SP + ((code == CODES.OKCode) ? (OKCodeString + SP + playerID) : ErrorCodeString);
    }

    /**
     * mLeave = “LEAVE” SP username SP room ENDOL
     *
     * @return
     */
    private String serializeMLeave() {
        return mLeaveCommand + SP + username + SP + room;
    }

    /**
     * mMovementUpdate= “UPDATE” SP playerID SP coordinateOrigin SP
     * coordinateDestination ENDOL
     *
     * @return
     */
    private String serializeMMovementUpdate() {
        return mMovementUpdateCommand + SP + playerID + SP + serializeCoordinate(coordinateOrigin) + SP + serializeCoordinate(coordinateDestination);
    }

    /**
     * coordinate = numero ”.” numero DEL2 numero ”.” numero DEL2 numero ”.”
     * numero
     *
     * @param coordinate
     * @return
     */
    private String serializeCoordinate(float[] coordinate) {
        return coordinate[0] + DEL2 + coordinate[1] + DEL2 + coordinate[2];
    }

    /**
     * mPlayerList = “PLAYERS” SP characterDescription *(DEL
     * characterDescription)
     *
     * @return
     */
    private String serializeMPlayerList() {
        return mPlayerListCommand + SP + serializeCharacterDescriptionList(playersList);
    }

    private String serializeCharacterDescriptionList(List<CharacterDescription> playersList) {
        String list = "";

        CharacterDescription player = playersList.get(0);
        list = serializeCharacterDescription(player.getName(), player.getCharacterMesh(), player.getMainTexture(), player.getHairTexure(), player.getPlayerID());

        for (int i = 1; i < playersList.size(); i++) {
            player = playersList.get(i);
            list = list + DEL + serializeCharacterDescription(player.getName(), player.getCharacterMesh(), player.getMainTexture(), player.getHairTexure(), player.getPlayerID());
        }

        return list;
    }

    /**
     * mStartMatch = “START” SP room SP playerSpawnList ENDOL
     *
     * @return
     */
    private String serializeMStartMatch() {
        return mStartMatchCommand + SP + room + SP + serializePlayerSpawnList(spawnPlayersList);
    }

    /**
     * playerSpawnList = playerPosition *(DEL playerPosition) playerPosition =
     * playerID DEL2 coordinate
     *
     * @param spawnPlayersList
     * @return
     */
    private String serializePlayerSpawnList(Map<String, float[]> spawnPlayersList) {
        String serial = "";

        Set<String> playersIDlist = spawnPlayersList.keySet();

        int i = 0;
        for (String playerId : playersIDlist) {
            float[] coordinate = spawnPlayersList.get(playerId);
            serial = serial + playerId + DEL2 + serializeCoordinate(coordinate);

            i++;
            if (i < playersIDlist.size()) {
                serial = serial + DEL;
            }
        }

        return serial;
    }

}
