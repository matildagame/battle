/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ugr.tstc.matilda.matildalib;

import es.ugr.tstc.matilda.registrationservice.RegistrationClient;
import es.ugr.tstc.matilda.transport.TransportEntity;
import es.ugr.tstc.matilda.registrationservice.RegistrationMessage;

/**
 *
 * @author matilda
 */
public class RegistrationManager {

    static final int StatusConnected=0;
    static final int StatusUndefined=-1;
    static final int StatusInvalidUser=1;
    static final int StatusServerUnreachable=2;
    
    // Internal comunnication state:
    int estado=StatusUndefined;
    
    private String name;
    private String password;
    private String token=null;
    
    // Trasnportation Layer Entity:
    TransportEntity transportEntity=null;
    
    // internal errors:
    static final int NoError=0;
    
    int error=NoError;
    
    RegistrationClient registrationClient=null;

    public RegistrationManager() {
    }

    int getStatus() {
        return estado;
    }

    String getToken() {
        return token;
    }

    void register(String name, String password) {
        this.name=name;
        this.password=password;
        
        sendRegistrationRequest(name,password);
        
        // Let's wait for the response:
        RegistrationMessage message=receiveMessage();
        
        if (message==null){
            estado=StatusInvalidUser;
        } else {
            if(message.getType()==RegistrationMessage.RegisterResponseType){
                if(message.getErrorField()==RegistrationMessage.ERROR.NoError){
                    token=message.getToken();
                } else {
                    token=null;
                }
            }
        }
    }

    private void sendRegistrationRequest(String name, String password) {
        int error=0;
        
        RegistrationMessage message=new RegistrationMessage(name,password);
        error = transportEntity.send(message.serialize());
    }

    void init(String registrationServerAddress, int registrationServerPort) {
        transportEntity=new TransportEntity(
                TransportEntity.ClientMode,
                registrationServerAddress, 
                registrationServerPort);
        if(transportEntity.getStatus()==TransportEntity.STATE.Connected){
            estado=StatusConnected;
        }
        
        // registrationClient=new RegistrationClient(transportEntity);
    }

    private RegistrationMessage receiveMessage() {
        RegistrationMessage message=null;
        
        byte [] packet=transportEntity.receivePacket();
        message=new RegistrationMessage(packet);
        
        return message;
    }

  
    
}
