/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ugr.tstc.matilda.registrationservice;

import java.io.UnsupportedEncodingException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author matilda
 */
public class RegistrationMessage {

    private String name=null;
    private String password=null;
    private String token=null;

    static final String RegisterRequestString="REGISTER";
    static final String RegisterResponseString="REGISTER";
    
    public static final int InvalidMessage=-1;
    public static final int RegisterRequestType=0;
    public static final int RegisterResponseType=1;

    RegistrationMessage(int type, ERROR error) {
        this.type=type;
        this.error=error;
    }

    RegistrationMessage(int type, ERROR error, String token) {
        this.type=type;
        this.error=error;
        this.token=token;        
    }
    
    public enum ERROR {NoError,UserUnknown};
    private ERROR error;
    
    public ERROR getErrorField(){
        return error;
    }
    
    // type of message:
    int type=InvalidMessage;
    
    public RegistrationMessage(String name, String password) {
        this.name=name;
        this.password=password;
    }

    public RegistrationMessage(byte[] packet) {
        parsePacketBytes(packet);
    }
    
    public String serialize(){
        String linea="";
        
        switch(type){
            case InvalidMessage:
                break;
            case RegisterResponseType:
                linea=RegisterResponseString+" "+((error!=ERROR.NoError)?("Ok "+token):"Unk");
                break;
        }
        
        return linea;
    }

    private void parsePacketBytes(byte[] packet) {
        try {
            
            String line=new String(packet,"ASCII");
            
            String[] fields = line.split(" ");
            
            if(fields[0].compareTo(RegisterRequestString)==0){
                type=RegisterRequestType;
                if(fields.length>1)
                    name=fields[1];
                if(fields.length>2)
                    password=fields[2];        
            }
            
            
        } catch (UnsupportedEncodingException ex) {
            Logger.getLogger(RegistrationMessage.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
    
    public int getType(){
        return type;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }
}
