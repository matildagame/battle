/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ugr.tstc.matilda.matildalib;

import java.io.BufferedReader;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author matilda
 */
class Mensaje {



   
   

    
    enum ERROR {noError};
    enum MessageType {invalidMessage,libraryConnectionRequest,libraryChatMessage,
	libraryConnectionReply,
	rpcSpawn,rpcUpdatePosition,rpcUpdateValue,
	serverConnectionReply, serverConnectionRequest,
        rpcRegister
    }
    
    // Campos del mensaje:
    MessageType tipo=MessageType.invalidMessage;
    String aplicacion="unknown";
    String remitente="";
    String mensaje="";
    
    String nombre="";
    String objeto="";

    private String contrasenia="+";
    private String direccionServidorRegistro="locahost";
    private int puertoServidorRegistro=9999;
    
    String servidor="localhost";
    int puerto=9090;
    
    Mensaje(){
        
    }

    Mensaje(BufferedReader in) {
        String mensajeBruto=leerMensaje(in);
        
        if (interpretaMensaje(mensajeBruto)!=ERROR.noError){
            tipo=MessageType.invalidMessage;
        }
    }
    
    private ERROR interpretaMensaje(String mensajeBruto) {
        ERROR error=ERROR.noError;
        
        String[] campos = mensajeBruto.split(":");
        
        // Si es la inicialziación:
        if(campos[0].compareTo("HI")==0){
            tipo=MessageType.libraryConnectionRequest;
            aplicacion=campos[2];
        } else if(campos[0].compareTo("MSG")==0){
            tipo=MessageType.libraryChatMessage;
            remitente=campos[1];
            mensaje=campos[2];        
        } else if(campos[0].compareTo("Spawn")==0){
         tipo=MessageType.rpcSpawn;
            objeto=campos[1];
            nombre=campos[2]; 
        }else if(campos[0].compareTo("CONNECT")==0){
            tipo=MessageType.serverConnectionRequest;
            servidor=campos[1];
            puerto=Integer.parseInt(campos[2]); 
        } else if(campos[0].compareTo("REG")==0){
            tipo=MessageType.rpcRegister;
            nombre=campos[1];
            contrasenia=campos[2];
            direccionServidorRegistro=campos[3];
            puertoServidorRegistro=Integer.parseInt(campos[4]); 
        }
        
        return error;
    }

    private String leerMensaje(BufferedReader in) {
        String mensaje=null;
        
        try {
            // suponemos mensajes orientados a líneas de texto:
            mensaje=in.readLine();
            System.out.println("> Raw: \""+mensaje+"\"");
            
        } catch (IOException ex) {
            Logger.getLogger(Mensaje.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        return mensaje;
    }
    
     String getMessage() {
        return mensaje;
    }
     
    MessageType getType(){
        return tipo;
    }
    
    String getApplication() {
        return aplicacion;
    }

    public String getPassword(){
        return contrasenia;
    }
    
    public String getName() {
        return nombre;
    }

    public void setName(String nombre) {
        this.nombre = nombre;
    }

    public String getObject() {
        return objeto;
    }

    public void setObject(String objeto) {
        this.objeto = objeto;
    }

    public String getRegistrationServerAddress(){
        return direccionServidorRegistro;
    }
    
    public int getRegistrationServerPort(){
        return puertoServidorRegistro;
    }
}
