/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package es.ugr.tstc.matilda.matildalib;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author matilda
 */
public class MatildaLibClient {
    
    int libPort=9998;

           BufferedReader in=null;
        PrintWriter out=null;

    private void sendConnectionReplyRefused(int error) {
        out.println("CONNECT:"+error);
    }

    private void sendConnectionReplyOk() {
        out.println("CONNECT:Ok");
    }
    
    enum Estados {inicial, inicializado};
    
    Estados estado=Estados.inicial;
    
    // to be assigned by the library user:
    ConnectionManager connectionManager=null;
    GameObjectManager gameObjectManager=null;
    ChatManager chatManager=null;
    
    public void setConnectionManager(ConnectionManager cm){
        connectionManager=cm;
    }

    public GameObjectManager getGameObjectManager() {
        return gameObjectManager;
    }

    public void setGameObjectManager(GameObjectManager gameObjectManager) {
        this.gameObjectManager = gameObjectManager;
    }

    public ChatManager getChatManager() {
        return chatManager;
    }

    public void setChatManager(ChatManager chatManager) {
        this.chatManager = chatManager;
    }
    
    
    
   

    public MatildaLibClient(int libPort) {
      this.libPort=libPort;
    }
    
    public int init(){
        int error=0;
        
          ServerSocket serverSocket;
        try {
            serverSocket = new ServerSocket(libPort);
        
            Socket socket = serverSocket.accept();
    
            crearProcesador(socket);
            
           
            
            serverSocket.close();
        } catch (IOException ex) {
            Logger.getLogger(MatildaLibClient.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        return error;
    }

    /**
     * It processes the Matlib.gd Peer.
     * @param socket 
     */
    private void crearProcesador(Socket socket) {

        boolean salir=false;
        int error=0;
                    
        try {

            in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            out=new PrintWriter(socket.getOutputStream(),true);
            
            // Let's read messages form Matilda.gd:
            do {
                Mensaje mensaje=new Mensaje(in);
                
                System.out.print("Recibido mensaje Tipo: "+mensaje.getType());
                
                switch(estado){
                    case inicial:
                        if (mensaje.getType()==Mensaje.MessageType.libraryConnectionRequest){
                            
                            System.out.println("Conectando con aplicación: "+mensaje.getApplication());
                            
                            sendLibraryConnectionResponse(mensaje.getApplication());
                            
                            estado=Estados.inicializado;
                        }
                        break;
                    case inicializado:
                        switch(mensaje.getType()){
                            case rpcSpawn:
                                System.out.println("Llega un Spawn...");
                                break;
                            case serverConnectionRequest:
                                 System.out.println("Llega una solicitud de comenzar conexión..");
                                
                                 
                                error=connectionManager.connect(mensaje.servidor,mensaje.puerto);
                                if(error!=0){
                                   System.out.println("No se puedo conectar al servidor..."); 
                                   sendConnectionReplyRefused(error);
                                } else {
                                    sendConnectionReplyOk();
                                    // estado=Estados.inicializado_servidor
                                }
                                break;
                        }
//                          if (mensaje.getType()==Mensaje.MessageType.libraryChatMessage){
//                            System.out.println("Chat > "+mensaje.getMessage());
//                    
//                         enviarMensaje(mensaje.getMessage());
//                }
                     
                        break;
                }
                
            } while(!salir);
            
        } catch (IOException ex) {
            Logger.getLogger(MatildaLibClient.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try {
                in.close();
                out.close();
            } catch (IOException ex) {
                Logger.getLogger(MatildaLibClient.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
    }

    private void enviarMensaje(String message) {
        
    }
    
    private void sendLibraryConnectionResponse(String name) {
        out.println("Hi:Ok:"+name);
    }
}
